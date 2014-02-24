class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.order(start: :desc)
    workshop_ids = []
    @matches.find_each do |m|
      workshop_ids << m.map.workshop_id
    end
    workshop_ids.uniq!
    @workshop = WorkshopCache.item *workshop_ids
    @title = 'Matches'
    @page_class = 'matches'
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @title = "Match #{@match.id}: #{@match.map.name}"
    @page_class = "matches-#{@match.id}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end
end
