#!/usr/bin/env ruby

require 'rack'
require 'net/http'


class Greeter

  def call(env)
    request = Rack::Request.new(env)
    case request.path
    when "/"
      Rack::Response.new("BOT")
    when "/oauth"
      body = "{ \"name\": \"#{request.params['username']}\", \"password\": \"#{request.params['password']}\", \"res\": \"#{call_site}\" }"
      Rack::Response.new(body, 200, {'Content-Type' => 'application/json'})
    else
    Rack::Response.new("Not Found", 404)
    end
  end

  def call_site
    uri = URI('https://www.mirceasamuila.com/')
    req = Net::HTTP::Get.new(uri)
    res = Net::HTTP::start(uri.host, uri.port, :use_ssl => uri.scheme == "https") do |http|
      http.request(req)
    end

    res['server']
  end
end
Rack::Handler::WEBrick.run Greeter.new, :Port => 3000 #, :Host => "192.168.1.3"
