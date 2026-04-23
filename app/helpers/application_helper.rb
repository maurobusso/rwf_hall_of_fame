module ApplicationHelper
  def abbreviate_expansion(expansion_name)
    case expansion_name
    when "World of Warcraft"
      "WoW"
    when "The Burning Crusade"
      "TBC"
    when "Wrath of the Lich King"
      "WotLK"
    when "Cataclysm"
      "Cata"
    when "Mists of Pandaria"
      "MoP"
    when "Warlords of Draenor"
      "WoD"
    when "Legion"
      "Legion"
    when "Battle for Azeroth"
      "BFA"
    when "Shadowlands"
      "SL"
    when "Dragonflight"
      "DF"
    when "The War Within"
      "TWW"
    when "Midnight"
      "Midnight"
    else
      expansion_name # fallback
    end
  end
end
