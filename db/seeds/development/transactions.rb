# Enough history to page through the transaction list, always reaching up to today. The fixed seed keeps the mix
# of counterparties and amounts the same on every reset.
random = Random.new(42)
payees = {
  counterparties.rewe => ["VISA Debitkartenumsatz", -80..-2],
  counterparties.insurance => ["Haftpflicht Vertrag 1234567", -15..-5],
  counterparties.dkb => ["Rechnung Entgelt", -5..-1],
  counterparties.savings => ["Sparen", -300..-50],
  counterparties.employer => ["GEHALT", 1800..2100]
}

last_balance = balances.girokonto_current
balance_today = last_balance.amount

transactions.with account: accounts.girokonto do |transactions|
  200.times do |index|
    counterparty, (reference, range) = payees.to_a.sample(random:)
    booked_on = Date.current - random.rand(365)
    amount = BigDecimal(random.rand(range).to_s) + BigDecimal(random.rand(100)) / 100
    balance_today += amount if booked_on > last_balance.recorded_on

    transactions.create counterparty:, booked_on:, value_on: booked_on, amount:, reference: "#{reference} #{index}",
      raw_row: "seed-#{index}"
  end
end

# The shared balance has a fixed date, so the history generated after it needs a balance of its own.
if Date.current > last_balance.recorded_on
  balances.create :girokonto_today, account: accounts.girokonto, recorded_on: Date.current, amount: balance_today
end
