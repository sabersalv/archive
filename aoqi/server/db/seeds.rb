[ # Hero
  # %w[ hjsl 黄金圣龙 龙 肉盾 ]      + [ 3351, 3896, 3144, 2930, 3553,  9876, 9132, 9716, 247 ] 
].each { |name, name2, attr, type, damage_sum, normal_damage, normal_armor, magical_damage, magical_armor, super_damage, super_armor, hp, speed|
  puts "#{name2} #{attr} #{type}"
  Hero.create!(name: name, name2: name2, attr: Attr.find_by_name2!(attr), type_id: Type.find_by_name2!(type).id, damage_sum: damage_sum, normal_damage: normal_damage, normal_armor: normal_armor, magical_damage: magical_damage, magical_armor: magical_armor, super_damage: super_damage, super_armor: super_armor, hp: hp, speed: speed )
}
