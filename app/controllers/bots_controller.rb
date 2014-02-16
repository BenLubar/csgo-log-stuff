class BotsController < ApplicationController
  before_action :set_bot, only: [:show]

  # GET /bots
  # GET /bots.json
  def index
    @bots = Bot.all
  end

  # GET /bots/1
  # GET /bots/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bot
      @bot = Bot.find(params[:id])
    end
end
