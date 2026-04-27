require "rails_helper"
require "rake"

RSpec.describe "fetch_all_raids:sync" do
  before(:all) do
    # load the rake task from lib/tasks
    Rake.application.rake_require("fetch_all_raids", [ "lib/tasks" ]) rescue nil
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["fetch_all_raids:sync"] }

  before do
    allow(YAML).to receive(:load_file).and_return([
      { "slug" => "existing-raid", "expansion" => "X", "raid_name" => "Existing" },
      { "slug" => "new-raid", "expansion" => "Y", "raid_name" => "New Raid" }
    ])

    # existing record
    Winner.create!(raid_slug: "existing-raid", guild_name: "OldGuild", raid_name: "Existing")

    allow(RaiderIoClient).to receive(:get_world_first).with("new-raid").and_return(
      guild_name: "NewGuild",
      kill_date: Time.parse("2026-04-02T12:00:00Z"),
      region: "US",
      raid_name: "New Raid"
    )
  end

  after do
    task.reenable
  end

  it "skips existing winners and processes new ones" do
    expect { task.invoke }.to change { Winner.where(raid_slug: "new-raid").count }.by(1)
    expect(Winner.find_by(raid_slug: "existing-raid").guild_name).to eq("OldGuild")
    expect(Winner.find_by(raid_slug: "new-raid").guild_name).to eq("NewGuild")
  end
end
