/* Fix invalid dates */
UPDATE entity SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE entity SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE entity SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';

UPDATE property SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET value_datetime = NULL WHERE CAST(value_datetime AS CHAR(20)) = '0000-00-00 00:00:00';

UPDATE relationship SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE relationship SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE relationship SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';

/* create props table */
DROP TABLE IF EXISTS props;
CREATE TABLE `props` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `entity` varchar(64) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `language` varchar(2) DEFAULT NULL,
  `datatype` varchar(16) DEFAULT NULL,
  `public` int(1) DEFAULT NULL,
  `search` int(1) DEFAULT NULL,
  `value_text` text DEFAULT NULL,
  `value_integer` int(11) DEFAULT NULL,
  `value_decimal` decimal(15,4) DEFAULT NULL,
  `value_reference` varchar(64) DEFAULT NULL,
  `value_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `entity` (`entity`),
  KEY `type` (`type`),
  KEY `language` (`language`),
  KEY `datatype` (`datatype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* entity id */
INSERT INTO props (entity, type, datatype, value_text, created_at, created_by)
SELECT
    id,
    '_mid',
    'string',
    id,
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE entity_definition_keyname NOT LIKE 'conf-%';


/* entity type */
INSERT INTO props (entity, type, datatype, value_reference, created_at, created_by)
SELECT
    id,
    '_type',
    'reference',
    TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_'))),
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE entity_definition_keyname NOT LIKE 'conf-%';


/* entity name formula */
INSERT INTO props (entity, type, datatype, search, language, value_text)
SELECT
    entity.id AS entity_id,
    'name' AS property_definition,
    'formula' AS property_type,
    1 AS search,
    CASE language
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END AS property_language,
    REPLACE(TRIM(value), '@title@', '@name@') AS value_text
FROM translation
LEFT JOIN entity ON entity.entity_definition_keyname = translation.entity_definition_keyname
WHERE translation.entity_definition_keyname NOT LIKE 'conf-%'
AND translation.entity_definition_keyname NOT IN (SELECT entity_definition_keyname FROM property_definition WHERE dataproperty IN ('name', 'title'))
AND field = 'displayname'
AND translation.entity_definition_keyname IS NOT NULL
AND entity.id IS NOT NULL;


/* entity created at/by */
INSERT INTO props (entity, type, datatype, created_at, created_by)
SELECT
    id,
    '_created',
    'atby',
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE entity_definition_keyname NOT LIKE 'conf-%'
AND (created IS NOT NULL OR IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL) IS NOT NULL);


/* entity deleted at/by */
INSERT INTO props (entity, type, datatype, created_at, created_by)
SELECT
    id,
    '_deleted',
    'atby',
    deleted,
    IF(TRIM(deleted_by) REGEXP '^-?[0-9]+$', TRIM(deleted_by), NULL)
FROM entity
WHERE entity_definition_keyname NOT LIKE 'conf-%'
AND is_deleted = 1;


/* parents */
INSERT INTO props (entity, type, datatype, value_reference, created_at, created_by, deleted_at, deleted_by)
SELECT
    r.related_entity_id,
    '_parent',
    'reference',
    r.entity_id,
    IFNULL(r.created, e.created),
    IF(TRIM(r.created_by) REGEXP '^-?[0-9]+$', TRIM(r.created_by), IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL)),
    IF(r.is_deleted = 1, IFNULL(r.deleted, NOW()), NULL),
    IF(TRIM(r.deleted_by) REGEXP '^-?[0-9]+$', TRIM(r.deleted_by), IF(TRIM(e.deleted_by) REGEXP '^-?[0-9]+$', TRIM(e.deleted_by), NULL))
FROM
    relationship AS r,
    entity AS e
WHERE e.id = r.related_entity_id
AND r.relationship_definition_keyname = 'child';


/* rights */
INSERT INTO props (entity, type, datatype, value_reference, created_at, created_by, deleted_at, deleted_by)
SELECT
    r.entity_id,
    CONCAT('_', REPLACE(r.relationship_definition_keyname, '-', '_')),
    'reference',
    r.related_entity_id,
    IFNULL(r.created, e.created),
    IF(TRIM(r.created_by) REGEXP '^-?[0-9]+$', TRIM(r.created_by), IF(TRIM(e.created_by) REGEXP '^-?[0-9]+$', TRIM(e.created_by), NULL)),
    IF(r.is_deleted = 1, IFNULL(r.deleted, NOW()), NULL),
    IF(TRIM(r.deleted_by) REGEXP '^-?[0-9]+$', TRIM(r.deleted_by), IF(TRIM(e.deleted_by) REGEXP '^-?[0-9]+$', TRIM(e.deleted_by), NULL))
FROM
    relationship AS r,
    entity AS e
WHERE e.id = r.entity_id
AND r.relationship_definition_keyname IN ('editor', 'expander', 'owner', 'viewer');


/* entity sharing */
INSERT INTO props (entity, type, datatype, value_integer, created_at, created_by)
SELECT
    id,
    '_public',
    'boolean',
    1,
    created,
    IF(TRIM(created_by) REGEXP '^-?[0-9]+$', TRIM(created_by), NULL)
FROM entity
WHERE entity_definition_keyname NOT LIKE 'conf-%'
AND TRIM(LOWER(sharing)) = 'public'
AND sharing IS NOT NULL;


/* properties */
INSERT INTO props (entity, type, datatype, language, public, search, value_text, value_integer, value_decimal, value_reference, value_date, created_at, created_by, deleted_at, deleted_by)
SELECT
    p.entity_id,
    IF(
        pd.dataproperty = 'title',
        'name',
        REPLACE(pd.dataproperty, '-', '_')
    ),
    IF(
        pd.formula = 1,
        'formula',
        pd.datatype
    ),
    CASE IF(pd.multilingual = 1, TRIM(p.language), NULL)
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    pd.public,
    pd.search,
    IF(
        pd.formula = 1,
        pd.defaultvalue,
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
        END
    ),
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


/* definitions */
INSERT INTO props (entity, type, language, datatype, public, value_text, value_integer, value_reference)
SELECT
    NULLIF(LOWER(TRIM(REPLACE(entity_id, '-', '_'))), '') AS entity,
    NULLIF(LOWER(TRIM(REPLACE(property_definition, '-', '_'))), '') AS type,
    NULLIF(LOWER(TRIM(property_language)), '') AS language,
    NULLIF(LOWER(TRIM(property_type)), '') AS datatype,
    1 AS public,
    NULLIF(TRIM(value_text), '') AS value_text,
    NULLIF(TRIM(value_integer), '') AS value_integer,
    NULLIF(TRIM(value_reference), '') AS value_reference
FROM (

    /* entity id */
    SELECT
        keyname AS entity_id,
        '_mid' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        LOWER(REPLACE(keyname, '-', '_')) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM entity_definition
    WHERE keyname NOT LIKE 'conf-%'

    /* entity key */
    UNION SELECT
        keyname AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        LOWER(REPLACE(keyname, '-', '_')) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM entity_definition
    WHERE keyname NOT LIKE 'conf-%'

    /* entity type */
    UNION SELECT
        keyname AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'entity' AS value_reference
    FROM entity_definition
    WHERE keyname NOT LIKE 'conf-%'

    /* entity rights */
    UNION SELECT
        keyname AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM
        entity_definition,
        (
            SELECT
                entity.id,
                property.value_string AS user
            FROM
                property,
                entity,
                property_definition
            WHERE entity.id = property.entity_id
            AND property_definition.keyname = property_definition_keyname
            AND property.is_deleted = 0
            AND entity.is_deleted = 0
            AND property_definition.dataproperty = 'entu-user'
        ) AS users
    WHERE keyname NOT LIKE 'conf-%'

    /* entity open-after-add properties */
    UNION SELECT
        keyname AS entity_id,
        'open-after-add' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM entity_definition
    WHERE keyname NOT LIKE 'conf-%'
    AND open_after_add = 1

    /* entity add-action properties */
    UNION SELECT
        keyname AS entity_id,
        'add-action' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        actions_add AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM entity_definition
    WHERE keyname NOT LIKE 'conf-%'
    AND actions_add IS NOT NULL

    /* entity translation (label, label_plural, ...) fields */
    UNION SELECT
        entity_definition_keyname AS entity_id,
        TRIM(field) AS property_definition,
        'string' AS property_type,
        CASE language
            WHEN 'estonian' THEN 'et'
            WHEN 'english' THEN 'en'
            ELSE NULL
        END AS property_language,
        REPLACE(TRIM(value), '@title@', '@name@') AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM translation
    WHERE entity_definition_keyname NOT LIKE 'conf-%'
    AND field NOT IN ('public', 'menu', 'displayname')
    AND entity_definition_keyname IS NOT NULL

    /* entity allowed-child, default-parent, optional-parent */
    UNION SELECT
        entity_definition_keyname,
        relationship_definition_keyname AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        IFNULL(related_entity_id, LOWER(REPLACE(related_entity_definition_keyname, '-', '_'))) AS value_reference
    FROM relationship
    WHERE entity_definition_keyname IS NOT NULL
    AND relationship_definition_keyname IN ('allowed-child', 'default-parent', 'optional-parent')

    /* entity add from menu */
    UNION SELECT
        entity_definition_keyname,
        'add_from_menu' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS value_reference
    FROM relationship
    WHERE relationship_definition_keyname = 'optional-parent'
    AND is_deleted = 0
    GROUP BY
        entity_definition_keyname


    /* property key */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        IF(
            dataproperty = 'title',
            'name',
            LOWER(REPLACE(dataproperty, '-', '_'))
        ) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)

    /* property type */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'property' AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)

    /* property rights */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM
        property_definition,
        (
            SELECT
                entity.id,
                property.value_string AS user
            FROM
                property,
                entity,
                property_definition
            WHERE entity.id = property.entity_id
            AND property_definition.keyname = property_definition_keyname
            AND property.is_deleted = 0
            AND entity.is_deleted = 0
            AND property_definition.dataproperty = 'entu-user'
        ) AS users
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)

    /* property parent entity */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        '_parent' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        LOWER(REPLACE(entity_definition_keyname, '-', '_')) AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)

    /* property datatype */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'type' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        LOWER(datatype) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)

    /* property default value */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'default' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        defaultvalue AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(formula < 1, 1) IS NULL
    AND defaultvalue IS NOT NULL

    /* property is formula */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'formula' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        defaultvalue AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(formula < 1, 1) IS NOT NULL

    /* property is hidden */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'hidden' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND visible = 0

    /* property ordinal */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'ordinal' AS property_definition,
        'integer' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        ordinal AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND ordinal IS NOT NULL

    /* property is multilingual */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'multilingual' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(multilingual < 1, 1) IS NOT NULL

    /* property is list */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'list' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(multiplicity < 1, 1) IS NULL

    /* property is readonly */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'readonly' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(readonly < 1, 1) IS NOT NULL
    AND NULLIF(formula < 1, 1) IS NULL

    /* property is public */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'public' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(public < 1, 1) IS NOT NULL

    /* property is mandatory */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'mandatory' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(mandatory < 1, 1) IS NOT NULL

    /* property is searchable */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'search' AS property_definition,
        'boolean' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        1 AS value_integer,
        NULL AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND NULLIF(search < 1, 1) IS NOT NULL

    /* property has classifier (reference property) */
    UNION SELECT
        CONCAT(entity_definition_keyname, '_', dataproperty) AS entity_id,
        'classifier' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        NULLIF(LOWER(TRIM(REPLACE(classifying_entity_definition_keyname, '-', '_'))), '') AS value_reference
    FROM property_definition
    WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND classifying_entity_definition_keyname IS NOT NULL

    /* property translation (label, ...) fields */
    UNION SELECT
        CONCAT(pd.entity_definition_keyname, '_', pd.dataproperty) AS entity_id,
        TRIM(t.field) AS property_definition,
        'string' AS property_type,
        CASE t.language
            WHEN 'estonian' THEN 'et'
            WHEN 'english' THEN 'en'
            ELSE NULL
        END AS property_language,
        TRIM(t.value) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM
        translation AS t,
        property_definition AS pd
    WHERE pd.keyname = t.property_definition_keyname
    AND t.property_definition_keyname NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
    AND pd.entity_definition_keyname NOT LIKE 'conf-%'
    AND pd.entity_definition_keyname IN (SELECT keyname FROM entity_definition)
    AND t.property_definition_keyname IS NOT NULL

    /* menu key */
    UNION SELECT
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'menu' AS value_reference
    FROM translation
    WHERE field = 'menu'
    AND entity_definition_keyname NOT LIKE 'conf-%'

    /* menu rights */
    UNION SELECT
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM
        translation,
        (
            SELECT
                entity.id,
                property.value_string AS user
            FROM
                property,
                entity,
                property_definition
            WHERE entity.id = property.entity_id
            AND property_definition.keyname = property_definition_keyname
            AND property.is_deleted = 0
            AND entity.is_deleted = 0
            AND property_definition.dataproperty = 'entu-user'
        ) AS users
    WHERE field = 'menu'
    AND entity_definition_keyname NOT LIKE 'conf-%'

    /* menu group */
    UNION SELECT
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS entity_id,
        'group' AS property_definition,
        'string' AS property_type,
        CASE language
            WHEN 'estonian' THEN 'et'
            WHEN 'english' THEN 'en'
            ELSE NULL
        END AS property_language,
        TRIM(value) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM translation
    WHERE field = 'menu'
    AND entity_definition_keyname NOT LIKE 'conf-%'

    /* menu name */
    UNION SELECT
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        CASE language
            WHEN 'estonian' THEN 'et'
            WHEN 'english' THEN 'en'
            ELSE NULL
        END AS property_language,
        LEFT(CONCAT(GROUP_CONCAT(TRIM(value) ORDER BY field DESC SEPARATOR '#@#'),'#@#'), LOCATE('#@#', CONCAT(GROUP_CONCAT(TRIM(value) ORDER BY field DESC SEPARATOR '#@#'),'#@#')) - 1) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM translation
    WHERE field IN ('label', 'label_plural')
    AND entity_definition_keyname NOT LIKE 'conf-%'
    GROUP BY
        entity_definition_keyname,
        language

    /* menu query */
    UNION SELECT
        CONCAT('menu_', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS entity_id,
        'query' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        CONCAT('_type.string=', TRIM(LOWER(REPLACE(entity_definition_keyname, '-', '_')))) AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    FROM translation
    WHERE field = 'menu'
    AND entity_definition_keyname NOT LIKE 'conf-%'
    GROUP BY
        entity_definition_keyname

    /* conf menu key */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'menu' AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'menu' AS value_reference

    /* conf menu rights */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM (
        SELECT
            entity.id,
            property.value_string AS user
        FROM
            property,
            entity,
            property_definition
        WHERE entity.id = property.entity_id
        AND property_definition.keyname = property_definition_keyname
        AND property.is_deleted = 0
        AND entity.is_deleted = 0
        AND property_definition.dataproperty = 'entu-user'
    ) AS users
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM (
        SELECT
            entity.id,
            property.value_string AS user
        FROM
            property,
            entity,
            property_definition
        WHERE entity.id = property.entity_id
        AND property_definition.keyname = property_definition_keyname
        AND property.is_deleted = 0
        AND entity.is_deleted = 0
        AND property_definition.dataproperty = 'entu-user'
    ) AS users

    /* conf menu group */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'group' AS property_definition,
        'string' AS property_type,
        'et' property_language,
        'Seaded' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'group' AS property_definition,
        'string' AS property_type,
        'et' property_language,
        'Seaded' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'group' AS property_definition,
        'string' AS property_type,
        'en' property_language,
        'Configuration' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'group' AS property_definition,
        'string' AS property_type,
        'en' property_language,
        'Configuration' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    /* conf menu name */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        'et' property_language,
        'Objektid' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        'et' property_language,
        'Menüü' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        'en' property_language,
        'Entities' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        'en' property_language,
        'Menu' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    /* conf menu query */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'query' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        '_type.string=entity' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'query' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        '_type.string=menu' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    /* conf menu ordinal */
    UNION SELECT
        'menu_conf_entity' AS entity_id,
        'ordinal' AS property_definition,
        'integer' AS property_type,
        NULL property_language,
        NULL AS value_text,
        1000 AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu_conf_menu' AS entity_id,
        'ordinal' AS property_definition,
        'integer' AS property_type,
        NULL property_language,
        NULL AS value_text,
        1000 AS value_integer,
        NULL AS value_reference


    /* entity_definition */
    UNION SELECT
        'entity' AS entity_id,
        '_mid' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        'entity' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'entity' AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'entity' AS value_reference
    UNION SELECT
        'entity' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        'entity' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'entity' AS entity_id,
        'allowed_child' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'property' AS value_reference
    UNION SELECT
        'entity' AS entity_id,
        'add_from_menu' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'menu_conf_entity' AS value_reference
    UNION SELECT
        'entity' AS entity_id,
        'optional_parent' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0) AS value_reference

    UNION SELECT
        'entity' AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM (
        SELECT
            entity.id,
            property.value_string AS user
        FROM
            property,
            entity,
            property_definition
        WHERE entity.id = property.entity_id
        AND property_definition.keyname = property_definition_keyname
        AND property.is_deleted = 0
        AND entity.is_deleted = 0
        AND property_definition.dataproperty = 'entu-user'
    ) AS users

    /* property_definition */
    UNION SELECT
        'property' AS entity_id,
        '_mid' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        'property' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'property' AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'property' AS value_reference
    UNION SELECT
        'property' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        'property' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference

    UNION SELECT
        'property' AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM (
        SELECT
            entity.id,
            property.value_string AS user
        FROM
            property,
            entity,
            property_definition
        WHERE entity.id = property.entity_id
        AND property_definition.keyname = property_definition_keyname
        AND property.is_deleted = 0
        AND entity.is_deleted = 0
        AND property_definition.dataproperty = 'entu-user'
    ) AS users

    /* menu_definition */
    UNION SELECT
        'menu' AS entity_id,
        '_mid' AS property_definition,
        'string' AS property_type,
        NULL property_language,
        'menu' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu' AS entity_id,
        '_type' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'entity' AS value_reference
    UNION SELECT
        'menu' AS entity_id,
        'name' AS property_definition,
        'string' AS property_type,
        NULL AS property_language,
        'menu' AS value_text,
        NULL AS value_integer,
        NULL AS value_reference
    UNION SELECT
        'menu' AS entity_id,
        'add_from_menu' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        'menu_conf_menu' AS value_reference
    UNION SELECT
        'menu' AS entity_id,
        'optional_parent' AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0) AS value_reference

    UNION SELECT
        'menu' AS entity_id,
        CASE TRIM(users.user)
            WHEN 'argoroots@gmail.com' THEN '_owner'
            WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
            ELSE '_viewer'
        END AS property_definition,
        'reference' AS property_type,
        NULL AS property_language,
        NULL AS value_text,
        NULL AS value_integer,
        users.id AS value_reference
    FROM (
        SELECT
            entity.id,
            property.value_string AS user
        FROM
            property,
            entity,
            property_definition
        WHERE entity.id = property.entity_id
        AND property_definition.keyname = property_definition_keyname
        AND property.is_deleted = 0
        AND entity.is_deleted = 0
        AND property_definition.dataproperty = 'entu-user'
    ) AS users

) AS x
WHERE NULLIF(TRIM(entity_id), '') IS NOT NULL
ORDER BY
    entity_id,
    property_definition,
    property_language,
    property_type;


OPTIMIZE TABLE props;
