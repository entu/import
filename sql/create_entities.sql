/* id */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    e.id,
    '_mid',
    'string',
    e.id
FROM
    entity AS e,
    mongo_entity_keyname AS mek
WHERE mek.keyname = e.entity_definition_keyname;


/* type */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference,
    created_at,
    created_by
) SELECT DISTINCT
    e.id,
    '_type',
    'reference',
    TRIM(LOWER(REPLACE(e.entity_definition_keyname, '-', '_'))),
    e.created,
    IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL)
FROM
    entity AS e,
    mongo_entity_keyname AS mek
WHERE mek.keyname = e.entity_definition_keyname;


/* created at/by */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    created_at,
    created_by
) SELECT DISTINCT
    e.id,
    '_created',
    'atby',
    e.created,
    IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL)
FROM
    entity AS e,
    mongo_entity_keyname AS mek
WHERE mek.keyname = e.entity_definition_keyname
AND (e.created IS NOT NULL OR IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL) IS NOT NULL);


/* deleted at/by */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    created_at,
    created_by
) SELECT DISTINCT
    e.id,
    '_deleted',
    'atby',
    e.deleted,
    IF(TRIM(e.deleted_by) REGEXP '^-?[0-9]+$', TRIM(e.deleted_by), NULL)
FROM
    entity AS e,
    mongo_entity_keyname AS mek
WHERE mek.keyname = e.entity_definition_keyname
AND e.is_deleted = 1;


/* parents */
INSERT INTO mongo (
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
    entity AS e,
    mongo_entity_keyname AS mek
WHERE e.id = r.related_entity_id
AND mek.keyname = e.entity_definition_keyname
AND r.relationship_definition_keyname = 'child';


/* rights */
INSERT INTO mongo (
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
    entity AS e,
    mongo_entity_keyname AS mek
WHERE e.id = r.entity_id
AND r.related_entity_id IS NOT NULL
AND mek.keyname = e.entity_definition_keyname
AND r.relationship_definition_keyname IN ('editor', 'expander', 'owner', 'viewer');


/* sharing */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    e.id,
    '_public',
    'boolean',
    1
FROM
    entity AS e,
    mongo_entity_keyname AS mek
WHERE mek.keyname = e.entity_definition_keyname
AND TRIM(LOWER(e.sharing)) = 'public';
