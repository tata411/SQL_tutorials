SELECT
    CASE
    WHEN SUM(column) OVER (...) > 100 THEN 'above 100'
    WHEN SUM(column) OVER (...) < 100 THEN 'below 100'
    ELSE 'equal 100'
    END AS sum_case
FROM table

/*Функции смещения:

LAG, LEAD — значение предыдущей или следующей строки.
FIRST_VALUE, LAST_VALUE — первое или последнее значение в окне.*/

FIRST_VALUE(Athlete) OVER(ORDER BY Athlete ASC) AS First_Athlete
FROM All_Male_Medalists;

LAST_VALUE(City) OVER (ORDER BY Year ASC
   RANGE BETWEEN
     UNBOUNDED PRECEDING AND
     UNBOUNDED FOLLOWING
  ) AS Last_City

  -- Fetch the previous year's champion
  LAG(Champion) OVER
    (ORDER BY Year ASC) AS Last_Champion -- столбец с чемпионами проедыдущего года

  NTILE(15) OVER -- разделить на 15 частей. В новом столбце указана страница
	
--фильтр в оконных фукциях
SELECT SUM(column_1) FILTER (WHERE column_2 > 100) OVER (PARTITION BY column_3 ORDER BY column_4) AS sum
FROM table
