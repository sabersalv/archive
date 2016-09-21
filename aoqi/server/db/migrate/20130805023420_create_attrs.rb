class CreateAttrs < ActiveRecord::Migration
  def change
    create_table :attrs do |t|
      t.string :name
      t.string :name2

      t.timestamps
    end

    add_index :attrs, :name
  end
end
