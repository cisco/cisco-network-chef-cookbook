# NXAPI client library.
#
# November 2014, Glenn F. Matthews
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'
require File.join(File.dirname(__FILE__), 'cisco_logger')

include CiscoLogger
require 'net/http'

module CiscoNxapi
  class NxapiError < RuntimeError
  end

  class CliError < NxapiError
    attr_reader :input, :msg, :code, :clierror, :previous
    def initialize(input, msg, code, clierror, previous)
      @input = input
      @msg = msg
      @code = code
      @clierror = clierror
      @previous = previous
    end

    def to_s
      "CliError: '#{@input}' rejected with message: '#{clierror}'"
    end

    def message
      to_s
    end
  end

  class RequestNotSupported < NxapiError
  end

  class ConnectionRefused < NxapiError
  end

  class HTTPBadRequest < NxapiError
  end

  class HTTPUnauthorized < NxapiError
  end

  # Location of unix domain socket for NXAPI localhost
  NXAPI_UDS = '/tmp/nginx_local/nginx_1_be_nxapi.sock'
  # NXAPI listens for remote connections to "http://<switch IP>/ins"
  # NXAPI listens for local connections to "http://<UDS>/ins_local"
  NXAPI_REMOTE_URI_PATH = '/ins'
  NXAPI_UDS_URI_PATH = '/ins_local'
  # Latest supported version is 1.0
  NXAPI_VERSION = '1.0'

  class NxapiClient
    # Constructor for NxapiClient. By default this connects to the local
    # unix domain socket. If you need to connect to a remote device,
    # you must provide the address/username/password parameters.
    def initialize(address = nil, username = nil, password = nil)
      # Default: connect to unix domain socket on localhost, if available
      if address.nil?
        if File.socket?(NXAPI_UDS)
          # net_http_unix provides NetX::HTTPUnix, a small subclass of Net::HTTP
          # which supports connection to local unix domain sockets. We need this
          # in order to run natively under NX-OS but it's not needed for off-box
          # unit testing where the base Net::HTTP will meet our needs.
          require 'net_http_unix'
          @http = NetX::HTTPUnix.new('unix://' + NXAPI_UDS)
        else
          fail "No address specified but no UDS found at #{NXAPI_UDS} either"
        end
      else
        fail TypeError, 'invalid address' unless address.is_a?(String)
        fail ArgumentError, 'empty address' if address.empty?
        # Remote connection. This is primarily expected
        # when running e.g. from a Unix server as part of Minitest.
        @http = Net::HTTP.new(address)
        # In this case, a username and password are mandatory
        fail TypeError if username.nil? || password.nil?
      end
      # The default read time out is 60 seconds, which may be too short for
      # scaled configuration to apply. Change it to 300 seconds, which is
      # also used as the default config by firefox.
      @http.read_timeout = 300

      unless username.nil?
        fail TypeError, 'invalid username' unless username.is_a?(String)
        fail ArgumentError, 'empty username' unless username.length > 0
      end
      unless password.nil?
        fail TypeError, 'invalid password' unless password.is_a?(String)
        fail ArgumentError, 'empty password' unless password.length > 0
      end
      @username = username
      @password = password
      @cache_enable = true
      @cache_auto = true
      cache_flush
    end

    def to_s
      @http.address
    end

    def inspect
      "<NxapiClient of #{@http.address}>"
    end

    def reload
      # no-op for now
    end

    def cache_enable?
      @cache_enable
    end

    def cache_enable=(enable)
      @cache_enable = enable
      cache_flush unless enable
    end

    def cache_auto?
      @cache_auto
    end

    attr_writer :cache_auto

    # Clear the cache of CLI output results.
    #
    # If cache_auto is true (default) then this will be performed automatically
    # whenever a config() or exec() is called, but providers may also call this
    # to explicitly force the cache to be cleared.
    def cache_flush
      @cache_hash = {
        'cli_conf' => {},
        'cli_show' => {},
        'cli_show_ascii' => {}
      }
    end

    # Configure the given command(s) on the device.
    #
    # @raise [CiscoNxapi::CliError] if any command is rejected by the device
    #
    # @param commands [String, Array<String>] either of:
    #   1) The configuration sequence, as a newline-separated string
    #   2) An array of command strings (one command per string, no newlines)
    def config(commands)
      cache_flush if cache_auto?

      if commands.is_a?(String)
        commands = commands.split(/\n/)
      elsif !commands.is_a?(Array)
        fail TypeError
      end
      req('cli_conf', commands)
    end

    # Executes a command in exec mode on the device.
    #
    # If cache_auto? (on by default) is set then the CLI cache will be flushed.
    #
    # For "show" commands please use show() instead of exec().
    #
    # @param command [String] the exec command to execute
    # @return [String, nil] the body of the output of the exec command
    #   (if any)
    def exec(command)
      cache_flush if cache_auto?
      req('cli_show_ascii', command)
    end

    # Executes a "show" command on the device, returning either ASCII or
    # structured output.
    #
    # Unlike config() and exec() this will not clear the CLI cache;
    # multiple calls to the same "show" command may return cached data
    # rather than querying the device repeatedly.
    #
    # @raise [CiscoNxapi::RequestNotSupported] if
    #   structured output is requested but the given command can't provide it.
    # @raise [CiscoNxapi::CliError] if the command is rejected by the device
    #
    # @param command [String] the show command to execute
    # @param type [:ascii, :structured] ASCII or structured output.
    #             Default is :ascii
    # @return [String] the output of the show command, if type == :ascii
    # @return [Hash{String=>String}] key-value pairs, if type == :structured
    def show(command, type = :ascii)
      if type == :ascii
        return req('cli_show_ascii', command)
      elsif type == :structured
        return req('cli_show', command)
      else
        fail TypeError
      end
    end

    # Sends a request to the NX API and returns the body of the request or
    # handles errors that happen.
    # @raise CiscoNxapi::ConnectionRefused if NXAPI is disabled
    # @raise CiscoNxapi::HTTPUnauthorized if username/password are invalid
    # @raise CiscoNxapi::HTTPBadRequest (should never occur)
    # @raise CiscoNxapi::RequestNotSupported
    # @raise CiscoNxapi::CliError if any command is rejected as invalid
    #
    # @param type ["cli_show", "cli_show_ascii"] Specifies the type of command
    #             to be executed.
    # @param command_or_list [String, Array<String>] The command or array of
    #                        commands which should be run.
    # @return [Hash, Array<Hash>] output when type == "cli_show"
    # @return [String, Array<String>] output when type == "cli_show_ascii"
    def req(type, command_or_list)
      if command_or_list.is_a?(Array)
        # NXAPI wants config lines to be separated by ' ; '
        command = command_or_list.join(' ; ')
      else
        command = command_or_list
        command_or_list = [command]
      end

      debug("Input (#{type}): \'#{command}\'")
      if cache_enable? && @cache_hash[type] && @cache_hash[type][command]
        return @cache_hash[type][command]
      end

      # form the request
      if !(@username.nil? || @password.nil?)
        request = Net::HTTP::Post.new(NXAPI_REMOTE_URI_PATH)
        request.basic_auth("#{@username}", "#{@password}")
      else
        request = Net::HTTP::Post.new(NXAPI_UDS_URI_PATH)
        request['Cookie'] = 'nxapi_auth=admin:local'
      end
      request.content_type = 'application/json'
      request.body = {
        'ins_api' => {
          'version' => NXAPI_VERSION,
          'type' => "#{type}",
          'chunk' => '0',
          'sid' => '1',
          'input' => "#{command}",
          'output_format' => 'json'
        }
      }.to_json

      # send the request and get the response
      debug("Sending HTTP request to NX-API at #{@http.address}:\n" +
            "#{request.to_hash}\n#{request.body}")
      begin
        response = @http.request(request)
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET
        emsg = 'Connection refused or reset. Is the NX-API feature enabled?'
        raise ConnectionRefused, emsg
      end
      handle_http_response(response)
      body = JSON.parse(response.body)
      # In case of an error the JSON may not be complete, so we need to
      # proceed carefully, as blindly doing body["ins_api"]["outputs"]["output"]
      # could throw an error otherwise.
      output = body['ins_api']
      fail NxapiError, "unexpected JSON output:\n#{body}" unless output
      output = output['outputs'] if output['outputs']
      output = output['output'] if output['output']

      prev_cmds = []
      if output.is_a?(Array)
        output.zip(command_or_list) do |o, cmd|
          handle_output(prev_cmds, cmd, o)
          prev_cmds << cmd
        end
        output = output.collect do |o|
          if type == 'cli_show_ascii' && o['body'].empty?
            ''
          else
            o['body']
          end
        end
      else
        handle_output(prev_cmds, command, output)
        if type == 'cli_show_ascii' && output['body'].empty?
          output = ''
        else
          output = output['body']
        end
      end

      @cache_hash[type][command] = output if cache_enable?
      output
    end
    private :req

    def handle_http_response(response)
      debug("HTTP Response: #{response.message}\n#{response.body}")
      case response
      when Net::HTTPUnauthorized
        emsg = 'HTTP 401 Unauthorized. Are your NX-API credentials correct?'
        fail CiscoNxapi::HTTPUnauthorized, emsg
      when Net::HTTPBadRequest
        emsg = "HTTP 400 Bad Request\n#{response.body}"
        fail CiscoNxapi::HTTPBadRequest, emsg
      end
    end
    private :handle_http_response

    def handle_output(prev_cmds, command, output)
      if output['code'] == '400'
        # CLI error.
        # Examples: "Invalid input", "Incomplete command", etc.
        fail CliError.new(command, output['msg'], output['code'],
                          output['clierror'], prev_cmds)
      elsif output['code'] == '413'
        # Request too large
        fail NxapiError.new("Error 413: #{output['msg']}")
      elsif output['code'] == '501'
        # if structured output is not supported for this command,
        # raise an exception so that the calling function can
        # handle accordingly
        fail RequestNotSupported.new(
          "Structured output not supported for #{command}")
      else
        debug("Result for '#{command}': #{output['msg']}")
        if output['body'] && !output['body'].empty?
          debug("Output: #{output['body']}")
        end
      end
    end
    private :handle_output
  end
end
