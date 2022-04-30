class Stonk < ActiveRecord::Base
  has_many :stonk_changes

  def tick
    old = self.get_value

    stonk_change = StonkChange.create(
      stonk_id: self.id,
      old_value: old.to_f.round(2).to_s,
    )

    rnd = if old <= 40
        rand(-0.02...0.04)
      else
        rand(-0.03...0.03)
      end

    change_percent = self.volatility.to_f * rnd

    change_amount = old.to_f * change_percent
    new_value = old.to_f + change_amount

    if (new_value <= 30)
      new_value = rand(35..40)
    end

    stonk_change.new_value = new_value.to_f.round(2).to_s

    stonk_change.save!
  end

  def delta
    last_change = StonkChange.where(stonk_id: self.id).last

    if (last_change == nil)
      return "-"
    else
      return (last_change.new_value.to_f - last_change.old_value.to_f).to_f.round(2).to_s
    end
  end

  def get_value
    last_change = StonkChange.where(stonk_id: self.id).last

    if (last_change == nil)
      return self.base_value.to_f.round(2)
    else
      return last_change.new_value.to_f.round(2)
    end
  end
end
