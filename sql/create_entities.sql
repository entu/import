/* id */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    id,
    '_mid',
    'string',
    id
FROM entity
WHERE entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* type */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference,
    created_at,
    created_by
) SELECT DISTINCT
    id,
    '_type',
    'reference',
    TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_'))),
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* created at/by */
INSERT INTO props (
    entity,
    type,
    datatype,
    created_at,
    created_by
) SELECT DISTINCT
    id,
    '_created',
    'atby',
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE (created IS NOT NULL OR IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL) IS NOT NULL)
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* deleted at/by */
INSERT INTO props (
    entity,
    type,
    datatype,
    created_at,
    created_by
) SELECT DISTINCT
    id,
    '_deleted',
    'atby',
    deleted,
    IF(TRIM(deleted_by) REGEXP '^-?[0-9]+$', TRIM(deleted_by), NULL)
FROM entity
WHERE is_deleted = 1
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* parents */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference,
    created_at,
    created_by,
    deleted_at,
    deleted_by
) SELECT DISTINCT
    r.related_entity_id,
    '_parent',
    'reference',
    r.entity_id,
    r.created,
    IF(TRIM(r.created_by) REGEXP '^-?[0-9]+$', TRIM(r.created_by), NULL),
    IF(r.is_deleted = 1, IFNULL(r.deleted, NOW()), NULL),
    IF(TRIM(r.deleted_by) REGEXP '^-?[0-9]+$', TRIM(r.deleted_by), NULL)
FROM
    relationship AS r,
    entity AS e
WHERE e.id = r.related_entity_id
AND r.relationship_definition_keyname = 'child'
AND e.entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference,
    created_at,
    created_by,
    deleted_at,
    deleted_by
) SELECT DISTINCT
    r.entity_id,
    CONCAT('_', REPLACE(r.relationship_definition_keyname, '-', '_')),
    'reference',
    r.related_entity_id,
    r.created,
    IF(TRIM(r.created_by) REGEXP '^-?[0-9]+$', TRIM(r.created_by), NULL),
    IF(r.is_deleted = 1, IFNULL(r.deleted, NOW()), NULL),
    IF(TRIM(r.deleted_by) REGEXP '^-?[0-9]+$', TRIM(r.deleted_by), NULL)
FROM
    relationship AS r,
    entity AS e
WHERE e.id = r.entity_id
AND r.relationship_definition_keyname IN ('editor', 'expander', 'owner', 'viewer')
AND e.entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* sharing */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    id,
    '_public',
    'boolean',
    1
FROM entity
WHERE TRIM(LOWER(sharing)) = 'public'
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);
