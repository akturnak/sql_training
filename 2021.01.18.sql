-- UPSERT

DROP TABLE IF EXISTS customers;

CREATE TABLE customers
(
    customer_id serial PRIMARY KEY,
    name        VARCHAR UNIQUE,
    email       VARCHAR NOT NULL,
    active      bool    NOT NULL DEFAULT TRUE
);

INSERT INTO customers (name, email)
VALUES ('IBM', 'contact@ibm.com'),
       ('Microsoft', 'contact@microsoft.com'),
       ('Intel', 'contact@intel.com');

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT ON CONSTRAINT customers_name_key
    DO NOTHING;

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT (name)
    DO NOTHING;

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT (name)
    DO UPDATE SET email = excluded.email || ';' || customers.email;

-- ARRAY

CREATE TABLE contacts
(
    id     serial PRIMARY KEY,
    name   VARCHAR(100),
    phones TEXT[]
);

INSERT INTO contacts (name, phones)
VALUES ('John Doe', ARRAY ['(408)-789-7894', '(408)-768-7819']);

INSERT INTO contacts (name, phones)
VALUES ('Lily Bush', '{"(408)-589-8900"}'),
       ('William Gate', '{"(408)-589-5842", "(408)-589-7892"}');

SELECT name,
       phones
FROM contacts;

SELECT name,
       phones[1]
FROM contacts;

SELECT name
FROM contacts
WHERE phones[1] = '(408)-789-7894';

SELECT name
FROM contacts
WHERE phones @> ARRAY ['(408)-789-7894'];

UPDATE contacts
SET phones[2] = '(408)-589-923'
WHERE ID = 3;

SELECT id,
       name,
       phones[2]
FROM contacts
WHERE id = 3;

UPDATE contacts
SET phones = '{"(408)-589-5843"}'
WHERE id = 3;

SELECT name,
       phones
FROM contacts
WHERE '(408)-589-5843' = ANY (phones);

SELECT name,
       unnest(phones)
FROM contacts;

-- JSON

CREATE TABLE orders
(
    id   serial NOT NULL PRIMARY KEY,
    info json   NOT NULL
);

INSERT INTO orders(info)
VALUES ('{"customer": "John Doe", "items": {"product": "Beer", "qty": 6}}');

INSERT INTO orders (info)
VALUES ('{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'),
       ('{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'),
       ('{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}');

SELECT info
FROM orders;

SELECT info -> 'customer' AS customer
FROM orders;

SELECT info ->> 'customer' AS customer
FROM orders;

SELECT info -> 'items' ->> 'product' AS product
FROM orders
ORDER BY product;

SELECT info ->> 'customer' AS customer
FROM orders
WHERE info -> 'items' ->> 'product' = 'Diaper';

SELECT info ->> 'customer'           AS customer,
       info -> 'items' ->> 'product' AS product
FROM orders
WHERE CAST(info -> 'items' ->> 'qty' AS INTEGER) = 2;

SELECT info ->> 'customer'           AS customer,
       info -> 'items' ->> 'product' AS product
FROM orders
WHERE (info -> 'items' ->> 'qty')::INTEGER = 2;

SELECT MIN((info -> 'items' ->> 'qty')::INT),
       MAX((info -> 'items' ->> 'qty')::INT),
       SUM((info -> 'items' ->> 'qty')::INT),
       AVG((info -> 'items' ->> 'qty')::INT)
FROM orders;

SELECT json_each(info)
FROM orders;

SELECT json_each_text(info)
FROM orders;

SELECT json_object_keys(info -> 'items')
FROM orders;

SELECT json_typeof(info -> 'items')
FROM orders;

SELECT json_typeof(info -> 'items' -> 'qty')
FROM orders;

-- PL/pgSQL

SELECT 'String constant';

SELECT 'I''m also string constant';

SELECT E'I\'m also string)';

SELECT $$I'm a string constant that contains a backslash \$$;

SELECT $message$I'm a string constant that contains a backslash \$message$;

DO
'declare
    film_count integer;
begin
select count(*) into film_count from film;
raise notice ''The number of films: %'', film_count;
end;
';

do
$$
    declare
        film_count integer;
    begin
        select count(*)
        into film_count
        from film;
        raise notice 'The number of films: %', film_count;
    end;
$$

create function find_film_by_id(
    id int
) returns film
    language sql
as
'select *
 from film
 where film_id = id;'

select find_film_by_id(133);

create function find_film_by_id_2(
   id int
) returns film
language sql
as
$$
  select * from film
  where film_id = id;
$$;

select find_film_by_id(133);

