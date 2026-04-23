require "rails_helper"

RSpec.describe RwfUpdater, type: :service do
  describe ".fetch_winner" do
    let(:slug) { "nerubar-palace" }

    before do
      allow(RaiderIoClient).to receive(:get_world_first).with(slug).and_return(
        guild_name: "TestGuild",
        kill_date: Time.parse("2026-04-01T12:00:00Z"),
        region: "EU",
        raid_name: "Nerub'ar Palace"
      )
    end

    it "creates a Winner with expected attributes" do
      expect { RwfUpdater.fetch_winner(slug) }.to change { Winner.where(raid_slug: slug).count }.by(1)

      winner = Winner.find_by(raid_slug: slug)
      expect(winner.raid_name).to eq("Nerub'ar Palace")
      expect(winner.guild_name).to eq("TestGuild")
      expect(winner.region).to eq("EU")
    end
  end
end
