require_relative 'calculator'

if ARGV.empty? || ARGV.size < 2
  puts "Arguments missing, example command: ruby calculator.rb market.csv 1000"
  exit 1
end

begin
  calculator = Calculator.new ARGV.shift, 100, 15000
  calculator.get_rates ARGV.shift
rescue => e
  puts e.message
end