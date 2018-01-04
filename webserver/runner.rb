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
  eval rule

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

code = ARGV[0].dup
rule = ARGV[1].dup

parsed_rule = Parser::CurrentRuby.parse(rule)
rule_name = get_class_name(parsed_rule)
puts eval_rule(code, rule, rule_name)
