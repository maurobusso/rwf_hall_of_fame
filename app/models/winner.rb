class Winner < ApplicationRecord
  validates :raid_slug, :guild_name, :raid_name, presence: true
end
