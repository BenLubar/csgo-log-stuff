json.array!(@bots) do |bot|
  json.extract! bot, :id
  json.url bot_url(bot, format: :json)
end
