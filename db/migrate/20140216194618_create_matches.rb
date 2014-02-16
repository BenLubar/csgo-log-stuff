class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :start, null: false
      t.string :map, null: false
      t.string :t1p1
      t.string :t1p2
      t.string :t1p3
      t.string :t1p4
      t.string :t1p5
      t.string :t2p1
      t.string :t2p2
      t.string :t2p3
      t.string :t2p4
      t.string :t2p5

      t.timestamps
    end
    add_index :matches, :map
  end
end
