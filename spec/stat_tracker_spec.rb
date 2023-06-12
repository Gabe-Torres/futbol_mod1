require './spec/spec_helper'


RSpec.describe 'StatTracker' do
  before(:each) do
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    @locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.from_csv(@locations)
  end

  describe '#initialize' do
    it 'exists' do
      expect(StatTracker.from_csv(@locations)).to be_a(StatTracker)
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


  describe '#percentage_home_wins' do 
    it "can get percentages of home wins" do
      expect(@stat_tracker.percentage_home_wins).to eq 0.44
    end
  end

  describe '#percentage_visitor_wins' do 
    it "can get percentages of visitor wins" do
      expect(@stat_tracker.percentage_visitor_wins).to eq 0.36
    end
  end

  describe '#percentage_ties' do
    it "can get percentages of ties" do
      expect(@stat_tracker.percentage_ties).to eq 0.20
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

  describe '#average_goals_per_game' do
    it 'can generate an average' do
      expect(@stat_tracker.average_goals_per_game).to eq 4.22
    end
  end


  describe '#average_' do
    it "#average_goals_by_season" do
      expected = {
        "20122013"=>4.12,
        "20162017"=>4.23,
        "20142015"=>4.14,
        "20152016"=>4.16,
        "20132014"=>4.19,
        "20172018"=>4.44
      }
      expect(@stat_tracker.average_goals_by_season).to eq expected
    end
  end
  
  describe '#count_of_teams' do
    it 'can count the total number of teams in the league' do
      expect(@stat_tracker.count_of_teams).to eq 32
    end
  end


  describe '#highest_scoring_visitor' do
    it 'can return highest scoring visitor team' do
      expect(@stat_tracker.highest_scoring_visitor).to eq "FC Dallas"
    end
  end

  describe '#highest_scoring_home_team' do
    it "returns Team Name with highest home scores" do
      expect(@stat_tracker.highest_scoring_home_team).to eq "Reign FC"
    end
  end

  describe '#lowest_scoring_visitor' do
    it "returns Team Name with highest home scores" do
      expect(@stat_tracker.lowest_scoring_visitor).to eq "San Jose Earthquakes"
    end
  end

  describe '#lowest_scoring_home_team' do
    it "returns the name of the lowest scoring home team" do
      expect(@stat_tracker.lowest_scoring_home_team).to eq "Utah Royals FC"
    end
  end

  describe '#best_offense' do
    it "can return the name of the team with the highest average number of goals" do
      expect(@stat_tracker.best_offense).to eq "Reign FC"
    end
  end

  describe '#worst_offense' do
    it "can return the name of the team with the highest average number of goals" do
      expect(@stat_tracker.worst_offense).to eq "Utah Royals FC"
    end
  end

  describe '#most_tackles' do
    it 'can return the team each season with the most tackles' do
      expect(@stat_tracker.most_tackles("20132014")).to eq "FC Cincinnati"
      expect(@stat_tracker.most_tackles("20142015")).to eq "Seattle Sounders FC"
    end
  end

  describe '#fewest_tackles' do
    it 'can return the team each season with the fewest tackles' do
      expect(@stat_tracker.fewest_tackles("20132014")).to eq "Atlanta United"
      expect(@stat_tracker.fewest_tackles("20142015")).to eq "Orlando City SC"
      end
  end

  describe "#winningest_coach" do
    it "can return the name of the most winning coach" do
      expect(@stat_tracker.winningest_coach("20132014")).to eq "Claude Julien"
      expect(@stat_tracker.winningest_coach("20142015")).to eq "Alain Vigneault"
    end
  end

  describe "#worst_coach" do
    it "can return the name of the coach with the worst record" do
      expect(@stat_tracker.worst_coach("20132014")).to eq "Peter Laviolette"
      expect(@stat_tracker.worst_coach("20142015")).to eq("Craig MacTavish").or(eq("Ted Nolan"))
    end
  end
end