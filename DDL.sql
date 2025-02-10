-- ШАГ 1 
-- ЗАДАНИЕ создание таблицы MY SQL
CREATE TABLE book(
    -- AUTO_INCREMENT  АВТО_ПРИРОСТ
    -- MS SQL- ID int NOT NULL CONSTRAINT PK_Employees (ограничитель имени) PRIMARY KEY, 
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    -- диапазон чисел который позволяет тип int (цедые числа) от -2 147 483 648 до 2 147 483 647. 
    --Обычно это основной тип, который используется для задания идентификаторов.
    title VARCHAR(30)
    --CHAR хранит строку фиксированной длины (от 0 до 28-1 символов), 
    --которая задаётся на этапе создания таблицы. 
    --Если происходит передача строки меньшей длины, 
   -- чем была указана, то оставшиеся символы заполняются пробелами.
   --Отличие varchar от nvarchar заключается в том, что varchar позволяет 
   --хранить строки в формате ASCII, где один символ занимает 1 байт, 
   --а nvarchar хранит строки в формате Unicode, где каждый символ занимает 2 байта.
    autor VARCHAR(30)
    -- DECIMAL - вещественное число, (8,2) 8 знаков до ,  2 знака после  
    --в MS SQL float
    author_id INT NOT NULL
    price DECIMAL(8,2)
    amount INT,
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,/*при удалении из главной таблицы, удалится вся строка*/
    FOREIGN KEY (genre_id)  REFERENCES genre (agenre_id) ON DELETE SET NULL /*при удалении из главной таблицы будет значении null*/
-- дату заключаем в кавычки

-- SQL Server
create table trip
(
    trip_id INT PRIMARY KEY Identity(1,1),
    [name] varchar(30),
    city varchar(25),
    per_diem decimal(8,2),
    date_first date,
    date_last date
)

-- создаем новую таблицу из существующей
CREATE TABLE ordering AS
SELECT author,title, (SELECT ROUND(AVG(amount)) FROM book) as amount
FROM book
WHERE book.amount < (SELECT ROUND(AVG(amount)) FROM book)

    -- ШАГ 2
    -- Вставляем строку
    INSERT INTO book(
        -- перечисляем наименования атрибутов (столбцов), необязательно если во все
    book_id, title, author, price, amount)
    VALUES(1, 'Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3)
    -- числы без кавычек
 
 --ШАГ 3
 --Вставить несколько строк через ;
 INSERT INTO book(
    title, author, price, amount)
    VALUES ('Белая гвардия', 'Булгаков М.А.', 540.50, 5),
            ('Идиот', 'Достоевский Ф.М.', 460.00, 10);

 INSERT INTO book(
    title, author, price, amount)
    VALUES ('Идиот', 'Достоевский Ф.М.', 460.00, 10);
   
 INSERT INTO book(
    title, author, price, amount)
    VALUES ('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);
--если вставка из другой таблицы то вместо VALUES SELECT:
INSERT INTO client (name_client, city_id, email)
SELECT'Попов Илья', city_id, 'popov@test'
       FROM city
--вставить с подзапросом
       INSERT INTO buy_book(buy_id, book_id, amount)
VALUES
    (5, (SELECT book_id FROM book WHERE title = 'Лирика'), 2),
    (5, (SELECT book_id FROM book WHERE title = 'Белая гвардия'), 1);


--без перечисления столбцов (на мой взгляд проще не перечислять столбцы, когда их много, 
--а просто указывать функцию DEFAULT в качестве значения первого столбца с id. 
--Функция будет автоматически продолжать нумерацию)
INSERT INTO fine 
VALUES     (DEFAULT,'Баранов П.Е.','Р523ВТ','Превышение скорости(от 40 до 60)',NULL,'2020-02-14',NULL),
           (DEFAULT,'Абрамова К.А.','О111АВ','Проезд на запрещающий сигнал',NULL,'2020-02-23',NULL),
           (DEFAULT,'Яковлев Г.Р.','Т330ТТ','Проезд на запрещающий сигнал',NULL,'2020-03-03',NULL);
/* Смотрим, что получилось */
SELECT * FROM fine

-- ШАГ 4

--Добавить новый столбец
ALTER TABLE book ADD genre_id INT;
/*Эта команда используется для изменения струкутры таблицы. добавлять изменять удалять столбцы,
менять ограничения и индексы */
-- Изменить столбец
--Для того, чтобы задать обязательные для заполнения столбцы, 
--можно использовать опцию NOT NULL.
ALTER TABLE Employees ALTER COLUMN ID int NOT NULL


--добавить новый столбец (временно?..)
SELECT
    title,
    amount,
    amount * 1.65 AS pack
 FROM book

 --ШАГ 5
 --Округляем после запятой ROUND(Значение, кол-во знаков после запятой)
 SELECT 
    title,
    author, 
    amount,
    ROUND(price - price*0.3, 2) as new_price
    -- если просто ROUND(price) то округление до целого
FROM book

--ШАГ 6
-- Функция 'если' в MYSQL, в других БД это CASE WHEN THEN 
SELECT
    author, 
    title, 
    -- Если (автор такой-то, то цена на книгу такая-то, если (автор книги такой-то , 
    --то цена книги такая-то, либо цена по прайсу) 
    --и все это в новый столбец new_price
    ROUND(IF(author='Булгаков М.А.', price*1.1,
          IF(author='Есенин С.А.', price*1.05, price)),2) AS new_price
FROM book;

 --еще вариант
 SELECT
    author, title, price as real_price, amount,
    ROUND(IF (price*amount <5000, price*1.2, price *0.8),2) AS new_price,
    ROUND(IF(price<=500, 99.99, IF(amount<5, 149.99, 0)),2) AS delivery_price
 FROM book

--В MySQL можно использовать IF и CASE WHEN
--IF
UPDATE book
SET buy=IF(buy>amount, amount, buy),
price = IF(buy=0, price*0.9, price);
SELECT * FROM book


 --CASE WHEN THEN
UPDATE book SET buy = (
  CASE
    WHEN buy > amount
    THEN amount
    ELSE buy
  END),
price = (
  CASE
    WHEN buy = 0
    THEN round((price * 0.9), 2)
    ELSE price
  END);


--ШАГ 7
--операторы IN и BETWEEN
SELECT title, author
FROM book
WHERE price BETWEEN 540.50 AND 800 AND
amount IN(2,3,5,7)

--ШАГ 8
--оператор LIKE
SELECT title, author
FROM book
WHERE title LIKE "_% %_" AND
author LIKE "_%С.%"
-- LIKE 'Поэм_' выполняет поиск и выдает все книги, 
--названия которых либо «Поэма», либо «Поэмы» и пр.
-- LIKE '%М.%' выполняет поиск и выдает все книги, 
--инициалы авторов которых содержат «М.»
ORDER BY title
