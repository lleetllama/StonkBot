class DiscordUserStonk < ActiveRecord::Base
  belongs_to :stonk
  belongs_to :discord_user

  def owner
    return DiscordUser.find(self.discord_user_id)
  end

  def my_stonk
    return Stonk.find(self.stonk_id)
  end

  def market_value
    return self.my_stonk.get_value.to_f * self.quantity
  end

  def buy_units(count)
    self.quantity = (self.quantity.to_i + count.to_i).to_s
    cost = self.my_stonk.get_value.to_f * count.to_i
    self.owner.wallet_change(-cost.to_f)
    self.value_at_purchase = (self.value_at_purchase.to_f + cost.to_f).to_s
    self.save
  end

  def sell_units(quantity)
    count = [quantity.to_i, self.quantity.to_i].min
    self.quantity = self.quantity - count

    payout = self.my_stonk.get_value.to_f * count
    profit =  (self.my_stonk.get_value.to_f - self.value_at_purchase.to_f) * count
    profit_percent = (((payout / (self.value_at_purchase.to_f * quantity.to_f)) - 1) * 100).round(2)

    result = if profit_percent >= 0
        "for a GAIN of "
      elsif profit_percent = 0
        "to BREAK EVEN at "
      else
        "for a LOSS of "
      end

    self.owner.wallet_change(payout)
    self.value_at_purchase = (self.value_at_purchase.to_f - payout).to_s
    self.save



    return ["$" + profit.to_s, profit_percent.to_s + "%", result]
  end
end
