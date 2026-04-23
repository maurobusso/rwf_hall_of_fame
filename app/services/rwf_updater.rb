require "httparty"

class RwfUpdater
  def self.fetch_winner(raid_slug)
    data = RaiderIoClient.get_world_first(raid_slug)
    return nil unless data

    # Ensure required fields are present
    raid_name = data[:raid_name] || raid_slug

    winner = Winner.find_or_initialize_by(raid_slug: raid_slug)
    winner.raid_name = raid_name
    winner.guild_name = data[:guild_name]
    winner.kill_date = data[:kill_date]
    winner.region = data[:region]
    winner.save!

    winner
  end
end
