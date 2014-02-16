class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.datetime :start, null: false
      t.datetime :end, null: false
      t.references :match, index: true
      t.integer :round, null: false
      t.integer :t_wins, null: false, default: 0
      t.integer :ct_wins, null: false, default: 0
      t.integer :all_ct_killed, null: false, default: 0
      t.integer :all_t_killed, null: false, default: 0
      t.integer :hostage_reached, null: false, default: 0
      t.integer :hostage_rescued, null: false, default: 0
      t.integer :bomb_planted, null: false, default: 0
      t.integer :bomb_detonated, null: false, default: 0
      t.integer :bomb_defused, null: false, default: 0
      t.integer :time_ran_out, null: false, default: 0

      t.timestamps
    end
    add_index :rounds, [:match_id, :round], unique: true
  end
end
