class GameTeam
  attr_reader :game_id, 
              :team_id,
              :hoa,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals,
              :result,
              :goals,
              :tackles,
              :head_coach
  
  def initialize(row)
  
    @game_id = row[:game_id]
    @team_id = row[:team_id]
    @hoa = row[:hoa]
    @head_coach = row[:head_coach]
    @goals = row[:goals]
    @result = row[:result]
    @shots = row[:shots]
    @tackles = row[:tackles]
  end
end