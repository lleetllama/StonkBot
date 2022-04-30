require "discordrb"
require "active_record"
require "ascii_charts"
require "tabulo"
require "pry"
require "ascii_charts"
require "discordrb/webhooks"

require_relative "models/stonk"
require_relative "models/stonk_change"
require_relative "models/discord_user"
require_relative "models/discord_user_stonk"
require_relative "models/disco_bot"
require_relative "./lib/DatabaseManager"

if (ENV["development_phase"] != "production")
  require_relative "env_variables"
end

if (ENV["development_phase"] == "production")
  require "pg"

  ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :host => ENV["database_url"],
    :database => ENV["database_user"],
    :username => ENV["database_user"],
    :password => ENV["database_pass"],
  )
else
  require "sqlite3"

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/development.sqlite3",
  )
end

# run migrations without rails
ActiveRecord::Base.connection
ActiveRecord::MigrationContext.new("./migrate/", ActiveRecord::SchemaMigration).migrate

@bot = DiscoBot.new(ENV["bot_token"], "*", ENV["hook_url"])

def create_new_stonk(name, value)
  new_id = Stonk.last.id + 1
  Stonk.create(
    id: new_id,
    stonk_name: name.to_s,
    base_value: value.to_s,
    volatility: "3",
  )
end

# spawn a thread worker to "tick" the stonks
ticker_thread = Thread.new {
  loop do
    puts "ticking stonks @" + Time.now.to_s
    Stonk.all.map { |x| x.tick }
    @bot.send_market_update_hook
    sleep(600)
  end
}

@bot.run
