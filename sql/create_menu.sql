/* key */
INSERT INTO mongo (
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
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* parent (database) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    '_parent',
    'reference',
    CONCAT('database_entity_', ?)
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* sharing - domain */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    '_sharing',
    'string',
    'domain'
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* inherit rights */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_')))),
    '_inheritrights',
    'boolean',
    1
FROM translation
WHERE field = 'menu'
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* name */
INSERT INTO mongo (
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
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname)
GROUP BY
    entity_definition_keyname,
    language;


/* group */
INSERT INTO mongo (
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
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* query */
INSERT INTO mongo (
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
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname)
GROUP BY
    entity_definition_keyname;


/* conf menu */
INSERT INTO mongo (
    entity,
    type,
    language,
    datatype,
    value_string,
    value_integer,
    value_reference
) VALUES
    ('menu_conf_menu', '_type', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_conf_menu', '_parent', NULL, 'reference', NULL, NULL, CONCAT('database_entity_', ?)),
    ('menu_conf_menu', '_sharing', NULL, 'string', NULL, 1, 'domain'),
    ('menu_conf_menu', '_inheritrights', NULL, 'boolean', NULL, 1, NULL),
    ('menu_conf_menu', 'name', 'et', 'string', 'Menüü', NULL, NULL),
    ('menu_conf_menu', 'name', 'en', 'string', 'Menu', NULL, NULL),
    ('menu_conf_menu', 'group', 'et', 'string', 'Seaded', NULL, NULL),
    ('menu_conf_menu', 'group', 'en', 'string', 'Configuration', NULL, NULL),
    ('menu_conf_menu', 'query', NULL, 'string', '_type.string=menu&sort=name.string', NULL, NULL),
    ('menu_conf_menu', 'ordinal', NULL, 'integer', NULL, 1000, NULL),

    ('menu_conf_entity', '_type', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_conf_entity', '_parent', NULL, 'reference', NULL, NULL, CONCAT('database_entity_', ?)),
    ('menu_conf_entity', '_sharing', NULL, 'string', NULL, 1, 'domain'),
    ('menu_conf_entity', '_inheritrights', NULL, 'boolean', NULL, 1, NULL),
    ('menu_conf_entity', 'name', 'et', 'string', 'Objektid', NULL, NULL),
    ('menu_conf_entity', 'name', 'en', 'string', 'Entities', NULL, NULL),
    ('menu_conf_entity', 'group', 'et', 'string', 'Seaded', NULL, NULL),
    ('menu_conf_entity', 'group', 'en', 'string', 'Configuration', NULL, NULL),
    ('menu_conf_entity', 'query', NULL, 'string', '_type.string=entity&system._id.exists=false&sort=name.string', NULL, NULL),
    ('menu_conf_entity', 'ordinal', NULL, 'integer', NULL, 1000, NULL);
