class Map < ActiveRecord::Base
  has_many :matches
  has_many :rounds, through: :matches

  def workshop
    workshop_id = path[/workshop\/([0-9]+)\//, 1]
    WorkshopCache.item(workshop_id)[workshop_id] if workshop_id
  end
end
