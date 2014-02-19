class Match < ActiveRecord::Base
  default_scope -> { preload(:map, :rounds, :team_1, :team_2, :t1_t_rounds, :t1_ct_rounds, :t2_t_rounds, :t2_ct_rounds) }

  belongs_to :map
  has_many :rounds
  has_many :players

  has_many :team_1, -> { where(first_team: true).includes(:bot) }, class_name: 'Player'
  has_many :team_2, -> { where(first_team: false).includes(:bot) }, class_name: 'Player'

  has_many :t1_t_rounds, -> { where(round: 1..15, t_wins: 1) }, class_name: 'Round'
  has_many :t1_ct_rounds, -> { where(round: 16..30, ct_wins: 1) }, class_name: 'Round'
  has_many :t2_t_rounds, -> { where(round: 16..30, t_wins: 1) }, class_name: 'Round'
  has_many :t2_ct_rounds, -> { where(round: 1..15, ct_wins: 1) }, class_name: 'Round'

  def t1_scores
    [t1_t_rounds.count, t1_ct_rounds.count]
  end

  def t2_scores
    [t2_ct_rounds.count, t2_t_rounds.count]
  end

  def t_scores
    [t1_t_rounds.count, t2_t_rounds.count]
  end

  def ct_scores
    [t2_ct_rounds.count, t1_ct_rounds.count]
  end
end
