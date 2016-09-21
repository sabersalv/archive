class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.string :name
      t.string :name2

      t.timestamps
    end

    add_index :types, :name 
  end
end
