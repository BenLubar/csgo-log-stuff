class CreateWorkshopCaches < ActiveRecord::Migration
  def change
    create_table :workshop_caches do |t|
      t.string :fileid
      t.text :data

      t.timestamps
    end
    add_index :workshop_caches, :fileid, unique: true
  end
end
