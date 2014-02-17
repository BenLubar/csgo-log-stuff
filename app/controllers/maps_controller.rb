class MapsController < ApplicationController
  before_action :set_map, only: [:show]

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.order(name: :asc)
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end
end
