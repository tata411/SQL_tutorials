--concatenation (объединение)
SELECT text1, text2, 
text1 ||' '|| text2 as text3,
CONCAT(text1, ' ', text2) as text3
--upper lower case
SELECT UPPER(col1), LOWER(col2), INITCAP(title) -- returns Title Case
--replacing
SELECT REPLACE(column_name, 'text_to_change', 'new_text'),
REVERSE(column1) --буквы в обратно порядке 

CHAR_LENGTH(title) -- можно просто LENGTH()
POSITION('@' IN email) -- выдает порядковый номер буквы/символа в строке
STRPOS(email, '@') -- аналог POSTION()
LEFT/RIGHT(description,50) -- 50 символов слева или справа
SUBSTRING(title, 10, 20) -- 10-начала отсчета, 20 кол-во симоволов
SUBSTRING(column_name FROM __ FOR __)
SUBSTRING(email FROM 0 FOR POSTION('@' IN email)) -- FROM 0 - начало, FOR - конец
SUBSTRING(email FROM POSITION('@' IN email)+1 FOR CHAR_LENGTH(email)) --начало после '@' до конца
SUBSTR(email, 10, 20) -- аналогично с substring, но можно использовать только с запятыми без from и for

SELECT TRIM(title) -- удаляет пробелы
LTRIM(title) -- удаляет пробелы в начале
RTRIM(title) -- удаляет пробелы в конце

RPAD/LPAD('padded', 10, '#') -- дополнение (padding) строки символом '#', чтобы в итоге получить 10 симоволов '####padded'
LPAD('padded',10) -- если не указывать симовл, то строка будет дополнена проблеами

-- Concatenate the first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) 
    || RPAD(last_name, LENGTH(last_name)+2, ' <') 
    || RPAD(email, LENGTH(email)+1, '>') AS full_email
FROM customer; 
--result:MARY SMITH <MARY.SMITH@sakilacustomer.org>

 -- Truncate the description without cutting off a word
  LEFT(description, 50 - 
    -- Subtract the position of the first whitespace character
    POSITION(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  ) 
