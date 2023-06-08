require "csv"

class StatTracker
  attr_reader :games,
              :teams,
              :game_teams

  def initialize
    @games = []
    @teams = []
    @game_teams =[]
  end

  def self.from_csv(locations)
    stat_tracker = StatTracker.new
    
    stat_tracker.game_generator(locations)
    stat_tracker.teams_generator(locations)
    stat_tracker.game_teams_generator(locations)
    return stat_tracker
  end
  
  # helper methods
  
  def game_generator(locations)
    CSV.foreach locations[:games], headers: true, header_converters: :symbol do |row|
      @games << Game.new(row[:game_id], row[:season], row[:type], row[:date_time], row[:away_team_id], row[:home_team_id], row[:away_goals], row[:home_goals], row[:venue])
    end
  end
  
  def teams_generator(locations)
    CSV.foreach locations[:teams], headers: true, header_converters: :symbol do |row|
      @teams << Team.new(row[:team_id], row[:franchiseid], row[:teamname], row[:abbreviation], row[:stadium])
    end
  end
  
  def game_teams_generator(locations)
    CSV.foreach locations[:game_teams], headers: true, header_converters: :symbol do |row|
      @game_teams << GameTeam.new(row[:game_id], row[:team_id], row[:hoa], row[:result], row[:settled_in], row[:head_coach], row[:goals], row[:shots], row[:tackles], row[:pim], row[:powerplayopportunities], row[:powerplaygoals], row[:faceoffwinpercentage], row[:giveaways], row[:takeaways])
    end
  end
  
  def highest_total_score
    #@games to find all game scores and pick out the highest total score
    
    
    # total = []
    # @games.each do |game|
    #   p game.game_id if game.away_goals.to_i + game.home_goals.to_i == 11
    #   total << game.away_goals.to_i + game.home_goals.to_i
    # end
    # total.find do |score|
    #   score == 11
    # end

    
    total = @games.max_by do |game|
      game.away_goals.to_i + game.home_goals.to_i
    end
    total.away_goals.to_i + total.home_goals.to_i
  end
  
end
