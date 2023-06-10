class Team
  attr_reader :team_id, 
              :team_name 
  
  def initialize(row)
  
    @team_id = row[:team_id]
    @team_name = row[:teamname]
  end
end