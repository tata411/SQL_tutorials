-- ЗАДАЧА 1
-- Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте 
-- все товары по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:

-- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
-- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
-- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).

SELECT product_id,
       name,
       price,
       row_number() OVER (ORDER BY price desc) as product_number,
       rank() OVER (ORDER BY price desc) as product_rank,
       dense_rank() OVER (ORDER BY price desc) as product_dense_rank
FROM   products

-- ЗАДАЧА 2
-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке 
-- для каждой записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price.
-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара — 
-- просто поделите одну колонку на другую. Полученные доли округлите до двух знаков после запятой. 
-- Колонку с долями назовите share_of_max.

SELECT product_id,
       name,
       price,
       max(price) OVER () as max_price,
       round(price / max(price) OVER (), 2) as share_of_max
FROM   products
ORDER BY price desc, product_id

-- ЗАДАЧА 3
-- Примените две оконные функции к таблице products. Одну с агрегирующей функцией MAX,
-- а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены. 
-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. 
-- Поместите результат вычислений в две колонки max_price и min_price.

SELECT product_id,
       name,
       price,
       max(price) OVER (ORDER BY price desc) as max_price,
       min(price) OVER (ORDER BY price desc) as min_price
FROM   products
ORDER BY price desc, product_id

-- ЗАДАЧА 4
-- Сначала на основе таблицы orders сформируйте запрос, который вернет таблицу с общим числом заказов по дням. 
-- При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). 
-- Колонку с днями назовите date, а колонку с числом заказов — orders_count.
-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией SUM
-- для расчёта накопительной суммы числа заказов. Не забудьте для окна задать инструкцию ORDER BY по дате.
-- Обратите внимание, что в PostgreSQL оконные функции в качестве результата возвращают значение типа DECIMAL несмотря на то, что исходное значение находится в формате INTEGER. 
-- Поэтому не забудьте полученное значение накопительной суммы дополнительно привести к целочисленному формату.
 
 SELECT date,
       orders_count,
       sum(orders_count:: int) OVER(ORDER BY date) as orders_count_cumulative
FROM   (SELECT creation_time :: date as date,
               count(distinct order_id) as orders_count
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY 1) as t1

-- ЗАДАЧА 5
-- Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа.
-- Для этого примените оконную функцию ROW_NUMBER, используйте id пользователей для деления на патриции,
-- а время заказа для сортировки внутри патриции. Отменённые заказы не учитывайте.

SELECT user_id,
       order_id,
       time,
       row_number() OVER(PARTITION BY user_id
                         ORDER BY time) as order_number
FROM   user_actions
WHERE  order_id not in(SELECT order_id
                       FROM   user_actions
                       WHERE  action = 'cancel_order')
ORDER BY user_id, order_number limit 1000

--ФУНКЦИИ СМЕЩЕНИЯ
SELECT LAG(column, 1) OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE BETWEEN ...) AS lag_value
FROM table

SELECT LEAD(column, 1) OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE BETWEEN ...) AS lead_value
FROM table

-- ЗАДАЧА 6
-- Дополните запрос из предыдущего задания и с помощью оконной функции для каждого заказа каждого пользователя рассчитайте, 
-- сколько времени прошло с момента предыдущего заказа. 
-- Для этого сначала в отдельном столбце с помощью LAG сделайте смещение по столбцу time на одно значение назад. 
-- Столбец со смещёнными значениями назовите time_lag. Затем отнимите от каждого значения в колонке time новое значение со смещением 
-- (либо можете использовать уже знакомую функцию AGE). Колонку с полученным интервалом назовите time_diff.

SELECT user_id,
       order_id,
       time,
       row_number() OVER(PARTITION BY user_id
                         ORDER BY time) as order_number,
       lag(time) OVER(PARTITION BY user_id) as time_lag,
       age(time, lag(time) OVER(PARTITION BY user_id)) as time_diff
FROM   user_actions
WHERE  order_id not in(SELECT order_id
                       FROM   user_actions
                       WHERE  action = 'cancel_order')
ORDER BY user_id, order_number limit 1000

-- ЗАДАЧА 7
-- На основе запроса из предыдущего задания для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами.
-- Посчитайте этот показатель только для тех пользователей, которые за всё время оформили более одного неотмененного заказа.
-- Ивлечение секунд:
SELECT EXTRACT(epoch FROM INTERVAL '3 days, 1:21:32')

with t1 as (SELECT user_id,
                   order_id,
                   extract(epoch
            FROM   age(time, lag(time)
            OVER(
            PARTITION BY user_id
            ORDER BY time))) /3600 :: int as time_diff, count(order_id)
            OVER(
            PARTITION BY user_id) as orders_count
            FROM   user_actions
            WHERE  order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order'))
SELECT user_id,
       round(avg(time_diff)) :: int as hours_between_orders
FROM   t1
WHERE  time_diff is not null
   and orders_count > 1
GROUP BY user_id
ORDER BY user_id limit 1000

-- ЗАДАЧА 8
-- РАМКИ ДЛЯ ROWS BETWEEN:
-- UNBOUNDED PRECEDING
-- значение PRECEDING
-- CURRENT ROW
-- значение FOLLOWING
-- UNBOUNDED FOLLOWING
-- Найти скользящее среднее для каждой записи по трём предыдущим дням. 
with t1 as (SELECT creation_time ::date as date,
                   count(orders) as orders_count
            FROM   orders
            WHERE  order_id not in(SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
            GROUP BY date)
SELECT date,
       orders_count,
       round(avg(orders_count) OVER(ORDER BY date rows between 3 preceding and 1 preceding),
             2) as moving_avg
FROM   t1

-- ЗАДАЧА 9
-- Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры.
-- Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов. 
-- Затем в отдельном столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры.
-- После этого сравните число заказов, доставленных каждым курьером, со средним значением в новом столбце. Если курьер доставил больше заказов, 
-- чем в среднем все курьеры, то в отдельном столбце с помощью CASE укажите число 1, в противном случае укажите 0.

with t1 as(SELECT courier_id,
                  count(order_id) as delivered_orders,
                  avg(count(order_id)) OVER () as avg_delivered_orders
           FROM   courier_actions
           WHERE  action = 'deliver_order'
              and time between '09.01.2022'
              and '10.01.2022'
           GROUP BY courier_id)
SELECT courier_id,
       delivered_orders,
       round(avg_delivered_orders, 2) as avg_delivered_orders,
       case when delivered_orders > avg_delivered_orders then '1'
            else '0' end as is_above_avg
FROM   t1
ORDER BY 1

-- ЗАДАЧА 10
-- По данным таблицы user_actions посчитайте число первых и повторных заказов на каждую дату.
-- Для этого сначала с помощью оконных функций и оператора CASE сформируйте таблицу, в которой напротив каждого заказа будет стоять отметка «Первый»
-- или «Повторный» (без кавычек). Для каждого пользователя первым заказом будет тот, который был сделан раньше всего. 
-- Все остальные заказы должны попасть, соответственно, в категорию «Повторный». Затем на каждую дату посчитайте число заказов каждой категории

SELECT date :: date,
       order_type,
       count (distinct order_id) as orders_count
FROM   (SELECT order_id,
               time as date,
               case when time = min(time) OVER(PARTITION BY user_id
                                               ORDER BY time) then 'Первый'
                    else 'Повторный' end as order_type
        FROM   user_actions
        WHERE  order_id not in(SELECT order_id
                               FROM   user_actions
                               WHERE  action = 'cancel_order')) as t1
GROUP BY 1, 2
ORDER BY 1, 2