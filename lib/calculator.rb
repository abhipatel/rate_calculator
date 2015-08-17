require 'csv'

class Calculator

  @min_requested_amount = 100
  @max_requested_amount = 15000
  attr_reader :rates

  def initialize rates_file_path, min_requested_amount, max_requested_amount, rate_precision=3, amount_precision=2
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
    @output_rate_precision = rate_precision
    @output_amount_precision = amount_precision
  end

  def calculate_loan_details amount
    requested_amount = parse_requested_amount amount
    remaining_requested_amount = requested_amount
    total_monthly_owed = 0
    total_owed = 0
    max_rate = @rates[0][:rate]
    min_rate = @rates[0][:rate]
    @rates.each do |loan_details|
      loan_rate = loan_details[:rate]
      if loan_rate > max_rate
        max_rate = loan_rate
      elsif loan_rate < min_rate
        min_rate = loan_rate
      end
      loan_available = loan_details[:available]
      loan_amount = remaining_requested_amount < loan_available ? remaining_requested_amount : loan_available
      remaining_requested_amount -= loan_amount
      monthly_owed = monthly_repayment_amount loan_amount, loan_rate, 12, 3
      total_monthly_owed += monthly_owed
      total_owed += monthly_owed * 12 * 3
      break if remaining_requested_amount == 0
    end
    estimated_rate = interpolate_rate requested_amount.round(@output_amount_precision), total_monthly_owed, 12, 3, max_rate, min_rate
    [requested_amount.round(@output_amount_precision), estimated_rate.round(@output_rate_precision), total_monthly_owed.round(@output_amount_precision), total_owed.round(@output_amount_precision)]
  end

  def monthly_repayment_amount principal_amount, rate, payments_count, year_count
    (principal_amount * rate)/(12*(1 - ((1 + (rate/payments_count))**(-1*payments_count*year_count))))
  end

  def principal_payable monthly_payment, rate, payments_count, year_count
    monthly_payment * (1-(1+(rate/payments_count))**(-1 * payments_count * year_count)) * (payments_count/rate)
  end

  def interpolate_rate principal_amount, monthly_payments, payments_count, year_count, max_rate, min_rate
    if max_rate != min_rate
      max_principal = principal_payable monthly_payments, max_rate, payments_count, year_count
      if max_principal.round(@output_amount_precision) == principal_amount
        max_rate
      else
        min_principal = principal_payable monthly_payments, min_rate, payments_count, year_count
        if min_principal.round(@output_amount_precision) == principal_amount
          min_rate
        else
          new_rate = (min_rate*(max_principal-principal_amount) + max_rate * (principal_amount-min_principal))/(max_principal-min_principal)
          new_rate
        end
      end
    else
      max_rate
    end
  end

  def print_loan_details loan_details
    puts "Requested amount: £#{'%.02f' % loan_details[0]}"
    puts "Rate: #{'%.01f' % (loan_details[1]*100)}%"
    puts "Monthly repayment: £#{'%.02f' % loan_details[2]}"
    puts "Total repayment: £#{'%.02f' % loan_details[3]}"
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
    rates.sort! do |a,b|
      (a[:rate] <=> b[:rate]).nonzero? ||
      (b[:available] <=> a[:available])
    end
    csv.close
    rates
  end

  def parse_requested_amount amount
    requested_amount = amount.to_f
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