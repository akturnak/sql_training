create table data_series
(
    id   serial primary key,
    date timestamptz
);

insert into data_series (date)
values ('2010-11-26 00:00:00'),
       ('2010-11-27 00:00:00'),
       ('2010-11-27 10:00:00'),

       ('2010-11-29 00:00:00'),
       ('2010-11-30 00:00:00'),
       ('2010-12-01 00:00:00'),
       ('2010-12-02 00:00:00'),
       ('2010-12-03 00:00:00'),

       ('2010-12-05 00:00:00'),
       ('2010-12-06 00:00:00'),
       ('2010-12-07 00:00:00'),
       ('2010-12-08 00:00:00'),
       ('2010-12-09 00:00:00'),
       ('2010-12-09 11:00:00'),

       ('2010-12-13 00:00:00'),
       ('2010-12-14 00:00:00'),
       ('2010-12-15 00:00:00')
;

select * from data_series;

select distinct date::date
from data_series
order by 1;

SELECT ROW_NUMBER() OVER (ORDER BY date) AS row_number,
       date::date
FROM data_series;

select - (2 || ' day')::INTERVAL;

WITH

    -- This table contains all the distinct date
    -- instances in the data set
    dates(date) AS (
        SELECT DISTINCT date::date
        FROM data_series
    ),

    -- Generate "groups" of dates by subtracting the
    -- date's row number (no gaps) from the date itself
    -- (with potential gaps). Whenever there is a gap,
    -- there will be a new group
    groups AS (
        SELECT ROW_NUMBER() OVER (ORDER BY date)                                      AS rn,
               (date - (ROW_NUMBER() OVER (ORDER BY date) || ' day')::INTERVAL)::date AS grp,
               date
        FROM dates
    )
SELECT COUNT(*)  AS consecutiveDates,
       MIN(date) AS minDate,
       MAX(date) AS maxDate
FROM groups
GROUP BY grp
ORDER BY 1 DESC, 2 DESC;

WITH groups(date, grp) AS (
    SELECT DISTINCT date::date,
                    (date::date - (DENSE_RANK() OVER (ORDER BY date::date) || ' day')::interval)::date AS grp
    FROM data_series
)
SELECT COUNT(*)  AS consecutiveDates,
       MIN(date) AS minDate,
       MAX(date) AS maxDate
FROM groups
GROUP BY grp
ORDER BY 1 DESC, 2 DESC;

SELECT RANK() OVER (ORDER BY date) AS row_number,
       date::date
FROM data_series;

SELECT DENSE_RANK() OVER (ORDER BY date) AS row_number,
       date::date
FROM data_series;

