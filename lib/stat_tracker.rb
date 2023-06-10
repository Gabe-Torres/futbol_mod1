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

  def count_of_teams
    @teams.count
  end
  
  def average_goals_per_game
    per_game_average = games.map do |game|
      sum_of_goals(game)
    end
    average = (per_game_average.sum / per_game_average.size.to_f).round(2)
  end
  
  def average_goals_by_season
    all_goals = Hash.new {|h, k| h[k] = [] }
    games.each do |game|
      all_goals[game.season] <<  sum_of_goals(game)
    end

    all_goals.each do |key, value|
      average = (value.sum / value.size.to_f).round(2)
      all_goals[key] = average
    end
  end

  def highest_scoring_visitor
    tally_scores = Hash.new {|h, k| h[k] = [] }
    games.each do |game|
      tally_scores[game.away_team_id] <<  game.away_goals.to_i
    end
    average_and_lookup(tally_scores, :max)
  end

  def highest_scoring_home_team
    tally_scores = Hash.new {|h, k| h[k] = [] }
    games.each do |game|
      tally_scores[game.home_team_id] <<  game.home_goals.to_i
    end
    average_and_lookup(tally_scores, :max)
  end

  def lowest_scoring_visitor
    tally_scores = Hash.new {|h, k| h[k] = [] }
    games.each do |game|
      tally_scores[game.away_team_id] <<  game.away_goals.to_i
    end
    average_and_lookup(tally_scores, :min)
  end
  
  def lowest_scoring_home_team 
    tally_scores = Hash.new {|h, k| h[k] = [] }
    games.each do |game|
      tally_scores[game.home_team_id] <<  game.home_goals.to_i
    end
    average_and_lookup(tally_scores, :min)
  end
  
  def best_offense
    best_offense_team_id = avg_goals_by_team.max_by do |team, avg_goals|
      avg_goals
    end[0]
    @teams.find { |team| team.team_id == best_offense_team_id }.team_name
  end
  
  def worst_offense
    worst_offense_team_id = avg_goals_by_team.min_by do |team, avg_goals|
      avg_goals
    end[0]
    @teams.find { |team| team.team_id == worst_offense_team_id }.team_name
  end
  
  def most_tackles(season)
    tackle_stats = Hash.new(0)
    games.each do |game| 
      if game.season == season
        game_teams.find_all do |game_team_stat| 
          if game.game_id == game_team_stat.game_id
            tackle_stats[game_team_stat.team_id] += game_team_stat.tackles.to_i
          end
        end
      end
    end
    team_with_most_tackles = teams.find do |team|
      highest_tackles = tackle_stats.max {|a,b| a[1] <=> b[1]} 
      team.team_id == highest_tackles[0]
    end
    team_with_most_tackles.team_name
  end
  
  def fewest_tackles(season)
    tackle_stats = Hash.new(0)
    games.each do |game| 
      if game.season == season
        game_teams.find_all do |game_team_stat| 
          if game.game_id == game_team_stat.game_id
            tackle_stats[game_team_stat.team_id] += game_team_stat.tackles.to_i
          end
        end
      end
    end
    team_with_least_tackles = teams.find do |team|
      least_tackles = tackle_stats.min {|a,b| a[1] <=> b[1]} 
      team.team_id == least_tackles[0]
    end
    team_with_least_tackles.team_name
  end

  def winningest_coach(season)
    coach_win_percentages(season).max_by do |coach, win_percentage|
      win_percentage
    end[0]
  end

  def worst_coach(season)
    coach_win_percentages(season).min_by do |coach, win_percentage|
      win_percentage
    end[0]
  end

  # HELPER METHODS #

  def avg_goals_by_team
    team_hash = {}
    @game_teams.each do |game|
      if team_hash[game.team_id] == nil
        team_hash[game.team_id] = [game.goals]
      else
        team_hash[game.team_id] += [game.goals]
      end
    end
    team_hash.map do |team, games|
      team_hash[team] = [(games.map { |game| game.to_f }.sum) / games.count]
    end
    team_hash
  end

  def coach_win_percentages(season)
    season_games = @game_teams.find_all do |game|
      game.game_id[0..3] == season[0..3]
    end
    coach_games = season_games.group_by do |game|
      game.head_coach
    end
    coach_wins = coach_games.each do |coach, games|
      coach_games[coach] = [((games.find_all { |game| game.result == "WIN" }.count.to_f) / games.count.to_f).round(2)]
    end
  end
  
  def game_generator(locations)
    CSV.foreach locations[:games], headers: true, header_converters: :symbol do |row|
      @games << Game.new(row)
    end
  end
  
  def teams_generator(locations)
    CSV.foreach locations[:teams], headers: true, header_converters: :symbol do |row|
      @teams << Team.new(row)
    end
  end
  
  def game_teams_generator(locations)
    CSV.foreach locations[:game_teams], headers: true, header_converters: :symbol do |row|
      @game_teams << GameTeam.new(row)
    end
  end
  
  def sum_of_goals(game)
    game.away_goals.to_i + game.home_goals.to_i
  end
  
  def average_and_lookup(tally_scores, selector)
    tally_scores.each do |key, value|
      tally_scores[key] = (value.sum / value.size.to_f).round(2)
    end

    selected_team = teams.find do |team|
      average_score = tally_scores.max {|a,b| a[1] <=> b[1]} if selector == :max 
      average_score = tally_scores.min {|a,b| a[1] <=> b[1]} if selector == :min 
      team.team_id == average_score[0]
    end
    selected_team.team_name
  end
end
