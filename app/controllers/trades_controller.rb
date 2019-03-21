class TradesController < ApplicationController
  def trade
    @survivor1 = Survivor.find(trade_params[:survivor1][:id])
    @survivor2 = Survivor.find(trade_params[:survivor2][:id])

    trade = Trade.new(@survivor1, @survivor2,
      trade_params[:survivor1][:resources],
      trade_params[:survivor2][:resources]
    )
    trade.process

    if trade.valid
      render json: { message: trade.message }, status: :ok
    else
      render json: { error: trade.message }, status: trade.status
    end
  end

  private

  def trade_params
    params.require(:trade).permit(survivor1: [:id, resources: [:type, :amount]],
      survivor2: [:id, resources: [:type, :amount]]
    )
  end
end
