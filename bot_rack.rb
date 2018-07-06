#!/usr/bin/env ruby

require 'rack'
require 'net/http'


class Greeter

  def call(env)
    request = Rack::Request.new(env)
    code = 200
    body = ""
    content_type = {'Content-Type' => 'application/json'}
    case request.path
    when "/"
      Rack::Response.new("BOT")
    when "/oauth"
      if request.params['username'].nil?
        body = "{\"status\": \"KO\",\"data\":\"unauthorized_client\"}"
        code = 500
      elsif request.params['password'].nil?
        body = "{\"status\": \"KO\",\"data\":\"unauthorized_client\"}"
        code = 500
      else
        resp = call_site(request.params['username'], request.params['password'])
        body = "{\"status\": \"#{resp[:status]}\", \"data\": \"#{resp[:data]}\"}"
        code = resp[:code]
      end
      Rack::Response.new(body, code, content_type)
    else
      Rack::Response.new("Not Found", 404)
    end
  end

  def call_site(username, password)
    resp = {}
    resp[:code] = 500
    resp[:status] = "KO"
    resp[:data] = "unauthorized_client"

    begin
      uri1 = URI('https://orbis-ej-03.lotoquebec.net/lqs/oauth/authorize?client_id=IGT_CONNECT&scope=pam_player&channel=I&state=state&response_type=code&redirect_uri=com-poker-espacejeux://local/login/auth')

      req1 = Net::HTTP::Get.new(uri1)
      req1['Connection'] = 'keep-alive'
      req1['Pragma'] = 'no-cache'
      req1['Cache-Control'] = 'no-cache'
      req1['Upgrade-Insecure-Requests'] = '1'
      req1['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
      req1['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
      req1['Accept-Encoding'] = 'gzip, deflate, br'
      req1['Accept-Language'] = 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7'
      req1['Cookie'] = 'navigationCookie=8e5e00f8-0e90-4552-8446-a73c8d3d320b'

      proxy_addr = "172.26.0.133"
      proxy_port = "3128"

      res1 = Net::HTTP.start(uri1.host, uri1.port, proxy_addr, proxy_port, :use_ssl => uri1.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(req1)
      end

      uri2 = URI(res1['location'])
      req2 = Net::HTTP::Post.new(uri2)
      req2['Connection'] = 'keep-alive'
      req2['Pragma'] = 'no-cache'
      req2['Cache-Control'] = 'no-cache'
      req2['Origin'] = res1['location']
      req2['Upgrade-Insecure-Requests'] = '1'
      req2['Content-Type'] = 'application/x-www-form-urlencoded'
      req2['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
      req2['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
      req2['Referer'] = res1['location']
      req2['Accept-Encoding'] = 'gzip, deflate, br'
      req2['Accept-Language'] = 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7'
      req2['Cookie'] = 'navigationCookie=8e5e00f8-0e90-4552-8446-a73c8d3d320b' + '; ' + res1['set-cookie']
      #puts req2['Cookie']
      req2.set_form_data('longitude' => '', 'latitude' => '', 'username' => username, 'password' => password, 'boutonLogin' => 'Login')

      res2 = Net::HTTP.start(uri2.host, uri2.port, proxy_addr, proxy_port, :use_ssl => uri2.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(req2)
      end
      #puts res2['location']


      uri3 = URI(res2['location'])

      req3 = Net::HTTP::Get.new(uri3)
      req3['Connection'] = 'keep-alive'
      req3['Pragma'] = 'no-cache'
      req3['Cache-Control'] = 'no-cache'
      req3['Upgrade-Insecure-Requests'] = '1'
      req3['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
      req3['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
      req3['Accept-Encoding'] = 'gzip, deflate, br'
      req3['Accept-Language'] = 'it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7'
      req3['Cookie'] = req2['Cookie']

      res3 = Net::HTTP.start(uri3.host, uri3.port, proxy_addr, proxy_port, :use_ssl => uri3.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(req3)
      end
      #puts res3['location']

      resp[:code] = 200
      resp[:status] = "OK"
      resp[:data] = res3['location'].split('=')[1].split('&').first
      resp
    rescue Exception => e
      resp
    end
  end
end
Rack::Handler::WEBrick.run Greeter.new, :Port => 3000 #, :Host => "192.168.1.3"
