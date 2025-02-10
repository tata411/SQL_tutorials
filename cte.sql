--CTE Common table expressions
--Reusable query result. 	Defined using the CREATE VIEW statement
--Correlating subqueries
SELECT
  c.name AS country,
  COUNT(sub.id) AS matches
FROM country AS c
INNER JOIN (
  SELECT country_id, id 
  FROM match
  WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id -- self join
GROUP BY country;

--SET OPERATIONS: UNION ALL, UNION (remove duplicates), INTERSECT (толлько пересечения в таблицах)
--EXCEPT (только то, чего нет в 2 запросе)
SELECT * FROM table_a
EXCEPT
SELECT * FROM table_b