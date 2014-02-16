class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :name

      t.timestamps
    end
  end
end
