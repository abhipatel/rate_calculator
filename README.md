# Rate Calculator Example

## Installation

Calculator can run without executing the commands below but if you run into any errors
the commands could help solve them.

- `gem install bundler`
- `bundle install`

## Running Calculator

rate_calculator.rb is the main file. It expects a csv file for the rates information and the loan amount.

Example command:
- `ruby lib/rate_calculator.rb assets/market.csv 1000`

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

Interest rate uses monthly compound interest rate calculation. Monthly installments
calculation uses the _Installment Loans_ calculation on the following page:

http://mathforum.org/dr.math/faq/faq.interest.html#install

## Assumptions

* Rate specified in market file is yearly interest rate
* Lender with the higher amount available will be used first if two lenders provide the same interest rate
* Monthly and total repayment amounts are most important in terms of priority, the rate will be interpolated from the repayment amounts if more than one interest rate is used

## Testing

All tests can be run with the following command:
- `rake spec`