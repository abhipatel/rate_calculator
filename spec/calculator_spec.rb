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
      sorted_market = [{lender: "Jane", rate: 0.069, available: 480}, {lender: "Bob", rate: 0.075, available: 640}]
      expect(calculator.rates).to eq sorted_market
    end
  end

  describe 'requested amount processing' do
    before(:all) do
      @calculator = Calculator.new("assets/test/example_market.csv", 100, 10000)
    end

    it 'rejects blank loan amount' do
      expect{ @calculator.get_rates(nil) }.to raise_error(ArgumentError, "Requested amount must be set and a valid integer value")
      expect{ @calculator.get_rates(1000) }.not_to raise_error
    end

    it 'rejects loan amount that is too small' do
      expect{ @calculator.get_rates(50) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount that is too large' do
      expect{ @calculator.get_rates(20000) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount in invalid increment' do
      expect{ @calculator.get_rates(503) }.to raise_error(ArgumentError, "Requested amount must be between 100 and 10000 and an increment of 100")
    end

    it 'rejects loan amount if market does not have sufficient available amount' do
      expect{ @calculator.get_rates(10000)}.to raise_error(ArgumentError, "It is not possible to provide a quote at this time")
    end
  end
end