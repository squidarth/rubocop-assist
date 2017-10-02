require 'rubocop'
require 'active_support/all'
require 'json'
require 'timeout'
require 'parser/current'

stream = StringIO.new
$stdout = stream

def handler(context)
  request = context.request
  parsed_body = JSON.parse(request.body.read)
  parsed_rule = Parser::CurrentRuby.parse(parsed_body["rule"])
  rule_name = get_class_name(parsed_rule)
  eval_rule(parsed_body["code"], parsed_body["rule"], rule_name)
end

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
#stream = StringIO.new
#$stdout = stream

def eval_rule(code, rule, rule_name)
  Timeout::timeout(5) {
    eval rule
  }

  options, = RuboCop::Options.new.parse(
    ['--format', 'simple','--only', rule_name]
  )
  options[:stdin] = code
  runner = RuboCop::Runner.new(options, RuboCop::ConfigStore.new)
  runner.run(['x.rb'])
  output = $stdout.string

  STDOUT.puts $stdout.string
  $stdout.string = ''

  output
end

# eval_rule(ARGV[0], ARGV[1])
