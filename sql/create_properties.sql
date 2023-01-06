INSERT INTO props (
    entity,
    type,
    datatype,
    language,
    value_string,
    value_integer,
    value_double,
    value_reference,
    value_date,
    created_at,
    created_by,
    deleted_at,
    deleted_by
) SELECT DISTINCT
    p.entity_id,
    IF(
        pd.dataproperty = 'title',
        'name',
        NULLIF(LOWER(TRIM(REPLACE(pd.dataproperty, '-', '_'))), '')
    ),
    NULLIF(LOWER(TRIM(REPLACE(pd.datatype, '-', '_'))), ''),
    CASE IF(pd.multilingual = 1, TRIM(p.language), NULL)
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    CASE pd.datatype
        WHEN 'string' THEN TRIM(p.value_string)
        WHEN 'text' THEN TRIM(p.value_text)
        WHEN 'file' THEN (
            SELECT TRIM(CONCAT(
                'A:',
                IFNULL(TRIM(filename), ''),
                '\nB:',
                IFNULL(TRIM(md5), ''),
                '\nC:',
                IFNULL(TRIM(s3_key), ''),
                '\nD:',
                IFNULL(TRIM(url), ''),
                '\nE:',
                IFNULL(filesize, '')
            )) FROM file WHERE id = p.value_file LIMIT 1
        )
        ELSE NULL
    END,
    CASE pd.datatype
        WHEN 'integer' THEN p.value_integer
        WHEN 'boolean' THEN p.value_boolean
        ELSE NULL
    END,
    CASE pd.datatype
        WHEN 'decimal' THEN p.value_decimal
        ELSE NULL
    END,
    CASE pd.datatype
        WHEN 'reference' THEN p.value_reference
        ELSE NULL
    END,
    CASE pd.datatype
        WHEN 'date' THEN DATE_FORMAT(p.value_datetime, '%Y-%m-%d')
        WHEN 'datetime' THEN DATE_FORMAT(CONVERT_TZ(p.value_datetime, 'Europe/Tallinn', 'UTC'), '%Y-%m-%d %H:%i:%s')
        ELSE NULL
    END,
    IFNULL(IF(p.created >= '2000-01-01', p.created, NULL), IF(e.created >= '2000-01-01', e.created, NULL)),
    IF(TRIM(p.created_by) REGEXP '^-?[0-9]+$', TRIM(p.created_by), IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL)),
    IF(p.is_deleted = 1, IF(p.deleted >= '2000-01-01', p.deleted, NOW()), NULL),
    IF(p.is_deleted = 1, IF(TRIM(p.deleted_by) REGEXP '^-?[0-9]+$', TRIM(p.deleted_by), IF(TRIM(e.deleted_by) REGEXP '^-?[0-9]+$', TRIM(e.deleted_by), NULL)), NULL)
FROM
    property AS p,
    property_definition AS pd,
    entity AS e
WHERE pd.keyname = p.property_definition_keyname
AND e.id = p.entity_id
AND NULLIF(formula < 1, 1) IS NULL
AND pd.dataproperty NOT IN (
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-path',
    'database-ssl-ca',
    'database-user',
    'mongodb'
)
AND pd.keyname NOT LIKE 'conf-%'
AND e.entity_definition_keyname NOT LIKE 'conf-%';
