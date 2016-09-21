class HeroesController < ApplicationController
  def index
    hero = Hero.includes(:type, :attr)
    @heroes = if params["ids"] 
                hero.where(id: params["ids"])  
              elsif params["query"]
                hero.where(params["query"])
              else
                hero
              end

    if params["sort"]
      @heroes = @heroes.order(params["sort"])
    end


    render json: @heroes
  end

  def maximum
    data = {}
    keys = [:hp, :speed, :normal_damage, :normal_armor, :magical_damage, :magical_armor, :super_damage, :super_armor] 
    keys.each { |k|
      data[:all] ||= {}
      data[:all][k] = Hero.maximum(k)

      Hero.includes(:type).select("type_id, max(#{k}) as max").group(:type_id).each{ |r|
        data[r.type.name] ||= {}
        data[r.type.name][k] = r.max
      }
=begin
      Hero.includes(:attr).select("attr_id, max(#{k}) as max").group(:attr_id).each{ |r|
        data[r.attr.name] ||= {}
        data[r.attr.name][k] = r.max
      }
=end
    }

    render json: data
  end

  def show
    @hero = Hero.find(params["id"])
    render json: @hero
  end
end
