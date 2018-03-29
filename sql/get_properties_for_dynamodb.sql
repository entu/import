SELECT
    NULL AS _id,
    ? AS db,
    entity,
    type,
    language,
    datatype,
    public,
    IF(datatype = 'formula', value_text, NULL) AS formula,
    IF(datatype != 'formula', value_text, NULL) AS `string`,
    value_integer AS `integer`,
    value_decimal AS `decimal`,
    DATE_FORMAT(value_date, '%Y-%m-%dT%TZ') AS `date`,
    CASE type
        WHEN '_created' THEN created_by
        WHEN '_deleted' THEN deleted_by
        ELSE value_reference
    END AS `reference`,
    CASE type
        WHEN '_created' THEN DATE_FORMAT(created_at, '%Y-%m-%dT%TZ')
        WHEN '_deleted' THEN DATE_FORMAT(deleted_at, '%Y-%m-%dT%TZ')
        ELSE NULL
    END AS `at`,
    DATE_FORMAT(created_at, '%Y-%m-%dT%TZ') AS created_at,
    created_by,
    DATE_FORMAT(deleted_at, '%Y-%m-%dT%TZ') AS deleted_at,
    deleted_by
FROM props
ORDER BY
    entity,
    type,
    language,
    type
LIMIT ? OFFSET ?;
