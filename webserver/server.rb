require 'sinatra'
require 'json'
require 'parser/current'
require 'httparty'

set :bind, '0.0.0.0'

get '/' do
  erb :index
end

post '/parse' do
  content_type :json
  response = Parser::CurrentRuby.parse(params["code"]).to_s#.gsub("\n", "")
  return { ast: response }.to_json
end

post '/rubocop-rule-eval' do
  content_type :json

  resp = HTTParty.post("http://104.197.22.12/rr1", body: {code: params["code"], rule: params["rule"] }.to_json, headers: {"Content-Type" => "json"}).response.body

  return { value: resp}.to_json
end
