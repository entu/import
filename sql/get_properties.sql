SELECT
    entity,
    type,
    language,
    datatype,
    public,
    search,
    IF(datatype = 'formula', value_text, NULL) AS formula,
    IF(datatype != 'formula', value_text, NULL) AS `string`,
    value_integer AS `integer`,
    value_decimal AS `decimal`,
    CASE type
        WHEN '_created' THEN created_at
        WHEN '_deleted' THEN deleted_at
        ELSE value_date
    END AS `date`,
    CASE type
        WHEN '_created' THEN created_by
        WHEN '_deleted' THEN deleted_by
        ELSE value_reference
    END AS `reference`,
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
