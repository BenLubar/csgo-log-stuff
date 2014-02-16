class Player < ActiveRecord::Base
  belongs_to :match
  belongs_to :bot
end
