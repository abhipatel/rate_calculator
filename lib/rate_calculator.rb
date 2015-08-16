require_relative 'calculator'

if ARGV.empty? || ARGV.size < 2
  puts "Arguments missing, example command: ruby calculator.rb market.csv 1000"
  exit 1
end

calculator = Calculator.new ARGV.shift, ARGV.shift
calculator.get_rates
