stream = StringIO.new
$stdout = stream

require 'sinatra'
require 'rubocop'
require 'active_support/all'
require 'json'

require 'sinatra/cross_origin'
require 'pry'

configure do
  enable :cross_origin
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Origin"] = "*"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  200
end

post '/rubocop-parse' do
  content_type :json
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Origin"] = "*"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  $stdout.string = ''

  if params['rule'].blank? || params['code'].blank?
    return { code: 'No input' }.to_json
  end

  rule = eval params['rule']
  rule_name = rule.name.demodulize

  options, = RuboCop::Options.new.parse(
    ['--only', rule_name, '--format', 'simple']
  )
  options[:stdin] = params['code']
  runner = RuboCop::Runner.new(options, RuboCop::ConfigStore.new)
  runner.run(['x.rb'])
  STDOUT.puts $stdout.string

  output = { code: $stdout.string }.to_json

  STDOUT.puts $stdout.string
  $stdout.string = ''

  return output
end

STDOUT.puts $stdout.string
$stdout.string = ''
