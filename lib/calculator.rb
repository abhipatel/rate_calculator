require 'csv'

class Calculator

  MIN_REQUESTED_AMOUNT = 100
  MAX_REQUESTED_AMOUNT = 15000
  attr_reader :rates

  def initialize rates_file_path, amount
    if rates_file_path.nil?
      raise(ArgumentError, "Rates file path should be set")
    elsif !File.size?(rates_file_path)
      raise(ArgumentError, "Rates file not found or blank")
    else
      @rates = parse_rates_file rates_file_path
      @total_available = @rates.inject(0) {|sum,row| sum + row[:available]}
    end

    @requested_amount = amount.to_i
    if @requested_amount == 0
      raise(ArgumentError, "Requested amount must be set and a valid integer value")
    elsif @requested_amount < MIN_REQUESTED_AMOUNT || @requested_amount > MAX_REQUESTED_AMOUNT || @requested_amount % 100 > 0
      raise(ArgumentError, "Requested amount must be between #{MIN_REQUESTED_AMOUNT} and #{MAX_REQUESTED_AMOUNT} and an increment of 100")
    end
  end

  def get_rates
  end

  private
  def parse_rates_file rates_file_path
    CSV::Converters[:blank_to_nil] = lambda do |field|
      field && field.empty? ? nil : field
    end
    csv = CSV.open(rates_file_path, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])

    rates = csv.to_a.map!{|row| row.to_hash}
    rates.delete_if {|row| row[:lender].nil? || row[:rate].nil? || row[:available].nil?}
    raise(ArgumentError, "Rates file does not contain any rates") if rates.empty?
    rates.sort! {|a,b| a[:rate] <=> b[:rate]}
    csv.close
    rates
  end
end