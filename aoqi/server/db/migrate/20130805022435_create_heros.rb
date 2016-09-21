class CreateHeros < ActiveRecord::Migration
  def change
    create_table :heros do |t|
      t.string :name
      t.string :name2
      t.text :skill1
      t.text :skill2
      t.text :skill3
      t.integer :damage_sum
      t.integer :hp
      t.integer :speed
      t.integer :normal_damage
      t.integer :magical_damage
      t.integer :super_damage
      t.integer :normal_armor
      t.integer :magical_armor
      t.integer :super_armor
      t.references :type, index: true
      t.references :attr, index: true

      t.timestamps
    end

    add_index :heros, :name 
  end
end
