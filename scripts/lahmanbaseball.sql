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
what is the lowest value of height
name of the team
how many games
Teams table
appearances table

SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	MIN(p.height),
	(SELECT a.g_all 
		FROM appearances AS a
		WHERE a.playerid = p.playerid) AS total_games,
	(SELECT t.name
		FROM teams AS t) AS team_name
FROM people AS p
GROUP BY p.namefirst, p.namelast, p.height, p.playerid
ORDER BY p.height ASC
LIMIT 1

SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	p.height,
	p.playerid
FROM people AS p
WHERE 
    t.teamid =(SELECT t.name
		FROM teams AS t)
    AND total_games =(SELECT a.g_all 
		FROM appearances AS a
		WHERE a.playerid = p.playerid)
GROUP BY p.height, p.namefirst, p.namelast, p.playerid
ORDER BY p.height ASC
LIMIT 1

--THIS KEEPS SHOWING A NULL TEAM VALUE
WITH team_name AS (SELECT name FROM teams AS t)

SELECT
    p.namefirst AS first_name,
    p.namelast AS last_name,
    p.height,
    	(SELECT a.g_all
        	FROM appearances a
        	WHERE a.playerid = p.playerid) AS games_played,
		(SELECT name FROM teams) as team_name
FROM people AS p
ORDER BY p.height ASC
LIMIT 1

    		

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
fullname
total_salary

Schools Table
collegeplaying Table
People Table


--THIS IS THE QUERY I USED
WITH vanderbilt AS (SELECT schoolname FROM schools WHERE schoolname = 'Vanderbilt University')
SELECT 
	p.namefirst || ' ' || p.namelast AS fullname,
	SUM(sa.salary::numeric::money) AS salary
FROM people p
INNER JOIN salaries AS sa
	ON  sa.playerid = p.playerid
LEFT JOIN vanderbilt
	ON schoolname
GROUP BY fullname
ORDER BY salary DESC;


LEFT JOIN collegeplaying AS cp
	ON p.playerid = cp.playerid

SELECT DISTINCT p.playerid
FROM people as p
	DISTINCT p.playerid,
SELECT
	schoolname,
	p.namefirst,
	p.namelast
FROM schools s
INNER JOIN people p
WHERE s.schoolname = 'Vanderbilt University'
GROUP BY schoolname 
ORDER BY schoolname DESC

SELECT schoolid, schoolname FROM schools WHERE schoolname = 'Vanderbilt University'
UNION
SELECT p.namefirst || ' ' || p.namelast AS fullname, playerid FROM people p
UNION
SELECT SUM(sa.salary::numeric::money) AS salary, sa.teamid FROM Salaries sa




-- 4. Using the fielding table, group players into three groups bas 
Fielding Table
Putout's for 3 groups Battery, Infield, Outfield
2016

--Use a CASE WHEN
SELECT pos, PO, YearID,
CASE
    WHEN pos IN ('OF') THEN 'Outfield'
    WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery'
ELSE 'NA'
END 
FROM fielding;

SELECT 
	PO, 
	YearID,
COUNT (CASE WHEN pos IN ('OF') THEN 'Outfield' END) AS Outfield,
COUNT (CASE WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield' END) AS Infield,
COUNT (CASE	WHEN pos IN ('P', 'C') THEN 'Battery' END) AS Battery
FROM fielding
WHERE yearid = '2016'
GROUP BY PO, YearID 
ORDER BY po DESC;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
decade
so_per_game
hr_per_game


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
full_name
sb
attempts
sb_pct

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
	ORDER BY yearid
	),
most_win_teams AS (
	SELECT 
		yearid,
		name,
		wswin
	FROM teams
	INNER JOIN most_wins
	USING(yearid, w)
)
SELECT 
	(SELECT COUNT(*)
	 FROM most_win_teams
	 WHERE wswin = 'N'
	) * 100.0 /
	(SELECT COUNT(*)
	 FROM most_win_teams
	);

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
	HAVING COUNT(DISTINCT lgid) = 2
	) -- there are only 2 people that fit this criteria.

-- SELECT 
-- 	* 
-- FROM awardsmanagers 
-- WHERE awardid = 'TSN Manager of the Year' 
-- 	AND  lgid IN ('AL', 'NL')
-- G-- 100 rows total --60 rows won in both


SELECT
	namefirst || ' ' || namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN both_league_winners
	USING(playerid)
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
full_name
hr

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
