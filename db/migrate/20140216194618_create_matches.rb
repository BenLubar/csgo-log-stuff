class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :start, null: false
      t.string :map, null: false

      t.timestamps
    end
    add_index :matches, :map
  end
end
