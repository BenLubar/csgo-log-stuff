class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :start, null: false
      t.references :map, index: true

      t.timestamps
    end
  end
end
