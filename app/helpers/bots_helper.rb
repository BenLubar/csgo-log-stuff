module BotsHelper
  def bot_path bot
    "/csgo/bots/#{bot.name}"
  end
end
