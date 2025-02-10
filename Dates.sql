--Для вычитания двух дат используется функция DATEDIFF(дата_1, дата_2)
--извлекается кол-во дней
DATEDIFF('2020-05-09','2020-05-01')

--используется в WHERE
WHERE DATEDIFF(date_last, date_first) = 
      (SELECT MIN(DATEDIFF(date_last, date_first)) 
       FROM trip);
EXTRACT(quarter from date)
DATE_PART('quarter', date)
DATE_TRUNC('month', date) -- возвращает дату, trunc - обрезание Result: 2005-05-01 00;00:00
  AGE(timestamp_1, time)    
 --вывести месяц
 MONTH('2020-04-12')
 --вывести название месяца
 MONTHNAME('2020-04-12')='April'

 DAY('2020-02-01') = 1
MONTH('2020-02-01') = 2
YEAR('2020-02-01') = 2020
--прибавить интервал

SELECT
      -- Calculate the expected_return_date
      rental_date + '3 days' AS expected_return_date
--convert into interval
SELECT INTERVAL '1' day * timestamp '2019-04-10 12:34:56',
INTERVAL '5 days' + CURRENT_DATE
--convert date type
CAST (NOW() AS timestamp)
NOW() :: timestamp
CURRENT_DATE,
CURRENT_TIME,
CURRENT_TIMESTAMP --текущее дата время
SELECT
      CURRENT_TIMESTAMP(0)::timestamp AS right_now, -- убрать лишние цифры (млсек)
    interval '5 days' + CURRENT_TIMESTAMP(0) AS five_days_from_now;


--BIGQUERY 2016.01 ->  в Jan 2016
SELECT FORMAT_TIMESTAMP('%b %Y', o.order_purchase_timestamp) as month 