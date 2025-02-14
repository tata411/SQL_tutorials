--window funcitions
--Инструкция PARTITION BY определяет столбец, по которому данные будут делиться на группы
--ORDER BY определяет столбец, по которому значения внутри окна будут сортироваться
--ROWS и RANGE могут дополнительно задавать границы рамки окна и ограничивать диапазон работы функций внутри партиции
--RANGE — начало и конец рамки задаются разницей значений в столбце из ORDER BY
--ROWS — начало и конец рамки определяются строками относительно текущей строки. 
ROW_NUMBER() OVER() AS Row_N 

SELECT 
	SUM(column) OVER (PARTITION BY user_id 
		ORDER BY date ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS sum
FROM table
--UNBOUNDED PRECEDING - рамка начинается с первой строки партиции.
--CURRENT ROW - рамка заканчивается на последней строке партиции.
--значение FOLLOWING
--UNBOUNDED FOLLOWING
/* Ранжирующие функции:
ROW_NUMBER — простая нумерация (1, 2, 3, 4, 5).
RANK — нумерация с учётом повторяющихся значений с пропуском рангов (1, 2, 2, 4, 5).
DENSE_RANK — нумерация с учётом повторяющихся значений без пропуска рангов (1, 2, 2, 3, 4).*/

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
