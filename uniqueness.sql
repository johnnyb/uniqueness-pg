-- - Package based largely on http://en.wikipedia.org/wiki/Pairing_function

CREATE OR REPLACE FUNCTION cantorPair (Decimal, Decimal) RETURNS Decimal AS '
    DECLARE
        cantorA ALIAS FOR $1;
        cantorB ALIAS FOR $2;
    BEGIN
        RETURN floor((((cantorA + cantorB) * (cantorA + cantorB + 1)) / 2) + cantorB);
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION cantorPairBI(BigInt, BigInt) RETURNS BigInt AS '
    DECLARE
        cantorA ALIAS FOR $1;
        cantorB ALIAS FOR $2;
    BEGIN
        RETURN (((cantorA + cantorB) * (cantorA + cantorB + 1)) / 2) + cantorB;
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION cantorUnpair(Decimal) RETURNS Decimal[] AS '
    DECLARE
        cantorZ ALIAS FOR $1;
        cantorW Decimal;
        cantorT Decimal;
        cantorA Decimal;
        cantorB Decimal;
    BEGIN
        cantorW = floor((sqrt((8 * cantorZ) + 1) - 1) / 2);
        cantorT = floor((cantorW * cantorW + cantorW) / 2);
        cantorB = cantorZ - cantorT;
        cantorA = cantorW - cantorB;

        return ARRAY[cantorA, cantorB];
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION cantorUnpairBI(BigInt) RETURNS BIGINT[] AS '
    DECLARE
        cantorZ ALIAS FOR $1;
        cantorW Decimal; -- Decimal because it easily overflows
        cantorT BigInt;
        cantorA BigInt;
        cantorB BigInt;
    BEGIN
        cantorW = floor((sqrt((8 * cantorZ) + 1) - 1) / 2);
        cantorT = floor((cantorW * cantorW + cantorW) / 2);
        cantorB = cantorZ - cantorT;
        cantorA = cantorW - cantorB;

        return ARRAY[cantorA, cantorB];
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION cantorTuple(BIGINT[]) RETURNS DECIMAL AS '
    DECLARE
        cantorAry ALIAS FOR $1;
        tmpval DECIMAL;
        tmplen INT;
    BEGIN
         tmplen = array_length(cantorAry, 1);
         IF tmplen = 0 THEN
           RETURN 0;
         END IF;
         IF tmplen = 1 THEN
           RETURN cantorAry[1];
         END IF; 
         return cantorPair(cantorAry[1], cantorTuple(cantorAry[2:tmplen]));
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION cantorUntuple(DECIMAL, INT) RETURNS DECIMAL[] AS '
    DECLARE
        cantorNumber ALIAS FOR $1;
        numNumbers ALIAS FOR $2;
        tmpAry DECIMAL[];
    BEGIN
        IF numNumbers = 1 THEN
            RETURN cantorNumber;
        END IF;
        tmpAry = cantorUnpair(cantorNumber);
        IF numNumbers = 2 THEN
            RETURN tmpAry;
        END IF;
        RETURN tmpAry[1] || cantorUntuple(tmpAry[2], numNumbers - 1);
        
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION uniquenessSpace(BIGINT, INT, INT) RETURNS BIGINT AS '
    DECLARE
        key ALIAS FOR $1;
        numTables ALIAS FOR $2;
        tableIndex ALIAS FOR $3;
    BEGIN
        return key * numTables + tableIndex;
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION uniquenessUnspace(BIGINT, INT, INT) RETURNS BIGINT AS '
    DECLARE
        scopedKey ALIAS FOR $1;
        numTables ALIAS FOR $2;
        tableIndex ALIAS FOR $3;
    BEGIN
        return floor((scopedKey - tableIndex) / numTables);
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION uniquenessSpace(DECIMAL, DECIMAL) RETURNS DECIMAL AS '
    DECLARE
        key ALIAS FOR $1;
        tableIndex ALIAS FOR $2; -- FIXME - this needs to be converted to the nth PRIME
    BEGIN
        return floor(tableIndex ^ key);
    END;
' LANGUAGE 'plpgsql' IMMUTABLE;
