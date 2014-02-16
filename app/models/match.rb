class Match < ActiveRecord::Base
  has_many :rounds
  has_many :players

  def team_1
    players.where first_team: true
  end

  def team_2
    players.where first_team: false
  end

  def t1_scores
    [
      rounds.where(round: 1..15).pluck(:t_wins).inject(0, :+),
      rounds.where(round: 16..30).pluck(:ct_wins).inject(0, :+)
    ]
  end

  def t2_scores
    [
      rounds.where(round: 1..15).pluck(:ct_wins).inject(0, :+),
      rounds.where(round: 16..30).pluck(:t_wins).inject(0, :+)
    ]
  end

  def t_scores
    [
      rounds.where(round: 1..15).pluck(:t_wins).inject(0, :+),
      rounds.where(round: 16..30).pluck(:t_wins).inject(0, :+)
    ]
  end

  def ct_scores
    [
      rounds.where(round: 1..15).pluck(:ct_wins).inject(0, :+),
      rounds.where(round: 16..30).pluck(:ct_wins).inject(0, :+)
    ]
  end
end
