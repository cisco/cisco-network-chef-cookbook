require 'spec_helper'
require 'net_x/http_unix'
require 'tempfile'

describe NetX::HTTPUnix do
  let(:socket_url) { "unix://#{@socket_path}" }
  let(:get_request) { Net::HTTP::Get.new("/") }

  before :all do
    tmpfile = Tempfile.open('socket')
    @socket_path = tmpfile.path
    tmpfile.close
    tmpfile.unlink

    semaphore = Mutex.new
    servers_starting = 2

    @server_thread_tcp = Thread.new do
      TCPServer.open(2000) do |server|
        semaphore.synchronize { servers_starting -= 1 }
        while conn = server.accept
          conn.puts "HTTP/1.1 200 OK"
          conn.puts ""
          conn.puts "Hello from TCP server"
          conn.close
        end
      end
    end

    @server_thread_unix = Thread.new do
      UNIXServer.open(@socket_path) do |server|
        semaphore.synchronize { servers_starting -= 1 }
        while conn = server.accept
          conn.puts "HTTP/1.1 200 OK"
          conn.puts ""
          conn.puts "Hello from UNIX server"
          conn.close
        end
      end
    end

    sleep(0.01) while servers_starting > 0
  end

  after :all do
    Thread.kill(@server_thread_unix)
    Thread.kill(@server_thread_tcp)
  end

  describe ".start" do
    it "accepts '127.0.0.1', 2000 host and port" do
      resp = described_class.start('127.0.0.1', 2000) do |http|
        http.request(get_request)
      end
      expect(resp.body).to eq("Hello from TCP server\n")
    end

    it "accepts unix:///path/to/socket URI" do
      resp = described_class.start(socket_url) do |http|
        http.request(get_request)
      end
      expect(resp.body).to eq("Hello from UNIX server\n")
    end
  end

  describe ".new" do
    it "accepts '127.0.0.1', 2000 host and port" do
      http = described_class.new("127.0.0.1", 2000)

      resp = http.request(get_request)
      expect(resp.body).to eq("Hello from TCP server\n")
    end

    it "accepts unix:///path/to/socket URI" do
      http = described_class.new(socket_url)

      resp = http.request(get_request)
      expect(resp.body).to eq("Hello from UNIX server\n")
    end
  end
end
