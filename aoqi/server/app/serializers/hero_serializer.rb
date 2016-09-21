class HeroSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :name2, :skill1, :skill2, :skill3, 
    :hp, :speed, :damage_sum, :normal_damage, :magical_damage, :super_damage, 
    :normal_armor, :magical_armor, :super_armor
  has_one :type
  has_one :attr
end
