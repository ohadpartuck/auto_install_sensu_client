#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   check-app-health
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/http'

class CheckHealthMulti < Sensu::Plugin::Check::CLI
  option :url,
       short: '-u URL',
  		 proc: proc { |q| q.split(',') },
  		 default: 'http://localhost:5000/health_check/' 

  option :warn,
         short: '-w WARN',
         proc: proc(&:to_f),
         default: 0.5

  option :crit,
         short: '-c CRIT',
         proc: proc(&:to_f),
         default: 1

  def run
    urls = {dal01: {port: 5000},
    }
    urls.each do
    url = URI.parse(config[:url])
    req = Net::HTTP::Get.new(url.to_s)
    start_time = Time.now

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)

    critical if 'application/json' != response.content_type

    elapsed_time = Time.now - start_time

    critical if elapsed_time > config[:crit]
    warning if elapsed_time > config[:warn]
    ok
  end
end