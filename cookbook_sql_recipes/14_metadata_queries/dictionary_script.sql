WITH vars
AS (
  SELECT
    'public'  AS v_SchemaName -- Set to the schema whose tables you want in the Data Dictionary
    ,'NO'      AS v_TablesOnly -- 'YES'=> Limit To Tables only; 'NO' => Include views too
)

,baseTbl
AS (
  SELECT table_schema AS SchemaName
       , table_catalog
       , table_type
       , table_name
       , table_schema
    FROM INFORMATION_SCHEMA.TABLES
   WHERE table_schema = (SELECT v_SchemaName FROM vars)
     AND ( ( table_type = 'BASE TABLE')
            OR ((SELECT v_TablesOnly FROM vars) = 'NO')
         )
)

,metadata
AS (
  SELECT bt.SchemaName AS schema_nm
       , bt.table_name AS table_nm
       , CASE WHEN bt.table_type = 'BASE TABLE' THEN 'TBL'
              WHEN bt.table_type = 'VIEW' THEN 'VW'
              ELSE 'UK'
         END AS obj_typ
       , tut.ordinal_position AS ord_pos
       , tut.column_name AS column_nm
       , COALESCE(tut.data_type,'unknown') ||
         CASE WHEN tut.data_type IN ('character varying','character')
                   THEN '(' || tut.CHARACTER_MAXIMUM_LENGTH::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('date', 'time') THEN '(3)'
              WHEN tut.data_type = 'datetime' THEN '(8)'
              WHEN tut.data_type = 'timestamp' THEN '(4)'
              WHEN tut.data_type IN ('bigint','integer','smallint')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) || ')'
              WHEN tut.data_type IN ('decimal','numeric')
                   THEN '(' || tut.NUMERIC_PRECISION::VARCHAR(10) ||
                        ',' || tut.NUMERIC_SCALE::VARCHAR(10) || ')'
              ELSE ''
         END AS data_typ
       , CASE WHEN tut.IS_NULLABLE = 'YES'
             THEN 'NULL'
             ELSE 'NOT NULL'
         END AS nullable
       , CASE WHEN LEFT(tut.column_default,8) = 'nextval('
              THEN 'seq_id'
              ELSE tut.column_default
         END AS def_val
   FROM INFORMATION_SCHEMA.COLUMNS AS tut
  INNER JOIN baseTbl bt
     ON bt.table_catalog = tut.table_catalog
    AND bt.table_name = tut.table_name
)
,cat_tables
AS (
  SELECT oid, relkind, relname
    FROM pg_catalog.pg_class
   WHERE relkind IN ('r','v')
)
,metadata_col
AS (
  SELECT m.*,
         CASE WHEN typ.typcategory = 'A' THEN 'Array'
              WHEN typ.typcategory = 'B' THEN 'Boolean'
              WHEN typ.typcategory = 'D' THEN 'Composite'
              WHEN typ.typcategory = 'E' THEN 'Enum'
              WHEN typ.typcategory = 'G' THEN 'Geometric'
              WHEN typ.typcategory = 'I' THEN 'Network address'
              WHEN typ.typcategory = 'N' THEN 'Numeric'
              WHEN typ.typcategory = 'P' THEN 'Pseudo-types'
              WHEN typ.typcategory = 'R' THEN 'Range'
              WHEN typ.typcategory = 'S' THEN 'String'
              WHEN typ.typcategory = 'T' THEN 'Timespan'
              WHEN typ.typcategory = 'U' THEN 'User-defined'
              WHEN typ.typcategory = 'V' THEN 'Bit-string'
              WHEN typ.typcategory = 'X' THEN 'unknown'
         END AS type_ctg
    FROM cat_tables AS t
   INNER JOIN pg_catalog.pg_attribute AS c
      ON t.oid = c.attrelid
   INNER JOIN pg_catalog.pg_type AS typ
      ON typ.oid = c.atttypid
    LEFT JOIN pg_catalog.pg_attrdef AS pgadf
      ON t.oid = pgadf.adrelid AND c.attnum = pgadf.adnum
   INNER JOIN metadata AS m
      ON t.relname  = m.table_nm AND c.attnum = m.ord_pos
   WHERE c.attnum > 0
)


,t
AS (
  SELECT  cons.table_schema AS schema_nm
        , cons.table_name AS table_nm
        , kcu.column_name AS column_nm
        , CASE WHEN cons.constraint_type = 'PRIMARY KEY' THEN 'PK'
               WHEN cons.constraint_type = 'FOREIGN KEY' THEN 'FK'
               WHEN cons.constraint_type = 'UNIQUE' THEN 'UK'
               ELSE 'X'
          END AS is_key
    FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS cons
   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
           ON  cons.table_schema = kcu.table_schema
          AND cons.constraint_name = kcu.constraint_name
          AND cons.table_name = kcu.table_name
   WHERE cons.table_schema = (SELECT v_SchemaName FROM vars)
     AND cons.table_name IN (SELECT DISTINCT table_name FROM baseTbl)
     AND cons.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
   GROUP BY cons.table_schema,
            cons.table_name,
            kcu.column_name,
            cons.constraint_type
)

, meta_for_keys
AS (
  SELECT schema_nm
        , table_nm
        , column_nm
        , STRING_AGG(is_key, ',' ORDER BY is_key) AS is_key
    FROM t
   GROUP BY schema_nm, table_nm, column_nm
)

, meta_ref_fks
AS (
  SELECT tc.table_name
       , kcu.column_name AS column_name
       , tc2.table_name AS ref_table_name
       , kcu2.column_name AS ref_col_name
       , update_rule
       , delete_rule
   FROM information_schema.referential_constraints rc
  INNER JOIN information_schema.table_constraints tc
     ON rc.constraint_name = tc.constraint_name
  INNER JOIN information_schema.table_constraints tc2
     ON rc.unique_constraint_name = tc2.constraint_name
  INNER JOIN information_schema.key_column_usage kcu
     ON rc.constraint_name = kcu.constraint_name
    AND tc.table_name = kcu.table_name
  INNER JOIN information_schema.key_column_usage kcu2
     ON rc.unique_constraint_name = kcu2.constraint_name
    AND tc2.table_name = kcu2.table_name
  INNER JOIN information_schema.columns c
     ON tc.table_name = c.table_name
    AND kcu.column_name = c.column_name
)

SELECT mc.*
     , mk.is_key
     , mfk.ref_table_name AS fk_ref_table
     , mfk.ref_col_name AS fk_ref_col_name
     , mfk.update_rule AS update_rule
     , mfk.delete_rule AS delete_rule
  FROM metadata_col mc
  LEFT JOIN meta_for_keys mk
    ON mc.table_nm = mk.table_nm AND mc.column_nm = mk.column_nm
  LEFT JOIN meta_ref_fks mfk
    ON mc.table_nm = mfk.table_name AND mc.column_nm = mfk.column_name
 ORDER BY 3, 2, 4;
