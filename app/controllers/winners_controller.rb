class WinnersController < ApplicationController
  def index
    @winners = Winner.order(kill_date: :desc)
    @history = @winners

    # Group by expansion, then sort those groups by the earliest kill_date in each group
    @expansions = @history.group_by(&:expansion_name)
                          .sort_by { |_, winners| winners.map(&:kill_date).min }
                          .map(&:first)
                          .compact
  end
end
