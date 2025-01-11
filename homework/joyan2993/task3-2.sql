/*
How many games in a row did LeBron James score over 10 points?
*/

WITH lebron_games AS (
    SELECT
        gd.game_id,
        g.game_date_est,
        gd.player_name,
        gd.team_id,
        gd.pts,
        CASE
            WHEN gd.pts > 10 THEN 1 ELSE 0
        END AS over_10_pts
    FROM
        public.game_details gd
    INNER JOIN
        public.games g ON gd.game_id = g.game_id
    WHERE
        gd.player_name = 'LeBron James'
),
streaks AS (
    SELECT
        game_id,
        game_date_est,
        player_name,
        team_id,
        over_10_pts,
        SUM(CASE WHEN over_10_pts = 0 THEN 1 ELSE 0 END) 
            OVER (ORDER BY game_date_est ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak_group
    FROM
        lebron_games
)
SELECT
    player_name,
    MAX(COUNT(over_10_pts)) AS max_streak
FROM
    streaks
WHERE
    over_10_pts = 1
GROUP BY
    player_name, streak_group
ORDER BY
    max_streak DESC
LIMIT 1;









