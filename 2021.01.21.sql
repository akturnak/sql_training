CREATE TABLE t
(
    a float
);

CREATE FUNCTION fill() RETURNS void as
$$
INSERT INTO t
SELECT random()
FROM generate_series(1, 3);
$$ LANGUAGE SQL;

SELECT *
FROM t;

SELECT fill();

SELECT *
FROM t;

CREATE OR REPLACE FUNCTION fill() RETURNS bigint
AS
$$
INSERT INTO t
SELECT random()
FROM generate_series(1, 3);
SELECT count(*)
FROM t;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fill_and_return() RETURNS bigint
AS
$$
INSERT INTO t
SELECT random()
FROM generate_series(1, 3);
SELECT count(*)
FROM t;
$$ LANGUAGE SQL;

SELECT fill_and_return();

CREATE OR REPLACE FUNCTION fill_and_return() RETURNS bigint
AS
$$
TRUNCATE t;
INSERT INTO t
SELECT random()
FROM generate_series(1, 3);
SELECT count(*)
FROM t;
$$ LANGUAGE SQL;

SELECT fill_and_return();

CREATE FUNCTION filler(nrows integer) RETURNS bigint
AS
$$
TRUNCATE t;
INSERT INTO t
SELECT random()
FROM generate_series(1, nrows);
SELECT count(*)
FROM t;
$$ LANGUAGE sql;

SELECT filler(10);
SELECT filler(nrows => 11);

