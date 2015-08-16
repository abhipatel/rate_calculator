# Rate Calculator Example

## Installation

- `gem install bundler`
- `bundle install`

## Running Calculator

rate_calculator.rb is the main file. It expects a csv file for the rates information and the loan amount.

Example command:
- `ruby lib/rate_calculator.rb assets/example_market.csv 1000`

## Inputs

Invalid inputs will throw an error and stop the process running

Rates file restrictions:
* Rate file has to be present and populated with rates
* Lender, rate and available amount need to be present

Amount restrictions:
* Value is in increments of 100
* Value is between 100 and 15000

## Output

Output will show the follow:
* Requested amount
* Rate available
* Monthly repayment
* Total repayment

Best rate is used first and then second best if the first lender does not have sufficient funds and so on.

Interest rate uses monthly compound interest rate calculation