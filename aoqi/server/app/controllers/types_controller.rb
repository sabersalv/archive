class TypesController < ApplicationController
  def index
    type = Type.includes(:heroes)
    @types = params["ids"] ? type.where(ids: params["ids"]) : type
    render json: @types
  end

  def show
    @type = Type.find(params[:id])
    render json: @type
  end
end
