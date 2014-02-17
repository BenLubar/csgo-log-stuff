class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
    add_index :maps, :name
  end
end
