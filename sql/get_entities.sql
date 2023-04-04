SELECT
    entity AS oid,
    MIN(created_at) AS created_at
FROM mongo
GROUP BY entity
ORDER BY entity;
