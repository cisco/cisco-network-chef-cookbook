# NetX::HTTPUnix

This gem is a small wrapper around Ruby's `Net::HTTP` interface that provides
support for unix domain sockets.  If you need to issue HTTP requests to a HTTP
server listening on a local unix domain socket then this library is for you.

Simply `require 'net_x/http_unix'` in place of `require 'net/http'` and use
`NetX::HTTPUnix` as you would `Net::HTTP`.  Address strings starting with
'unix://' will automatically be handled by a unix domain socket instead of a
TCP socket.

## Installation

Add this line to your application's Gemfile:

    gem 'net_http_unix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install net_http_unix

## Usage

Use the library just like you would `Net::HTTP.start` and `Net::HTTP.new`, but
with `NetX::HTTPUnix.start` and `NetX::HTTPUnix.new`.

For example a traditional SSL client works as expected:

```ruby
require 'net_http_unix'
req = Net::HTTP::Get.new("/status.json")
client = NetX::HTTPUnix.new('github.com', 443)
client.use_ssl = true
client.verify_mode = OpenSSL::SSL::VERIFY_NONE
resp = client.request(req)
puts resp.body
{"status":"ok","configuration_id":0}
```

And the corresponding `unix:///path/to/foo.sock` URI syntax:

```ruby
require 'net_http_unix'
req = Net::HTTP::Get.new("/status.json")
client = NetX::HTTPUnix.new('unix:///tmp/unicorn.sock')
resp = client.request(req)
puts resp.body
{"status":"ok","configuration_id":0,"socket":true}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
