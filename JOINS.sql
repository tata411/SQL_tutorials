INNER JOIN
FULL JOIN
CROSS JOIN

UNION
UNION ALL
INTERSECT
EXCEPT

--2 значения в FROM
SELECT local_name, lang_num
FROM countries,
  (SELECT code, COUNT(*) AS lang_num
  FROM languages
  GROUP BY code) AS sub
-- Where codes match
WHERE countries.code = sub.code
ORDER BY lang_num DESC;

--Filter with case statement
WHERE CASE WHEN THEN END IS NOT NULL
-- Select matches where Barcelona was the away team
SELECT
    m.date,
    t.team_long_name AS opponent,
    CASE WHEN m.home_goal < m.away_goal THEN 'Barcelona win!'
         WHEN m.home_goal > m.away_goal THEN 'Barcelona loss :('
         ELSE 'Tie' END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t
ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id = 8634;

--percentage using CASE
SELECT
ROUND(AVG(CASE WHEN condition 1 THEN 1
	ELSE 0, END),2) as pct_name