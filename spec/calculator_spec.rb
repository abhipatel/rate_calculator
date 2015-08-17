require 'spec_helper'

describe 'Calculator' do

  describe 'rates file processing' do
    before(:all) do
      @rates_file_path = "assets/test/example_market.csv"
      @min_requested_amount = 100
      @max_requested_amount = 10000
    end

    it 'rejects file path not set' do
      expect{ Calculator.new(nil, @min_requested_amount, @max_requested_amount) }.to raise_error(ArgumentError, "Rates file path should be set")
    end

    it 'rejects invalid rates file path' do
      expect{ Calculator.new("example_market.csv", @min_requested_amount, @max_requested_amount) }.to raise_error(ArgumentError, "Rates file not found or blank")
      expect{ Calculator.new(@rates_file_path, @min_requested_amount, @max_requested_amount) }.not_to raise_error
    end

    it 'rejects empty rates file' do
      expect{ Calculator.new("assets/test/empty_market.csv", @min_requested_amount, @max_requested_amount) }.to raise_error(ArgumentError, "Rates file not found or blank")
    end

    it 'rejects rates file with no rates' do
      expect{ Calculator.new("assets/test/blank_market.csv", @min_requested_amount, @max_requested_amount) }.to raise_error(ArgumentError, "Rates file does not contain any rates")
    end

    it 'rejects rates file with missing data' do
      expect{ Calculator.new("assets/test/broken_market.csv", @min_requested_amount, @max_requested_amount) }.to raise_error(ArgumentError, "Rates file does not contain any rates")
    end

    it 'sorts rates by lowest rate first' do
      calculator = Calculator.new("assets/test/unsorted_market.csv", @min_requested_amount, @max_requested_amount)
      sorted_market = [{lender: "Jane", rate: 0.069, available: 480}, {lender: "John", rate: 0.069, available: 50}, {lender: "Bob", rate: 0.075, available: 640}]
      expect(calculator.rates).to eq sorted_market
    end
  end

  describe 'requested amount processing' do
    before(:all) do
      @calculator = Calculator.new("assets/test/example_market.csv", 100, 10000)
    end

    it 'rejects blank loan amount' do
      expect{ @calculator.calculate_loan_details(nil) }.to raise_error(ArgumentError, "Requested amount must be set and a valid integer value")
      expect{ @calculator.calculate_loan_details(1000) }.not_to raise_error
    end

    it 'rejects loan amount that is too small' do
      expect{ @calculator.calculate_loan_details(50) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount that is too large' do
      expect{ @calculator.calculate_loan_details(20000) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount in invalid increment' do
      expect{ @calculator.calculate_loan_details(503) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount if market does not have sufficient available amount' do
      expect{ @calculator.calculate_loan_details(10000)}.to raise_error(ArgumentError, "It is not possible to provide a quote at this time")
    end
  end

  describe 'rates calculations' do
    before(:all) do
      @calculator = Calculator.new("assets/test/example_market.csv", 100, 10000)
    end

    it 'uses monthly compounding interest to calculate monthly payments' do
      expect(@calculator.monthly_repayment_amount(1000, 0.07, 12, 3).round(2)).to eq 30.88
    end

    it 'uses monthly compounding interest to calculate principal amount' do
      principal_amount = 1000
      repayment_amount = @calculator.monthly_repayment_amount(principal_amount, 0.07, 12, 3)
      expect(@calculator.principal_payable(repayment_amount, 0.07, 12, 3).round(2)).to eq principal_amount
    end

    it 'output rate interpolation retrieves approximate value' do
      monthly_payment = @calculator.monthly_repayment_amount(1000, 0.07, 12, 3)
      expect(@calculator.interpolate_rate(1000, monthly_payment, 12, 3, 0.05, 0.08).round(2)).to eq 0.07
    end

    it 'use first available loan to calculate amount owed' do
      monthly_amount = @calculator.monthly_repayment_amount 200, 0.069, 12, 3
      total_amount = monthly_amount * 12 * 3

      calculated_rates = @calculator.calculate_loan_details("200")
      expect(calculated_rates[0]).to eq 200
      expect(calculated_rates[1]).to eq 0.069
      expect(calculated_rates[2]).to eq monthly_amount.round(2)
      expect(calculated_rates[3]).to eq total_amount.round(2)
    end

    it 'uses combined available loans to calculate amount owed' do
      monthly_amount1 = @calculator.monthly_repayment_amount 480, 0.069, 12, 3
      monthly_amount2 = @calculator.monthly_repayment_amount 520, 0.071, 12, 3
      total_monthly_amount = monthly_amount1 + monthly_amount2
      total_amount = total_monthly_amount * 12 * 3
      
      calculated_rates = @calculator.calculate_loan_details("1000")
      expect(calculated_rates[0]).to eq 1000
      expect(calculated_rates[1]).to eq ((480*0.069 + 520*0.071)/(480 + 520)).round(3)
      expect(calculated_rates[2]).to eq total_monthly_amount.round(2)
      expect(calculated_rates[3]).to eq total_amount.round(2)
    end

    it 'outputs loan details in to correct decimal place' do
      expect(STDOUT).to receive(:puts).with('Requested amount: £1000.00')
      expect(STDOUT).to receive(:puts).with('Rate: 7.0%')
      expect(STDOUT).to receive(:puts).with('Monthly repayment: £30.88')
      expect(STDOUT).to receive(:puts).with('Total repayment: £1111.64')
      @calculator.print_loan_details([1000.001, 0.0701, 30.876, 1111.642])
    end
  end
end