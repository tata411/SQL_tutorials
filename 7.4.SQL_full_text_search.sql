SELECT title
WHERE title LIKE'%xyz'--case sensitive
AND title LIKE '_xyz' --1 symbol
-или
SELECT title
WHERE to_tsvector(column_1) @@ to_tsquery ('xyz') --case insesnsitive

SELECT to_tsvector(description) --разделяет на лексемы(variants of the same word)
--output:'display':3 'fate':2 'georgia':19 'mad':9 'must':12 

-- create new data types
CREATE TYPE dayofweek AS ENUM (--(enumerated daya types, custom list if values that never change)
	'Monday',
	'Tuesday' ...)
--crate user_defined functions
CREATE FUNCTION squared(i integral) RETURNS integral as $$
	BEGIN 
		RETURN i*i;
	END;
$$ LANGUAGE plpsql;

-- get info about all datatypes in db
SELECT typename, typecategory FROM pg_type

SELECT colimn_name, data_type, udt_name --user-defined data type
FROM INFORMATION_SCHEMA.COLUMNS

-- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f 
	INNER JOIN inventory AS i ON f.film_id=i.film_id 
WHERE
	-- Only include results where the held_by_cust is not null
    inventory_held_by_customer(i.inventory_id) IS NOT NULL

--find out list of available extensions in postgresql
SELECT colimn_nameFROM pg_available_extensions;
--installed extantions
SELECT extname
FROM plpgsql

CREATE EXTENSIOM IF NOT EXISTS pg_tgrm

-- Select the title and description columns
SELECT 
 title, 
  description, 
  -- Calculate the similarity
  similarity(title, description) -- from fuzzystrmatch extension
FROM 
  film;

  -- Select the title and description columns
SELECT  
  title, 
  description, 
  -- Calculate the levenshtein distance
 levenshtein(title, description) AS distance -- represents the number of edits required to convert one string to another string
FROM 
  film
ORDER BY 3