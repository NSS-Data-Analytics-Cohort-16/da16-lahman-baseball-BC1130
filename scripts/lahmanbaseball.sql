-- ## Lahman Baseball Database Exercise
-- - this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- - A data dictionary is included with the files for this project.

-- **Directions:**  
-- * Within your repository, create a directory named "scripts" which will hold your scripts.
-- * Create a branch to hold your work.
-- * For each question, write a query to answer.
-- * Complete the initial ten questions before working on the open-ended ones.

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

-- THIS PULLS ALL THE YEARS
SELECT year
FROM homegames
GROUP BY year
ORDER BY year
 
-- THIS PULLS JUST THE MIN AND MAX YEARS, FROM/TO
SELECT MIN(year) AS Min_year, MAX(year) AS Max_year
FROM homegames

--ANSWER: The range of years this database covers is 1871 to 2016.

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
shortest player
name & height
how many games played
team name

FIND SHORTEST PLAYER
player name
MIN value of height
team name
how many games
Teams table
appearances table

--THIS IS THE QUERY I USED
SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	MIN(p.height),
	a.g_all AS games_played,
	t.name AS team_name
FROM people AS p 
INNER JOIN appearances AS a
	ON a.playerid = p.playerid
INNER JOIN teams AS t
	ON t.teamid = a.teamid
GROUP BY p.namefirst, p.namelast, p.height, p.playerid, a.g_all, t.name
ORDER BY p.height ASC
LIMIT 1

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
fullname
total_salary

Schools Table
collegeplaying Table
People Table


--THIS IS THE QUERY I USED

SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	SUM(sa.salary::numeric) AS salary,
	(SELECT schoolname FROM schools WHERE schoolname = 'Vanderbilt University')
FROM people p
INNER JOIN salaries AS sa
	ON  sa.playerid = p.playerid
GROUP BY fullname
ORDER BY salary DESC;


--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
--those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of 
--putouts made by each of these three groups in 2016.
 
Fielding Table
Putout's for 3 groups Battery, Infield, Outfield
2016

SELECT 
	CASE 
		WHEN pos IN ('OF') THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery' 
	END AS positions,
	SUM(po) AS total_po
FROM fielding
WHERE yearid = '2016'
GROUP BY positions


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
decade
so_per_game
hr_per_game


SELECT 
	ROUND(SUM(so)::numeric/SUM(g)::numeric) AS so_per_game,
	ROUND(SUM(hr)::numeric/SUM(g)::numeric) AS hr_per_game,
	yearid/10*10 AS decade
FROM batting
WHERE 
	yearid >= '1920'
GROUP BY yearid 
ORDER BY yearid DESC
;


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
full_name
sb
attempts
sb_pct
yearid

SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	b.yearid,
	b.sb >20,
	b.cs AS tried_to_steal,
	b.sb_pct
FROM people AS p
LEFT JOIN batting AS b
ON b.playerid = p.playerid


-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
?column?
75.4716981132075472
What percentage of the time

WITH most_wins AS (
	SELECT
		yearid,
		MAX(w) AS w
	FROM teams
	WHERE yearid >= 1970
	GROUP BY yearid
	ORDER BY yearid),
most_win_teams AS (
	SELECT 
		yearid,
		name,
		wswin
	FROM teams
	INNER JOIN most_wins
	USING(yearid, w))
SELECT 
	(SELECT COUNT(*)
	 FROM most_win_teams
	 WHERE wswin = 'N') * 100.0 /
	(SELECT COUNT(*)
	 FROM most_win_teams);

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT 
	p.park_name,
	h.attendance,
	t.name AS team_name,
	h.games,
	h.attendance/h.games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
USING (park)
INNER JOIN teams AS t
ON h.team = t.teamidlahman45 AND t.yearid = h.year
WHERE yearid = '2016' AND games >= '10'
GROUP BY p.park_name, h.games, t.name, h.attendance
ORDER BY avg_attendance DESC 
LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
full_name
yearid
Igid
name


WITH both_league_winners AS (
	SELECT
		playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2)
SELECT
	namefirst || ' ' || namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN awardsmanagers
	USING(playerid)
INNER JOIN managers
	USING(playerid, yearid, lgid)
INNER JOIN teams
	USING(teamid,yearid,lgid)
WHERE awardid = 'TSN Manager of the Year'
ORDER BY full_name, yearid;


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, 
--and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

SELECT
	p.namefirst || ' ' || p.namelast AS full_name,
	b.hr,
	MIN(b.yearid) AS min_year,
	MAX(b.yearid) AS max_year,
	MAX(b.yearid) - MIN(b.yearid) >= 10 AS years_played
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE
	b.hr >= 1
	AND yearid = 2016
GROUP BY full_name, b.hr

SELECT
	p.namefirst || ' ' || p.namelast AS full_name,
	b.hr,
	(p.finalGame) - (p.debut) >= 10 AS years_played
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE
	b.hr >= 1
	AND yearid = 2016
GROUP BY full_name, b.hr

SELECT
	(finalGame - debut) AS years_played
FROM people

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
WHERE yearis > 2000

-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
