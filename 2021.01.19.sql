SELECT '1'::jsonb;
SELECT 'false'::jsonb;
SELECT '"value"'::jsonb;
SELECT '{"attribute": "value"}'::jsonb;
SELECT $JSON$
{
"attribute":"value",
"nested": {"nested_attribute":"nested value"}
}
    $JSON$::jsonb;

SELECT jsonb_pretty('{
  "attribute": "value",
  "nested": {"nested_attribute": "nested value"}
}'::jsonb);


\set record '{"key": "value", "nested": {"key": "nested value"}}'
\echo 'Operator -> Get JSON object field by key or index'

select jsonb_pretty((:'record')::jsonb) record;
select
'record->''key''' as access,
(:'record')::jsonb->'key' as value,
pg_typeof((:'record')::jsonb->'key');

select
'record->''nested''' as access,
(:'record')::jsonb->'nested'  as value,
pg_typeof((:'record')::jsonb->'nested');

----
-- ->>

\set record '{"key": "value", "nested": {"key": "nested value"}}'
\echo 'Operator ->> Get JSON object field or array element as text'
select jsonb_pretty((:'record')::jsonb) record;

select
'record->>''key''' as access,
(:'record')::jsonb->>'key' as value,
pg_typeof((:'record')::jsonb->>'key');

select
'record->>''nested'''          as access,
(:'record')::jsonb->>'nested'  as value,
pg_typeof((:'record')::jsonb->>'nested');

----
-- #>
\set record '{"key": "value", "nested": {"key": "nested value"}}'
\echo 'Operator #> Get JSON object at specified path'
select jsonb_pretty((:'record')::jsonb) record;

select
'record#>''{nested,key}''' as access,
(:'record')::jsonb#>'{nested,key}' as value,
pg_typeof((:'record')::jsonb#>'{nested,key}');
----
-- #>>

\set record '{"key": "value", "nested": {"key": "nested value"}}'
\echo 'Operator #>> Get JSON object at specified path as text'
select jsonb_pretty((:'record')::jsonb) record;

select
'record#>>''{nested,key}''' as access,
(:'record')::jsonb#>>'{nested,key}' as value,
pg_typeof((:'record')::jsonb#>>'{nested,key}');
----

-- Read
-- equivalent to #> operator
select jsonb_extract_path(
'{"attr": "value", "nested": {"foo": "bar"}}'::jsonb, 'nested', 'foo'
);

-- equivalent to #>> operator
select jsonb_extract_path_text(
'{"attr": "value", "nested": {"foo": "bar"}}'::jsonb, 'nested', 'foo'
);


