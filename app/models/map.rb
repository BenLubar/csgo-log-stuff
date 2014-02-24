class Map < ActiveRecord::Base
  has_many :matches
  has_many :rounds, through: :matches

  def workshop_id
    path[/\Aworkshop\/([0-9]+)\//, 1]
  end

  def workshop
    WorkshopCache.item(workshop_id)[workshop_id] if workshop_id
  end
end
