class CreateAttrConflicts < ActiveRecord::Migration
  def change
    create_table :attr_conflicts do |t|
      t.references :attack, index: true
      t.references :defence, index: true
      t.integer :result

      t.timestamps
    end
  end
end
