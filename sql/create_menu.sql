/* key */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    '_type',
    'reference',
    'menu'
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* name */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_string
) SELECT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    'name',
    CASE language
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    'string',
    LEFT(CONCAT(GROUP_CONCAT(TRIM(value) ORDER BY field DESC SEPARATOR '#@#'),'#@#'), LOCATE('#@#', CONCAT(GROUP_CONCAT(TRIM(value) ORDER BY field DESC SEPARATOR '#@#'),'#@#')) - 1)
FROM translation
WHERE field IN ('label', 'label_plural')
AND entity_definition_keyname IN (
    SELECT entity_definition_keyname
    FROM translation
    WHERE field = 'menu'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname)
GROUP BY
    entity_definition_keyname,
    language;


/* group */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_string
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    'group',
    CASE language
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    'string',
    TRIM(value)
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* query */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    'query',
    'string',
    CONCAT('_type.string=', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '&sort=name.string')
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname)
GROUP BY
    entity_definition_keyname;


/* rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
AND entity_definition_keyname IN (SELECT keyname FROM props_entity_keyname);


/* conf menu */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_string,
    value_integer,
    value_reference
) VALUES
    ('menu_conf_menu', '_type', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_conf_menu', 'name', 'et', 'string', 'Menüü', NULL, NULL),
    ('menu_conf_menu', 'name', 'en', 'string', 'Menu', NULL, NULL),
    ('menu_conf_menu', 'group', 'et', 'string', 'Seaded', NULL, NULL),
    ('menu_conf_menu', 'group', 'en', 'string', 'Configuration', NULL, NULL),
    ('menu_conf_menu', 'query', NULL, 'string', '_type.string=menu&sort=name.string', NULL, NULL),
    ('menu_conf_menu', 'ordinal', NULL, 'integer', NULL, 1000, NULL),

    ('menu_conf_entity', '_type', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_conf_entity', 'name', 'et', 'string', 'Objektid', NULL, NULL),
    ('menu_conf_entity', 'name', 'en', 'string', 'Entities', NULL, NULL),
    ('menu_conf_entity', 'group', 'et', 'string', 'Seaded', NULL, NULL),
    ('menu_conf_entity', 'group', 'en', 'string', 'Configuration', NULL, NULL),
    ('menu_conf_entity', 'query', NULL, 'string', '_type.string=entity&sort=name.string', NULL, NULL),
    ('menu_conf_entity', 'ordinal', NULL, 'integer', NULL, 1000, NULL);


/* conf menu rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    entities.entity,
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
FROM (
    SELECT 'menu_conf_menu' AS entity
    UNION SELECT 'menu_conf_entity'
) AS entities,
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
) AS users;
