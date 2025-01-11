# Game Analytics SQL Tasks

This README provides an overview of the SQL queries used to solve specific analytical tasks related to the `game_details` and `games` datasets. Each task demonstrates the use of advanced SQL features, including window functions and common table expressions (CTEs), to derive meaningful insights from the data.

---

## **1. Task: Most Games a Team Has Won in a 90-Game Stretch**

### **Objective**
To determine the highest number of games won by a team within any consecutive 90-game stretch.

### **SQL Query**
```sql
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
    ) AS teams(team_id)
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
```

### **Explanation**
1. **`team_results` CTE**: Prepares the dataset with information about whether a team won a particular game by comparing home and away scores.
2. **`team_wins` CTE**: Assigns a sequential number to each game for each team using `ROW_NUMBER()`.
3. **`cumulative_wins` CTE**: Uses a sliding window function to calculate the number of wins in the last 90 games for each team.
4. **Final Query**: Extracts the maximum wins in any 90-game stretch for each team and season.

---

## **2. Task: Longest Streak of LeBron James Scoring Over 10 Points**

### **Objective**
To find the longest streak of consecutive games where LeBron James scored more than 10 points.

### **SQL Query**
```sql
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
```

### **Explanation**
1. **`lebron_games` CTE**: Filters data for LeBron James and identifies games where he scored over 10 points.
2. **`streaks` CTE**: Groups games into streaks using a `SUM` window function that increments when a game breaks the streak (score <= 10 points).
3. **Final Query**: Finds the longest streak by counting the consecutive games in each streak group where LeBron scored over 10 points.

---

## **Schema Information**

### **`game_details` Table**
| Column           | Type    | Description                              |
|------------------|---------|------------------------------------------|
| `game_id`        | INTEGER | Unique identifier for the game           |
| `player_name`    | TEXT    | Name of the player                       |
| `team_id`        | INTEGER | Identifier for the team                  |
| `pts`            | REAL    | Points scored by the player              |
| Other columns... | ...     | Additional game statistics               |

### **`games` Table**
| Column            | Type    | Description                              |
|-------------------|---------|------------------------------------------|
| `game_id`         | INTEGER | Unique identifier for the game           |
| `game_date_est`   | DATE    | Date of the game                         |
| `home_team_id`    | INTEGER | Identifier for the home team             |
| `visitor_team_id` | INTEGER | Identifier for the visiting team         |
| `pts_home`        | REAL    | Points scored by the home team           |
| `pts_away`        | REAL    | Points scored by the visiting team       |
| `home_team_wins`  | INTEGER | Indicates if the home team won (1 or 0)  |
| Other columns...  | ...     | Additional game statistics               |

---
