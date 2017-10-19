require 'sinatra'
require 'json'
require 'parser/current'
require 'open3'

set :bind, '0.0.0.0'

def get_program
  <<-RUBY
  require 'rubocop'
  require 'active_support/all'
  require 'json'
  require 'timeout'
  require 'parser/current'

  stream = StringIO.new
  $stdout = stream

  def get_class_name(ast)
    return nil unless ast.class == Parser::AST::Node
    class_name = nil
    ast.children.each do |child|
      if child.respond_to?(:type) && child&.type == :class
        class_name = child.children.first.children[1]
      else
        class_name = get_class_name(child)
      end
    end
    class_name.to_s
  end

  def eval_rule(code, rule, rule_name)
    Timeout::timeout(2) {
      eval rule
    }

    options, = RuboCop::Options.new.parse(
      ['--format', 'simple','--only', rule_name]
    )
    options[:stdin] = code
    runner = RuboCop::Runner.new(options, RuboCop::ConfigStore.new)

    Timeout::timeout(2) {
      runner.run(['x.rb'])
    }
    output = $stdout.string

    STDOUT.puts $stdout.string
    $stdout.string = ''

    output
  end

  code = ARGV[0].dup
  rule = ARGV[1].dup

  parsed_rule = Parser::CurrentRuby.parse(rule)
  rule_name = get_class_name(parsed_rule)
  puts eval_rule(code, rule, rule_name)
  RUBY
end

def execute_ruby(code, rule)
  stdout, = Open3.capture2('ruby', '-e', get_program, code, rule, rlimit_cpu: [2,2])
  stdout
end

get '/' do
  erb :index
end

post '/parse' do
  content_type :json
  response = Parser::CurrentRuby.parse(params["code"]).to_s
  return { ast: response }.to_json
end

post '/rubocop-rule-eval' do
  content_type :json

  resp = execute_ruby(params['code'], params['rule'])
  return { value: resp }.to_json
end
