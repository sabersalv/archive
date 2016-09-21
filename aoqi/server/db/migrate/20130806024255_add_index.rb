class AddIndex < ActiveRecord::Migration
  def change
    add_index :heros, :name2
    add_index :types, :name2
    add_index :attrs, :name2
  end
end
