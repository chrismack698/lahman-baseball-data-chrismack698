--1. What range of years for baseball games played does the provided database cover?

SELECT CONCAT(MIN(year), '-', MAX(year)) AS date_range
FROM homegames;

-- 2. Find the name and height of the shortest player in the database. 
-- How many games did he play in? What is the name of the team for which he played?


SELECT p.namefirst, p.namelast, p.height, t.name, a.g_all AS appearances 
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
LEFT JOIN teams AS t
ON a.teamid = t.teamid
WHERE height = (SELECT MIN(height) FROM people)
ORDER BY height ASC
LIMIT 1;

-- 3. Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
-- Which Vanderbilt player earned the most money in the majors?

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS fullname, SUM(s.salary) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE sc.schoolname = 'Vanderbilt University'
AND salary IS NOT NULL
GROUP BY fullname
ORDER BY total_salary DESC;

-- 4. Using the fielding table, group players into three groups based on their position: 
-- label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
WHEN pos = 'P' THEN 'Battery'
WHEN pos = 'C' THEN 'Battery'
ELSE 'Infield' END AS position, SUM(po) as total_putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position
ORDER BY total_putouts DESC;

-- 5. Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?

SELECT
CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
WHEN yearid BETWEEN '2010' AND '2016' THEN '2010s'
ELSE '1919-beyond'
END AS decade,
ROUND(CAST(SUM(so) AS numeric)/CAST(SUM(g) AS numeric),2) AS avg_so_9
FROM teams
GROUP BY decade
ORDER BY decade DESC;

-- for strikeouts

SELECT
CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'
WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
WHEN yearid BETWEEN '2010' AND '2016' THEN '2010s'
ELSE '1919-beyond'
END AS decade,
ROUND(CAST(SUM(hr) AS numeric)/CAST(SUM(g) AS numeric),2) AS avg_hr_9
FROM teams
GROUP BY decade
ORDER BY decade DESC;

-- for homeruns

-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. 
-- (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- Consider only players who attempted at least 20 stolen bases.

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS fullname, ROUND(CAST(b.sb AS numeric)/(CAST(b.sb AS numeric) + CAST(b.cs AS numeric)), 2) AS sb_success_rate
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE yearid = '2016'
AND b.sb + b.cs >=20
ORDER BY sb_success_rate DESC;

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
-- Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
-- What percentage of the time?

SELECT yearid, name, w
FROM teams
WHERE w = 
	(SELECT MAX(w)
	FROM teams
	WHERE wswin = 'Y')
AND yearid BETWEEN '1970' AND '2016';

-- largest number of wins

SELECT yearid, name, w
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'
ORDER BY w ASC
LIMIT 1;

-- lowest number

SELECT yearid, name, w
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'
AND g = '162'
ORDER BY w ASC
LIMIT 1;

-- revised query with shortened season accounted for

WITH world_series_winners AS 
(SELECT yearid, name, w 
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'),

max_wins AS
(SELECT yearid, MAX(w)
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
GROUP BY yearid)

SELECT m.yearid, w.w
FROM max_wins AS m
INNER JOIN world_series_winners AS w
ON m.yearid = w.yearid
AND m.max = w.w

-- world series winners with most wins

WITH world_series_winners AS 
(SELECT yearid, name, w 
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'),

max_wins AS
(SELECT yearid, MAX(w)
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
GROUP BY yearid),

best_record_ws_winners AS 
(SELECT m.yearid, w.w
FROM max_wins AS m
INNER JOIN world_series_winners AS w
ON m.yearid = w.yearid
AND m.max = w.w)

SELECT ROUND(CAST(COUNT(*) AS numeric)/46, 2)
FROM best_record_ws_winners

-- percentage of most win world series winners

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
-- Only consider parks where there were at least 10 games played. 
-- Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT p.park_name, h.team, h.attendance/h.games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
WHERE year = '2016'
AND h.games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

-- highest average attendance

SELECT p.park_name, h.team, h.attendance/h.games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
WHERE year = '2016'
AND h.games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
-- Give their full name and the teams that they were managing when they won the award.

WITH al_tsn AS
(SELECT a.playerid, a.yearid, m.teamid
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid
INNER JOIN managers AS m
ON a.playerid = m.playerid
WHERE a.awardid = 'TSN Manager of the Year'
AND a.lgid = 'AL'
AND a.yearid = m.yearid
GROUP BY a.playerid, a.yearid, m.teamid),

nl_tsn AS
(SELECT a.playerid, a.yearid, m.teamid
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid
INNER JOIN managers AS m
ON a.playerid = m.playerid
WHERE a.awardid = 'TSN Manager of the Year'
AND a.lgid = 'NL'
AND a.yearid = m.yearid
GROUP BY a.playerid, a.yearid, m.teamid)

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS fullname, n.yearid, n.teamid, a.yearid, a.teamid
FROM nl_tsn AS n
INNER JOIN al_tsn AS a
ON n.playerid = a.playerid
INNER JOIN people AS p
ON n.playerid = p.playerid
GROUP BY fullname, n.yearid, n.teamid, a.yearid, a.teamid

-- 10. Analyze all the colleges in the state of Tennessee. 
-- Which college has had the most success in the major leagues. 
-- Use whatever metric for success you like - number of players, number of games, salaries, world series wins, etc.

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS fullname, sc.schoolname, SUM(s.salary) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE sc.schoolstate = 'TN'
AND salary IS NOT NULL
GROUP BY fullname, sc.schoolname
ORDER BY total_salary DESC;

-- highest paid player from tennessee colleges

SELECT sc.schoolname, SUM(s.salary) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE sc.schoolstate = 'TN'
AND salary IS NOT NULL
GROUP BY sc.schoolname
ORDER BY total_salary DESC;

-- highest total salary by college

SELECT sc.schoolname, COUNT(distinct p.playerid) AS number_players 
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE sc.schoolstate = 'TN'
GROUP BY sc.schoolname
ORDER BY number_players DESC;

-- most players by school 

SELECT sc.schoolname, ROUND(CAST(SUM(s.salary) AS numeric)/CAST(COUNT(distinct p.playerid) AS numeric), 0) AS avg_salary
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE sc.schoolstate = 'TN'
AND salary IS NOT NULL
GROUP BY sc.schoolname
HAVING COUNT(p.playerid) >= 15
ORDER BY avg_salary DESC;

-- average salary of players from colleges with more than 15 MLB players

SELECT sc.schoolname, COUNT(distinct ap.playerid) AS number_players
FROM appearances AS ap
LEFT JOIN collegeplaying AS c
ON ap.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
LEFT JOIN teams AS t
ON ap.teamid = t.teamid
WHERE sc.schoolstate = 'TN'
AND wswin = 'Y'
AND ap.yearid = t.yearid
GROUP BY sc.schoolname
ORDER BY number_players DESC;

-- number of world series winners by college

-- not sure if above queries worked - recheck

-- 11. Is there any correlation between number of wins and team salary?
-- Use data from 2000 and later to answer this question. 
-- As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT t.name, t.yearid, t.w, SUM(s.salary) As total_salary
FROM salaries AS s
LEFT JOIN teams as t 
ON s.teamid = t.teamid
AND s.yearid = t.yearid
WHERE t.yearid >= '2000'
GROUP BY t.name, t.yearid, t.w
ORDER BY t.yearid DESC, total_salary DESC

-- basic query showing teams wins and salary by year
-- ran correlation and regression. short answer: not really. long answer: used to matter more, but the correlation has lessened over the last decade.

-- 12. In this question, you will explore the connection between number of wins and attendance.
-- a. Does there appear to be any correlation between attendance at home games and number of wins?
-- b. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT t.yearid, t.name, t.w, h.attendance
FROM teams AS t
LEFT JOIN homegames AS h
ON t.teamid = h.team
AND t.yearid = h.year
WHERE t.yearid >= '1950'
ORDER BY t.yearid DESC, h.attendance DESC

-- once again, correlation shows attendance and home games used to correlate with each other much more than they do in the modern day




