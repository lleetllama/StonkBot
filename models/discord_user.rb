class DiscordUser < ActiveRecord::Base
  after_initialize :give_initial_cash

  has_many :discord_user_stonks

  LOAN_INTEREST = 0.1

  def buy_stock(stock_id, quantity)
    option =
      self.discord_user_stonks.create(
        stonk_id: stock_id,
        quantity: 0,
      )
    option.buy_units(quantity)
  end

  def net_worth()
    debt_ammount = (self.debt ||= 0).to_f
    without_debt = (self.wallet_value.to_f +
                    self.discord_user_stonks.map { |x| x.market_value.to_f }.sum)

    with_debt = without_debt - debt_ammount
    return [without_debt.round(2), debt_ammount.round(2), with_debt.round(2)]
  end

  def get_loan(ammount)
    with_interest = ammount + (ammount * LOAN_INTEREST)
    wallet_change(ammount)
    debt_change(with_interest)
  end

  def debt_change(amount)
    self.debt = (debt.to_f + amount.to_f).round(2).to_s
    self.save!
  end

  def wallet_change(amount)
    self.wallet_value = (wallet_value.to_f + amount.to_f).round(2).to_s
    self.save!
  end

  def wallet_balance()
    return wallet_value.to_f.round(2)
  end

  def give_initial_cash
    self.wallet_value ||= "1000"
  end
end
