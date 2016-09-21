[ # Type
  [ "tank", "肉盾" ],
  [ "balance", "平衡" ],
  [ "magic", "魔法" ],
  [ "shooter", "射击" ],
  [ "claw", "利爪" ],
  [ "healer", "治疗" ],
].each.with_index(1) { |(name, name2),i|
  r = Type.new(name: name, name2: name2)
  r.id = i
  r.save!
}

[ # Attr
  [ "dark", "暗" ],
  [ "fire", "火" ],
  [ "machine", "机械" ],
  [ "water", "水" ],
  [ "soil", "土" ],
  [ "dargon", "龙" ],
].each.with_index(1) { |(name, name2),i|
  r = Attr.new(name: name, name2: name2)
  r.id = i
  r.save!
}

i = 1
[ # AttrConflict
  [ "machine", %w[soil ], 1],
  [ "machine", %w[water dark ], -1],
  [ "dark", %w[machine fire water ], 1 ], 
  [ "fire", %w[machine dark ], 1 ],
  [ "fire", %w[soil water], -1 ],
  [ "soil", %w[water ], 1],
  [ "soil", %w[machine ], -1],
  [ "water", %w[fire ], 1],
  [ "water", %w[machine soil], -1],
  [ "dargon", %w[dark], 1 ],
].each { |attack, defences, result|
  defences.each { |defence|
    r = AttrConflict.new(attack: Attr.find_by_name(attack), defence: Attr.find_by_name(defence), result: result)
    r.id = i
    r.save!
    i += 1
  }
}

[ # Hero
  %w[ dlmm 哆啦梦梦 机械 肉盾	]    + [ 3501, 4024, 2824, 2930, 2123,  8832, 8232, 8876, 251 ],
  %w[ ahmm 暗黑梦梦 暗 魔法	]      + [ 3501, 2744,  744, 7180, 3223, 13872, 2232, 5516, 245 ],
  %w[ rxmm 热血梦梦 火 利爪	]      + [ 3501, 5624,  744, 2930, 1023, 13872, 2232, 6716, 299 ],
  %w[ ljmm 炼金梦梦 土 平衡	]      + [ 3501, 5048, 2184, 2930, 2343, 10992, 6552, 7436, 256 ],
  %w[ axmm 爱心梦梦	水 治疗	]      + [ 3501, 2744, 1944, 5910, 3223, 12912, 5832, 6356, 227 ],
  %w[ hjsl 黄金圣龙 龙 肉盾 ]      + [ 3601, 3896, 3144, 2930, 3553,  9876, 9132, 9716, 247 ] + 	
].each.with_index(1) { |(name, name2, attr, type, damage_sum, normal_damage, normal_armor, magical_damage, magical_armor, super_damage, super_armor, hp, speed),i|
  r = Hero.new(name: name, name2: name2, attr: Attr.find_by_name2!(attr), type_id: Type.find_by_name2!(type).id, damage_sum: damage_sum, normal_damage: normal_damage, normal_armor: normal_armor, magical_damage: magical_damage, magical_armor: magical_armor, super_damage: super_damage, super_armor: super_armor, hp: hp, speed: speed )
  r.id = i
  r.save!
}
