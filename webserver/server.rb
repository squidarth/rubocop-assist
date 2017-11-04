require 'sinatra'
require 'json'
require 'parser/current'
require 'open3'

set :bind, '0.0.0.0'

def execute_ruby(code, rule)
  stdout, = Open3.capture2(
    'ruby',
    'runner.rb',
    code,
    rule,
    rlimit_cpu: [2, 2],
    rlimit_nproc: 1
  )
  stdout
end

get '/' do
  erb :index
end

get '/about' do
  erb :about
end

post '/parse' do
  content_type :json
  response = Parser::CurrentRuby.parse(params['code']).to_s
  return { ast: response }.to_json
end

post '/rubocop-rule-eval' do
  content_type :json

  resp = execute_ruby(params['code'], params['rule'])
  return { value: resp }.to_json
end
