SELECT
    id,
    entity,
    type,
    language,
    datatype,
    public,
    IF(datatype = 'formula', value_text, NULL) AS formula,
    IF(datatype != 'formula', value_text, NULL) AS `string`,
    value_integer AS `integer`,
    value_decimal AS `decimal`,
    UNIX_TIMESTAMP(value_date) AS `date`,
    CASE type
        WHEN '_created' THEN created_by
        WHEN '_deleted' THEN deleted_by
        ELSE value_reference
    END AS `reference`,
    CASE type
        WHEN '_created' THEN UNIX_TIMESTAMP(created_at)
        WHEN '_deleted' THEN UNIX_TIMESTAMP(deleted_at)
        ELSE NULL
    END AS `at`,
    created_at,
    created_by,
    deleted_at,
    deleted_by
FROM props
ORDER BY
    entity,
    type,
    language,
    type
LIMIT ? OFFSET ?;
