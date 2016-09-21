class Attr < ActiveRecord::Base
  has_many :heroes

  def attack_add_ids
    @attack_add ||= AttrConflict.where(attack_id: id, result: 1).map{|v| v.defence_id}
  end

  def attack_reduce_ids
    @attack_reduce ||= AttrConflict.where(attack_id: id, result: -1).map{|v| v.defence_id}
  end

  def defence_add_ids
    @defence_add ||= AttrConflict.where(defence_id: id, result: 1).map{|v| v.attack_id}
  end

  def defence_reduce_ids
    @defence_reduce ||= AttrConflict.where(defence_id: id, result: -1).map{|v| v.attack_id}
  end
end
