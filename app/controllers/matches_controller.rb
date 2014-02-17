class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.order(start: :desc)
    @title = 'Matches'
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @title = "Match #{@match.id}: #{@match.map.name}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end
end
