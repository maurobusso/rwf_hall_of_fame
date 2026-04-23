require "httparty"

class RaiderIoClient
  include HTTParty
  base_uri "https://raider.io/api/v1"

  # Fetches the winner from the Hall of Fame
  def self.get_world_first(raid_slug)
    # Note: Modern raids use 'mythic', older ones might need 'heroic' or 'normal'
    # but the API usually maps the 'highest' available to the query.
    response = get("/raiding/hall-of-fame", query: { raid: raid_slug, difficulty: "mythic", region: "world" })
    return nil unless response.success?

    final_boss = response.parsed_response.dig("hallOfFame", "bossKills")&.last
    return nil unless final_boss

    winner_data = final_boss.dig("defeatedBy", "guilds")&.first
    return nil unless winner_data

    {
      guild_name: winner_data.dig("guild", "name"),
      kill_date:  winner_data["defeatedAt"],
      region:     winner_data.dig("guild", "region", "short_name"),
      raid_name:  response.parsed_response.dig("hallOfFame", "raid", "name")
      # banner_url: "https://cdn.raider.io/images/raids/#{raid_slug}.jpg"
    }
  end
end
