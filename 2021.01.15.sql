CREATE TABLE subscription_history (user_id BIGINT NOT NULL,
                                                  product_id INT NOT NULL,
                                                                 is_active BOOLEAN NOT NULL,
                                                                                   ts TIMESTAMP NOT NULL);


INSERT INTO subscription_history (user_id, product_id, is_active, ts)
SELECT a.n AS user_id,
       round(random() * 3) AS product_id,
       CASE
           WHEN random() < 0.5 THEN FALSE
           ELSE TRUE
       END AS is_active,
       TIMESTAMP '2017-03-01' + random() * interval '2 years' AS ts
FROM generate_series(1, 500000) AS a(n),
     generate_series(1, 5);


SELECT count(*)
FROM subscription_history;


SELECT *
FROM subscription_history
ORDER BY user_id,
         ts
LIMIT 1000;


SELECT a.user_id,
       a.product_id,
       MAX(a.ts) AS last_event_ts,

  (SELECT is_active
   FROM subscription_history b
   WHERE b.ts = MAX(a.ts)
     AND b.user_id = a.user_id
     AND b.product_id = a.product_id ) AS current_status
FROM subscription_history a
WHERE a.user_id < 5
GROUP BY a.user_id,
         a.product_id;


SELECT a.user_id,
       a.product_id,
       a.is_active AS current_status
FROM subscription_history a
WHERE NOT exists
    (SELECT 1
     FROM subscription_history b
     WHERE b.user_id = a.user_id
       AND b.product_id = a.product_id
       AND b.ts > a.ts )
ORDER BY a.user_id,
         a.product_id;


SELECT q.product_id,
       count(DISTINCT q.user_id) AS current_active_users
FROM
  (SELECT a.user_id,
          a.product_id,
          a.is_active AS current_status
   FROM subscription_history a
   WHERE NOT exists
       (SELECT 1
        FROM subscription_history b
        WHERE b.user_id = a.user_id
          AND b.product_id = a.product_id
          AND b.ts > a.ts )) q
WHERE q.current_status
GROUP BY q.product_id;

WITH history AS
  (SELECT a.user_id,
          a.product_id,
          a.is_active AS current_status,
          row_number() OVER (PARTITION BY a.user_id,
                                          a.product_id
                             ORDER BY a.ts DESC) AS rn
   FROM subscription_history a)
SELECT b.product_id,
       count(DISTINCT b.user_id) AS current_active_users
FROM history b
WHERE b.rn = 1
  AND b.current_status
GROUP BY b.product_id;

WITH history AS
  (SELECT a.user_id ,
          a.product_id ,
          a.is_active AS current_status ,
          ROW_NUMBER() OVER (PARTITION BY a.user_id,
                                          a.product_id
                             ORDER BY a.ts DESC) AS rn ,
                            a.ts - LEAD(a.ts) OVER (PARTITION BY a.user_id,
                                                                 a.product_id
                                                    ORDER BY a.ts DESC) AS time_since_last_subscription_change
   FROM subscription_history a)
SELECT b.product_id ,
       COUNT(DISTINCT b.user_id) AS currently_active_users ,
       AVG(time_since_last_subscription_change) AS avg_time_since_last_subscription_change
FROM history b
WHERE b.rn = 1
  AND b.current_status
GROUP BY b.product_id;

WITH history AS
  (SELECT a.user_id ,
          a.product_id ,
          a.is_active AS current_status ,
          ROW_NUMBER() OVER W AS rn ,
                            a.ts - LEAD(a.ts) OVER W AS time_since_last_subscription_change
   FROM subscription_history a WINDOW W AS (PARTITION BY a.user_id,
                                                         a.product_id
                                            ORDER BY a.ts DESC))
SELECT b.product_id ,
       COUNT(DISTINCT b.user_id) AS currently_active_users ,
       AVG(time_since_last_subscription_change) AS avg_time_since_last_subscription_change
FROM history b
WHERE b.rn = 1
  AND b.current_status
GROUP BY b.product_id;

WITH history AS
  (SELECT a.user_id ,
          a.product_id ,
          a.is_active AS current_status ,
          ROW_NUMBER() OVER W AS rn ,
                            a.ts - LEAD(a.ts) OVER W AS time_since_last_subscription_change
   FROM subscription_history a WINDOW W AS (PARTITION BY a.user_id,
                                                         a.product_id
                                            ORDER BY a.ts DESC))
SELECT b.product_id ,
       COUNT(DISTINCT b.user_id) AS currently_active_users ,
       AVG(time_since_last_subscription_change) AS avg_time_since_last_subscription_change
FROM history b
WHERE b.rn = 1
  AND b.current_status
GROUP BY b.product_id;
