require 'csv'

class Calculator

  @min_requested_amount = 100
  @max_requested_amount = 15000
  attr_reader :rates

  def initialize rates_file_path, min_requested_amount, max_requested_amount
    if rates_file_path.nil?
      raise(ArgumentError, "Rates file path should be set")
    elsif !File.size?(rates_file_path)
      raise(ArgumentError, "Rates file not found or blank")
    else
      @rates = parse_rates_file rates_file_path
      @total_available = @rates.inject(0) {|sum,row| sum + row[:available]}
    end
    @min_requested_amount = min_requested_amount
    @max_requested_amount = max_requested_amount
  end

  def get_rates amount
    requested_amount = parse_requested_amount amount
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

  def parse_requested_amount amount
    requested_amount = amount.to_i
    if requested_amount == 0
      raise(ArgumentError, "Requested amount must be set and a valid integer value")
    elsif requested_amount < @min_requested_amount || requested_amount > @max_requested_amount || requested_amount % 100 > 0
      raise(ArgumentError, "Requested amount must be between #{@min_requested_amount} and #{@max_requested_amount} and an increment of 100")
    elsif requested_amount > @total_available
      raise(ArgumentError, "It is not possible to provide a quote at this time")
    end
    requested_amount
  end
end