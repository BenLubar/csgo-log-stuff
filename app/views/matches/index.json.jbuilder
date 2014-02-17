json.array!(@matches) do |match|
  json.extract! match, :id
  json.score1 match.t1_scores
  json.score2 match.t2_scores
  json.players(match.players) do |player|
    json.extract! player.bot, :id, :name
    json.team 1 if player.first_team
    json.team 2 unless player.first_team
  end
  json.map match.map.path
  json.url match_url(match, format: :json)
end
