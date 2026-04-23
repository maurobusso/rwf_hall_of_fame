class CreateWinners < ActiveRecord::Migration[8.1]
  def change
    create_table :winners do |t|
      t.string :raid_slug
      t.string :guild_name
      t.string :raid_name
      t.string :expansion_name
      t.datetime :kill_date
      t.string :region

      t.timestamps
    end
  end
end
