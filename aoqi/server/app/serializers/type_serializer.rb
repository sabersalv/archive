class TypeSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :name2
  has_many :heroes
end
