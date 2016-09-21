class AttrSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :name2, :attack_add_ids, :attack_reduce_ids, :defence_reduce_ids, :defence_add_ids
  has_many :heroes
end
