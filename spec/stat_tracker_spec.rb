require './spec/spec_helper'


RSpec.describe 'StatTracker' do
  before(:each) do
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.from_csv(locations)
  end

  describe '#initialize' do
    it 'exists' do
      expect(@stat_tracker).to be_an_instance_of(StatTracker)
    end
    it 'can generate arrays of objects from CSVs' do
      expect(@stat_tracker.games.first).to be_a(Game)
      expect(@stat_tracker.teams.first).to be_a(Team)
      expect(@stat_tracker.game_teams.first).to be_a(GameTeam)
      expect(@stat_tracker.games).to include(an_object_having_attributes(game_id: "2012030221"))
    end
  end

  describe '#highest_total_score' do
    it 'can generate the highest total game score' do
      expect(@stat_tracker.highest_total_score).to eq(11)
    end
  end

  describe '#lowest_total_score' do
    it 'can generate the lowest total game score' do
      expect(@stat_tracker.lowest_total_score).to eq 0
    end
  end

  describe '#count_of_games_by_season' do
    it 'return a hash of total games by season' do
      expected = {
        "20122013"=>806,
        "20162017"=>1317,
        "20142015"=>1319,
        "20152016"=>1321,
        "20132014"=>1323,
        "20172018"=>1355
      }
      expect(@stat_tracker.count_of_games_by_season).to eq expected
    end
  end
end