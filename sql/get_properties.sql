SELECT
    id,
    entity,
    type,
    language,
    datatype,
    value_string AS `string`,
    value_integer AS `integer`,
    value_decimal AS `decimal`,
    CASE type
        WHEN '_created' THEN created_at
        WHEN '_deleted' THEN created_at
        ELSE value_date
    END AS `date`,
    CASE type
        WHEN '_created' THEN created_by
        WHEN '_deleted' THEN created_by
        ELSE value_reference
    END AS `reference`,
    created_at,
    created_by,
    deleted_at,
    deleted_by
FROM mongo
WHERE imported = 0
ORDER BY
    entity,
    type,
    language
LIMIT ?;
