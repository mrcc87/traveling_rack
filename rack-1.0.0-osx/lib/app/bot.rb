#!/usr/bin/env ruby

require 'rack'

class Greeter

  def call(env)
    Rack::Response.new("Hello World")
  end
end
Rack::Handler::Thin.run Greeter.new, :Port => 3000
