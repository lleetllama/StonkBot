class DiscoBot
  def initialize(token, prefix, hook_url)
    @bot = Discordrb::Commands::CommandBot.new(token: token, prefix: prefix)
    @hook = Discordrb::Webhooks::Client.new(url: hook_url)
    setup_commands
  end

  def run
    @bot.run
  end

  def market_table
    table = Tabulo::Table.new(
      Stonk.all,
      border: :modern,
      title: "Stonks",
      align_body: :center,
    ) do |t|
      t.add_column("Ticker") { |x| x.stonk_name }
      t.add_column("Market Value") { |x| "$" + x.get_value.to_s }
      t.add_column("Trend") { |x| x.delta }
    end
    return table
  end

  def setup_commands
    @bot.mention do |event|
      event.user.pm("Keep my name out yo fuckin mouth!")
    end

    @bot.command :help do |event, *args|
      event << "*wallet - see your money"
      event << "*market - shows stonk market"
      event << "*buy <STONK NAME> <QUANTITY> - buys units"
      event << "*sell <STONK NAME> <QUANTITY> - sells units"
      event << "*portfolio - see your stonks"
      event << "*chart <STONK NAME> - shows price history for stonk"
    end

    @bot.command :chart do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create
      stock_name = args[0]&.upcase

      if (stock_name == nil || args.length != 1)
        event << "Usage: *chart <StockName>"
      else
        stonk = Stonk.find_by(stonk_name: stock_name)

        if (stonk != nil)
          changes = stonk.stonk_changes.last(30)
          chart = changes.each_with_index.map { |x, i| ["", x.new_value.to_f] }
          event << "`"
          event << AsciiCharts::Cartesian.new(chart).draw
          event << "`"
        else
          event << "Either That Stock does not exist or your spelling sucks."
        end
      end
    end

    @bot.command(:eval, help_available: false) do |event, *code|
      if event.user.id == ENV["admin_id"].to_i # Replace number with your ID
        begin
          eval code.join(" ")
        rescue StandardError
          "An error occurred 😞"
        end
      else
        event << "Fuck off. This feature is for the cool kids only."
      end
    end

    @bot.command :market do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create

      event << "`"
      event << market_table
      event << "`"
    end

    @bot.command :portfolio do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create

      event << "Hello " + event.user.name
      event << "Account #" + user_id.to_s

      table = Tabulo::Table.new(account.discord_user_stonks, border: :modern, title: "Portfolio", align_body: :center) do |t|
        t.add_column("Stonk") { |x| x.my_stonk.stonk_name }
        t.add_column("Quantity") { |x| x.quantity.to_s }
        t.add_column("Invested") { |x| "$" + x.value_at_purchase.to_f.round(2).to_s }
        t.add_column("Cost Basis") { |x| "$" + (x.value_at_purchase.to_f.round(2) / x.quantity).round(2).to_s }
        t.add_column("Market Value") { |x| "$" + x.market_value.to_f.round(2).to_s }
      end

      event << "`"
      event << table
      event << "`"
    end

    @bot.command :flex do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create

      worth_array = account.net_worth

      event << "Assets:    $" + worth_array[0].to_s
      event << "Debt:      $" + worth_array[1].to_s
      event << "Net worth: $" + worth_array[2].to_s
    end

    @bot.command :buy do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create
      stock_name = args[0].upcase
      quantity = args[1]
      if (stock_name == nil || quantity == nil || quantity.to_s != quantity.to_i.to_s)
        event << "Usage: *buy <StockName> <QuantityToBuy>"
      else
        stonk = Stonk.find_by(stonk_name: stock_name)
        if (stonk != nil)
          transaction_cost = (stonk.get_value.to_f * quantity.to_f)
          if (transaction_cost.to_f > account.wallet_value.to_f)
            event << "You don't have that kinda cash"
          else
            transaction = DiscordUserStonk.where(discord_user_id: account.id, stonk_id: stonk.id).first_or_create
            transaction.buy_units(quantity)
            event << "You purchased " + quantity + " units of " + stock_name
          end
        else
          event << "Either That Stock does not exist or your spelling sucks."
        end
      end
    end

    @bot.command :wallet do |event|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create

      event << "Hello " + event.user.name
      event << "Account #" + user_id.to_s
      event << "Current Balance:$" + account.wallet_value.to_s
    end

    @bot.command :sell do |event, *args|
      user_id = event.user.id
      account = DiscordUser.where(id: user_id).first_or_create

      stock_name = args[0].upcase
      quantity = args[1]

      if (stock_name == nil || quantity == nil || quantity.to_s != quantity.to_i.to_s)
        event << "Usage: *sell <StockName> <QuantityToSell>"
      else
        stonk = Stonk.find_by(stonk_name: stock_name)
        if (stonk != nil)
          transaction = DiscordUserStonk.find_by(
            discord_user_id: account.id,
            stonk_id: stonk.id,
          )
          if (transaction == nil)
            event << "You don't own any units of that stock"
          else
            if (quantity.to_i > transaction.quantity)
              event << "You don't have enough units for that transaction"
            else
              offset = transaction.sell_units(quantity)
              if transaction.quantity.to_i <= 0
                transaction.delete
              end
              event << "Sold " + quantity.to_s + " units of " + stock_name
              event << "for a " + offset[2] + " of " + offset[0] + " (" + offset[1] + ")"
            end
          end
        else
          event << "Either That Stock does not exist or your spelling sucks."
        end
      end
    end
  end

  def send_market_update_hook
    @hook.execute do |builder|
      # builder.content = 'Hello world!'
      builder.add_embed do |embed|
        embed.title = "Stonk Price Update"
        embed.description = "`\n" + market_table.to_s + "`\n"
        embed.timestamp = Time.now
      end
    end
  end
end
