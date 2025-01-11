/*
1. What is the most games a team has won in a 90-game stretch?
*/
WITH team_results AS (
    SELECT
        game_id,
        team_id AS team_id,
        season,
        CASE
            WHEN team_id = home_team_id THEN pts_home ELSE pts_away
        END AS team_points,
        CASE
            WHEN team_id = home_team_id THEN pts_away ELSE pts_home
        END AS opponent_points,
        CASE 
            WHEN (team_id = home_team_id AND home_team_wins = 1) OR 
                 (team_id = visitor_team_id AND home_team_wins = 0) THEN 1
            ELSE 0
        END AS win
    FROM
        public.games
    CROSS JOIN LATERAL (
        VALUES 
            (home_team_id),
            (visitor_team_id)
    ) AS teams(team_id) -- Get both home and away teams in a single query
),
team_wins AS (
    SELECT
        team_id,
        season,
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY game_id) AS game_num,
        win
    FROM
        team_results
),
cumulative_wins AS (
    SELECT
        team_id,
        season,
        game_num,
        SUM(win) OVER (
            PARTITION BY team_id
            ORDER BY game_num
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS wins_in_90_games
    FROM
        team_wins
)
SELECT
    team_id,
    season,
    MAX(wins_in_90_games) AS max_wins_in_90_games
FROM
    cumulative_wins
GROUP BY
    team_id, season
ORDER BY
    max_wins_in_90_games DESC;
