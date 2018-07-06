#!/usr/bin/env ruby

require 'rack'
require 'rack/handler/puma'

class Greeter

  def call(env)
    Rack::Response.new("Hello World")
  end
end
Rack::Handler::Puma.run Greeter.new
