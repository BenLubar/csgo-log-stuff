class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.boolean :first_team
      t.references :match, index: true
      t.references :bot, index: true

      t.timestamps
    end
  end
end
