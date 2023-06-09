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
    stat_tracker
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
  
  
  def percentage_home_wins 
    home_wins = @game_teams.find_all do |game_team|
      game_team.hoa == "home" && game_team.result == "WIN"
    end
    (home_wins.count.to_f / @games.count).round(2)
  end
  
  def percentage_visitor_wins 
    visitor_wins = @game_teams.find_all do |game_team|
      game_team.hoa == "away" && game_team.result == "WIN"
    end
    (visitor_wins.count.to_f / @games.count).round(2)
  end
  
  def percentage_ties
    ties = @game_teams.find_all do |game_team|
      game_team.result == "TIE"
    end
    (ties.count.to_f / @game_teams.count).round(2)
  end

  def sum_of_goals(game)
    game.away_goals.to_i + game.home_goals.to_i
  end
  
  def highest_total_score
    game = @games.max_by do |game|
      sum_of_goals(game)
    end
    sum_of_goals(game)
  end
  
  def lowest_total_score
    game = @games.min_by do |game|
      sum_of_goals(game)
    end
    sum_of_goals(game)
  end

  def count_of_games_by_season
    seasons = games.map {|game| game.season}
    seasons.tally
  end
  
  def average_goals_per_game
    per_game_average = games.map do |game|
      sum_of_goals(game)
    end
    average = (per_game_average.sum / per_game_average.size.to_f).round(2)
  end
  
  def average_goals_by_season
    hash = {}
    games.each do |game|
      if hash[game.season]
        hash[game.season] <<  sum_of_goals(game)
      else
        hash[game.season] = [sum_of_goals(game)]
      end
    end
    hash.each do |key, value|
      average = (value.sum / value.size.to_f).round(2)
      hash[key] = average
    end
  end
    
  def count_of_teams
    @teams.count
  end
end
