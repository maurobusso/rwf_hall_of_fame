historical_kills = [
  # --- VANILLA ---
  { expansion_name: "World of Warcraft", raid_slug: "molten-core", raid_name: "Molten Core", guild_name: "Ascent", region: "US", kill_date: "2005-04-25" },
  { expansion_name: "World of Warcraft", raid_slug: "onyxias-lair", raid_name: "Onyxia's Lair", guild_name: "Ruined", region: "US", kill_date: "2005-01-30" },
  { expansion_name: "World of Warcraft", raid_slug: "blackwing-lair", raid_name: "Blackwing Lair", guild_name: "Drama", region: "US", kill_date: "2005-09-27" },
  { expansion_name: "World of Warcraft", raid_slug: "temple-of-ahnqiraj", raid_name: "Ahn'Qiraj", guild_name: "Nihilum", region: "EU", kill_date: "2006-04-25" },
  { expansion_name: "World of Warcraft", raid_slug: "naxxramas", raid_name: "Naxxramas", guild_name: "Nihilum", region: "EU", kill_date: "2006-09-07" },

  # --- BURNING CRUSADE ---
  { expansion_name: "The Burning Crusade", raid_slug: "gruuls-lair", raid_name: "Gruul's Lair", guild_name: "Nihilum", region: "EU", kill_date: "2007-02-08" },
  { expansion_name: "The Burning Crusade", raid_slug: "magtheridons-lair", raid_name: "Magtheridon's Lair", guild_name: "Nihilum", region: "EU", kill_date: "2007-02-24" },
  { expansion_name: "The Burning Crusade", raid_slug: "serpentshrine-cavern", raid_name: "Serpentshrine Cavern", guild_name: "Nihilum", region: "EU", kill_date: "2007-03-29" },
  { expansion_name: "The Burning Crusade", raid_slug: "the-eye", raid_name: "Tempest Keep", guild_name: "Nihilum", region: "EU", kill_date: "2007-05-25" },
  { expansion_name: "The Burning Crusade", raid_slug: "black-temple", raid_name: "Black Temple", guild_name: "Nihilum", region: "EU", kill_date: "2007-06-05" },
  { expansion_name: "The Burning Crusade", raid_slug: "sunwell-plateau", raid_name: "Sunwell Plateau", guild_name: "SK Gaming", region: "EU", kill_date: "2008-05-25" },

  # --- WRATH OF THE LICH KING ---
  { expansion_name: "Wrath of the Lich King", raid_slug: "ulduar-algalon", raid_name: "Ulduar (Algalon)", guild_name: "Ensidia", region: "EU", kill_date: "2009-06-03" },
  { expansion_name: "Wrath of the Lich King", raid_slug: "ulduar-yogg0", raid_name: "Ulduar (Yogg-0)", guild_name: "Stars", region: "TW", kill_date: "2009-07-07" },
  { expansion_name: "Wrath of the Lich King", raid_slug: "trial-of-the-grand-crusader", raid_name: "Trial of the Grand Crusader", guild_name: "Anarchy", region: "EU", kill_date: "2009-09-07" },
  { expansion_name: "Wrath of the Lich King", raid_slug: "icecrown-citadel", raid_name: "Icecrown Citadel", guild_name: "Paragon", region: "EU", kill_date: "2010-03-26" },
  { expansion_name: "Wrath of the Lich King", raid_slug: "ruby-sanctum", raid_name: "Ruby Sanctum", guild_name: "For the Horde", region: "EU", kill_date: "2010-07-01" },

  # --- CATACLYSM ---
  { expansion_name: "Cataclysm", raid_slug: "blackwing-descent", raid_name: "Tier 11 (BWD/BoT)", guild_name: "Paragon", region: "EU", kill_date: "2011-01-20" },
  { expansion_name: "Cataclysm", raid_slug: "firelands", raid_name: "Firelands", guild_name: "Paragon", region: "EU", kill_date: "2011-07-19" },
  { expansion_name: "Cataclysm", raid_slug: "dragon-soul", raid_name: "Dragon Soul", guild_name: "KIN Raiders", region: "KR", kill_date: "2011-12-20" },

  # --- MISTS OF PANDARIA ---
  { expansion_name: "Mists of Pandaria", raid_slug: "throne-of-thunder", raid_name: "Throne of Thunder", guild_name: "Method", region: "EU", kill_date: "2013-04-11" },
  { expansion_name: "Mists of Pandaria", raid_slug: "siege-of-orgrimmar", raid_name: "Siege of Orgrimmar", guild_name: "Method", region: "EU", kill_date: "2013-09-30" },

  # --- WARLORDS OF DRAENOR ---
  { expansion_name: "Warlords of Draenor", raid_slug: "highmaul", raid_name: "Highmaul", guild_name: "Paragon", region: "EU", kill_date: "2014-12-13" },
  { expansion_name: "Warlords of Draenor", raid_slug: "blackrock-foundry", raid_name: "Blackrock Foundry", guild_name: "Method", region: "EU", kill_date: "2015-02-20" },
  { expansion_name: "Warlords of Draenor", raid_slug: "hellfire-citadel", raid_name: "Hellfire Citadel", guild_name: "Method", region: "EU", kill_date: "2015-07-16" }
]

puts "Creating historical Hall of Fame..."

count = 0

historical_kills.each do |data|
  # We now find/create by the slug to avoid duplicates
  Winner.find_or_create_by!(raid_slug: data[:raid_slug]) do |w|
    w.raid_name = data[:raid_name]
    w.expansion_name = data[:expansion_name]
    w.guild_name = data[:guild_name]
    w.region = data[:region]
    w.kill_date = Date.parse(data[:kill_date])
    # Automatically setting banner url based on the slug
    # w.banner_url = "https://cdn.raider.io/images/raids/#{data[:raid_slug]}.jpg"
  end
  count += 1
end

puts "Success: #{count} legends added."
