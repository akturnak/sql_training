select name, installed_version, comment
from pg_available_extensions
where name like 'pl%';

DO 'BEGIN END;';

DO
$$
    DECLARE
/*
 Тестовый комментарий
 */
        var1 text;
        var2 text := 'World';
    BEGIN
        -- one line comment
        var1 := 'Hello';
        RAISE NOTICE '%, %!', var1, var2;
    END;
$$;

CREATE FUNCTION fmt_in(IN phone text) RETURNS text
AS
$$
BEGIN
    IF phone ~ '^[0-9]*$' AND length(phone) = 10 THEN
        RETURN '+7(' || substr(phone, 1, 3) || ')'
                   || substr(phone, 4, 3) || '-'
                   || substr(phone, 4, 2) || '-'
            || substr(phone, 9);
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT fmt_in('789');
SELECT fmt_in('9899876541');

CREATE FUNCTION fmt_out(IN phone text, OUT retval text)
AS
$$
BEGIN
    retval := fmt_in(phone);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT fmt_out('1234567897');

CREATE FUNCTION fmt_inout(INOUT phone text)
AS
$$
BEGIN
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT fmt_inout('1234567891');

CREATE FUNCTION reverse_for(line text) RETURNS text
AS
$$
DECLARE
    line_length CONSTANT int  = length(line);
    retval               text := '';
BEGIN
    FOR i IN 1 .. line_length
        LOOP
            retval := substr(line, i, 1) || retval;
        END LOOP;
    RETURN retval;
END;
$$
    LANGUAGE plpgsql
    IMMUTABLE
    STRICT;

SELECT reverse_for('АБЫРВАЛг');

