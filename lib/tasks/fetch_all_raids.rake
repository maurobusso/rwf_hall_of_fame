namespace :fetch_all_raids do
  desc "Fetch world first data from Raider.io based on manifest"
  task sync: :environment do
    manifest_path = Rails.root.join("db", "raids_manifest.yml")
    raids = YAML.load_file(manifest_path)

    puts "--- Starting Fetching Raid Data ---"

    raids.each do |entry|
      slug = entry["slug"]
      expansion = entry["expansion"]
      raid_name = entry["raid_name"]

      if Winner.exists?(raid_slug: slug)
        puts "⏭️  Skipping #{slug}... already exists"
        next
      end

      print "Fetching #{slug}... "

      data = RaiderIoClient.get_world_first(slug)

      if data
        # find_or_initialize lets us update records if they already exist
        winner = Winner.find_or_initialize_by(raid_slug: slug)

        winner.update!(
          expansion_name: expansion,
          raid_slug:      slug,
          raid_name:      raid_name,
          guild_name:     data[:guild_name],
          region:         data[:region],
          kill_date:      data[:kill_date]
        )
        puts "✅ Saved: #{data[:guild_name]}!"
      else
        puts "❌ No data found (likely pre-API era or incorrect slug)."
      end
    end

    puts "--- Sync Complete! Total: #{Winner.count} records ---"
  end
end
