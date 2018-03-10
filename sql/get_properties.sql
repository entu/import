SELECT
    entity,
    type,
    language,
    datatype,
    public,
    formula,
    value_text AS `string`,
    value_integer AS `integer`,
    value_decimal AS `decimal`,
    value_reference AS `reference`,
    value_date AS `date`,
    CASE type
        WHEN '_created' THEN created_by
        WHEN '_deleted' THEN deleted_by
        ELSE NULL
    END AS `by`,
    CASE type
        WHEN '_created' THEN created_at
        WHEN '_deleted' THEN deleted_at
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
