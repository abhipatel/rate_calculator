require_relative 'calculator'

if ARGV.empty? || ARGV.size < 2
  puts "Arguments missing, example command: ruby calculator.rb market.csv 1000"
  exit 1
end

begin
  calculator = Calculator.new ARGV.shift, 100, 15000
  loan_details = calculator.calculate_loan_details ARGV.shift
  calculator.print_loan_details loan_details
rescue => e
  puts e.message
end