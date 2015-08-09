require 'net/http'
module NetX
class HTTPUnix < Net::HTTP
  BufferedIO = ::Net::BufferedIO
  UNIX_REGEXP = %r{^unix://}i

  def initialize(address, port=nil)
    super(address, port)
    case address
    when UNIX_REGEXP
      @socket_type = 'unix'
      @socket_path = address.sub(UNIX_REGEXP, '')
      # Address and port are set to localhost so the HTTP client constructs
      # a HOST request header nginx will accept.
      @address = 'localhost'
      @port = 80
    else
      @socket_type = 'inet'
    end
  end

  def connect
    if @socket_type == 'unix'
      connect_unix
    else
      super
    end
  end

  ##
  # connect_unix is an alternative implementation of Net::HTTP#connect specific
  # to the use case of using a Unix Domain Socket.
  def connect_unix
    D "opening connection to #{@socket_path}..."
    s = timeout(@open_timeout) { UNIXSocket.open(@socket_path) }
    D "opened"
    @socket = BufferedIO.new(s)
    @socket.read_timeout = @read_timeout
    @socket.continue_timeout = @continue_timeout
    @socket.debug_output = @debug_output
    on_connect
  end
end
end
