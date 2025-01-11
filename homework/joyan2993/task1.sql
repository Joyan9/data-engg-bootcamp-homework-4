/*
-- Let's first create the table to store the player state changes
CREATE TABLE players_state_tracking(
	player_name TEXT,
  first_active_season INT,
	last_active_season INT,
  status TEXT,
  seasons_active INT[],
  current_season INT,
  PRIMARY KEY(player_name, current_season)
);
*/
INSERT INTO players_state_tracking

WITH last_season AS (
    SELECT * FROM players_state_tracking
    WHERE current_season = 2004

),
this_season AS (
    SELECT * FROM player_seasons
    WHERE season = 2005
)

SELECT
	COALESCE(ls.player_name, ts.player_name) as player_name,
  COALESCE(ls.first_active_season, ts.season) as first_active_season,
  COALESCE(ts.season, ls.last_active_season) as last_active_season,
  CASE 
  
  -- A player entering the league should be New
  WHEN ls.player_name IS NULL AND ts.player_name IS NOT NULL THEN 'New'
  
  -- A player leaving the league should be Retired
  WHEN 
  ts.season IS NULL and ls.last_active_season = ls.current_season THEN 'Retired'
  
  -- A player staying in the league should be Continued Playing
  WHEN 
  ls.last_active_season = ts.season - 1 IS NOT NULL THEN 'Continued Playing'
  
  -- A player that comes out of retirement should be Returned from Retirement
  WHEN 
  ls.last_active_season < ts.season - 1 THEN 'Returned from Retirement'
  
  -- A player that stays out of the league should be Stayed Retired
  ELSE 'Stayed Retired'
  END
  AS status,
  COALESCE(ls.seasons_active, ARRAY[]::INT[]) || -- get dates active array from history, if not present then create blank array
  -- Append
  CASE
    WHEN ts.player_name IS NOT NULL THEN ARRAY[ts.season] -- append to array
    ELSE ARRAY[]::INT[]
  END AS seasons_active,
  COALESCE(ts.season, ls.current_season + 1) as current_season
FROM last_season ls
FULL OUTER JOIN this_season ts
ON ls.player_name = ts.player_name



