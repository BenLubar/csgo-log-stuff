class Bot < ActiveRecord::Base
  has_many :games, class_name: 'Player'
  has_many :matches, through: :games
end
