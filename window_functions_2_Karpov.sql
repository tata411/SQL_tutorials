-- ЗАДАЧА 12
-- Использование FILTER(WHERE)
-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте среднюю цену всех товаров. Колонку с этим значением назовите avg_price.
-- Затем с помощью оконной функции и оператора FILTER в отдельной колонке рассчитайте среднюю цену товаров без учёта самого дорогого. Колонку с этим средним значением назовите avg_price_filtered

SELECT product_id,
       name,
       price,
       round(avg(price) OVER (), 2) as avg_price,
       round(avg(price) filter (WHERE price != (SELECT max(price)
                                         FROM   products)) OVER (), 2) as avg_price_filtered
FROM   products
ORDER BY price desc, product_id

-- ЗАДАЧА 13
-- Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте, сколько заказов сделал и сколько отменил каждый пользователь на момент совершения нового действия.
-- Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — числа оформленных и числа отменённых заказов.
-- Если пользователь оформляет заказ, то число оформленных им заказов увеличивайте на 1, если отменяет — увеличивайте на 1 количество отмен.

SELECT user_id,
       order_id,
       action,
       time,
       created_orders,
       canceled_orders,
       round(canceled_orders::decimal / created_orders, 2) as cancel_rate
FROM   (SELECT user_id,
               order_id,
               action,
               time,
               count(order_id) filter (WHERE action != 'cancel_order') OVER (PARTITION BY user_id
                                                                             ORDER BY time) as created_orders,
               count(order_id) filter (WHERE action = 'cancel_order') OVER (PARTITION BY user_id
                                                                            ORDER BY time) as canceled_orders
        FROM   user_actions) t
ORDER BY user_id, order_id, time limit 1000

-- ЗАДАЧА 14
-- Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов. Выведите id курьеров, количество доставленных заказов и порядковый номер курьера в соответствии с числом доставленных заказов.
-- У курьера, доставившего наибольшее число заказов, порядковый номер должен быть равен 1, а у курьера с наименьшим числом заказов — числу, равному десяти процентам от общего количества курьеров в таблице courier_actions.
-- При расчёте номера последнего курьера округляйте значение до целого числа.

with t1 as(SELECT courier_id,
                  count(order_id) as orders_count
           FROM   courier_actions
           WHERE  action = 'deliver_order'
           GROUP BY courier_id)
SELECT courier_id,
       orders_count,
       row_number() OVER (ORDER BY orders_count desc, courier_id) as courier_rank
FROM   t1 limit round ((SELECT count(distinct courier_id)
                        FROM   courier_actions)*0.1)

-- ЗАДАЧА 15
-- С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей компании 10 и более дней. 
-- Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.для нас важна только разница во времени между первым действием курьера и текущей отметкой времени.
-- Текущей отметкой времени, относительно которой необходимо рассчитывать продолжительность работы курьера, считайте время последнего действия в таблице courier_actions. 
-- Учитывайте только целые дни, прошедшие с момента первого выхода курьера на работу (часы и минуты не учитывайте).

with t1 as(SELECT DISTINCT courier_id,
                           extract(day
           FROM   max(time)
           OVER() - min(time) filter(
           WHERE  action = 'accept_order')
           OVER(
           PARTITION BY courier_id)) ::int as days_employed, count(order_id) filter(
           WHERE  action = 'deliver_order')
           OVER(
           PARTITION BY courier_id) as delivered_orders
           FROM   courier_actions)
SELECT courier_id,
       days_employed,
       delivered_orders
FROM   t1
WHERE  days_employed >= 10
ORDER BY 2 desc, 1

-- ЗАДАЧА 16
-- На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа, ежедневную выручку сервиса и долю стоимости каждого заказа в ежедневной выручке, 
-- выраженную в процентах. В результат включите следующие колонки: 
-- id заказа, время создания заказа, стоимость заказа, выручку за день, в который был совершён заказ, а также долю стоимости заказа в выручке за день, выраженную в процентах.
-- При расчёте долей округляйте их до трёх знаков после запятой.
-- Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени), потом по убыванию доли заказа в выручке за день, затем по возрастанию id заказа.

SELECT order_id,
       creation_time,
       order_price,
       daily_revenue,
       percentage_of_daily_revenue
FROM   (SELECT DISTINCT order_id,
                        creation_time::date as ct,
                        creation_time,
                        sum(price) OVER(PARTITION BY order_id) as order_price,
                        sum(price) OVER (PARTITION BY creation_time::date) as daily_revenue,
                        round(sum(price) OVER(PARTITION BY order_id)/ sum(price) OVER (PARTITION BY creation_time::date)*100,
                              3) as percentage_of_daily_revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in(SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')) as t
            LEFT JOIN products using(product_id)) as t2
ORDER BY ct desc, percentage_of_daily_revenue desc, order_id

-- ЗАДАЧА 17
-- На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите её в колонке daily_revenue. 
-- Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. Прирост выручки отразите как в абсолютных значениях, так и в % относительно предыдущего дня. 
-- Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.

with t1 as(SELECT creation_time::date as date,
                  order_id,
                  unnest(product_ids) as product_id
           FROM   orders)
SELECT date,
       round(sum(price), 1) as daily_revenue,
       coalesce(round(sum(price) - lag(sum(price)) OVER (ORDER BY date), 1),
                0) as revenue_growth_abs,
       coalesce(round((sum(price) - lag(sum(price)) OVER (ORDER BY date))/ lag(sum(price)) OVER (ORDER BY date) * 100 , 1),
                0) as revenue_growth_percentage
FROM   (SELECT date,
               order_id,
               product_id,
               price
        FROM   t1 join products using(product_id)) t2
WHERE  order_id not in (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
GROUP BY date
ORDER BY date

-- ЗАДАЧА 18
-- С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, оформленных в нашем сервисе. В качестве результата выведите одно число. 
-- Колонку с ним назовите median_price. Отменённые заказы не учитывайте. Запрос должен учитывать два возможных сценария: для чётного и нечётного числа заказов. 
-- Встроенные функции для расчёта квантилей применять нельзя.

WITH main_table AS (
  SELECT
    order_price,
    ROW_NUMBER() OVER (
      ORDER BY
        order_price
    ) AS row_number,
    COUNT(*) OVER() AS total_rows
  FROM
    (
      SELECT
        SUM(price) AS order_price
      FROM
        (
          SELECT
            order_id,
            product_ids,
            UNNEST(product_ids) AS product_id
          FROM
            orders
          WHERE
            order_id NOT IN (
              SELECT
                order_id
              FROM
                user_actions
              WHERE
                action = 'cancel_order'
            )
        ) t3
        LEFT JOIN products USING(product_id)
      GROUP BY
        order_id
    ) t1
)
SELECT
  AVG(order_price) AS median_price
FROM
  main_table
WHERE
  row_number BETWEEN total_rows / 2.0
  AND total_rows / 2.0 + 1