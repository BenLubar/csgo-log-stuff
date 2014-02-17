class BotsController < ApplicationController
  before_action :set_bot, only: [:show]

  # GET /bots
  # GET /bots.json
  def index
    @bots = Bot.order(name: :asc)
    @title = 'Bots'
  end

  # GET /bots/1
  # GET /bots/1.json
  def show
    @title = "#{@bot.name} | Bots"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bot
      @bot = Bot.find(params[:id])
    end
end
