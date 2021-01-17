
DROP TABLE IF EXISTS sales;


CREATE TABLE sales (brand varchar NOT NULL,
                                  SEGMENT varchar NOT NULL,
                                                  quantity int NOT NULL,
                                                               PRIMARY KEY (brand,
                                                                            SEGMENT));


INSERT INTO sales (brand, SEGMENT, quantity)
VALUES ('ABC', 'Premium', 100),
       ('ABC', 'Basic', 200),
       ('XYZ', 'Premium', 100),
       ('XYZ', 'Basic', 300);


SELECT brand,
       SEGMENT,
       sum(quantity)
FROM sales
GROUP BY ROLLUP (brand,
                 SEGMENT)
ORDER BY brand,
         SEGMENT;


SELECT SEGMENT,
       brand,
       sum(quantity)
FROM sales
GROUP BY ROLLUP (SEGMENT,
                 brand)
ORDER BY SEGMENT,
         brand;


SELECT SEGMENT,
       brand,
       sum(quantity)
FROM sales
GROUP BY SEGMENT,
         ROLLUP (brand)--     brand
ORDER BY SEGMENT,
         brand;


SELECT extract(YEAR
               FROM rental_date) y,
       extract(MONTH
               FROM rental_date) m,
       extract(DAY
               FROM rental_date) d,
       count(rental_id)
FROM rental
GROUP BY ROLLUP (extract(YEAR
                         FROM rental_date),
                 extract(MONTH
                         FROM rental_date),
                 extract(DAY
                         FROM rental_date));


SELECT extract(YEAR
               FROM rental_date) y,
       extract(MONTH
               FROM rental_date) m,
       extract(DAY
               FROM rental_date) d,
       count(rental_id)
FROM rental
GROUP BY ROLLUP (y,
                 m,
                 d)
ORDER BY y,
         m,
         d;


SELECT extract(YEAR
               FROM rental_date) y,
       extract(MONTH
               FROM rental_date) m,
       extract(DAY
               FROM rental_date) d,
       sum(amount)
FROM rental
INNER JOIN payment USING (rental_id)
GROUP BY ROLLUP (y,
                 m,
                 d)
ORDER BY y,
         m,
         d;


SELECT CASE
           WHEN brand NOTNULL THEN brand
           ELSE '<ALL BRANDS>'
       END AS brand,
       CASE
           WHEN SEGMENT NOTNULL THEN SEGMENT
           ELSE '<ALL SEGMENTS>'
       END AS SEGMENT,
       sum(quantity)
FROM sales
GROUP BY ROLLUP (brand,
                 SEGMENT)
ORDER BY brand,
         SEGMENT;
