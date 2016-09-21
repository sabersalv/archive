class AttrsController < ApplicationController
  def index
    attr = Attr.includes(:heroes)
    @attrs = params["ids"] ? attr.where(ids: params["ids"]) : attr
    render json: @attrs
  end

  def show
    @attr = Attr.find(params[:id])
    render json: @attr
  end
end
