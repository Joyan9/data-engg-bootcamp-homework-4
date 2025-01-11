# Game Analytics SQL Tasks

This README provides an overview of the SQL queries used to solve specific analytical tasks related to the `game_details` and `games` datasets. Each task demonstrates the use of advanced SQL features, including window functions and common table expressions (CTEs), to derive meaningful insights from the data.

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
