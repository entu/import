/* conf */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text,
    value_reference
) VALUES
    ('entity', '_mid', 'string', 'entity', NULL),
    ('entity', '_type', 'reference', NULL, 'entity'),
    ('entity', 'name', 'string', 'entity', NULL),
    ('entity', 'allowed_child', 'reference', NULL, 'property'),
    ('entity', 'add_from_menu', 'reference', NULL, 'menu_conf_entity'),
    ('entity', 'optional_parent', 'reference', NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),

    ('property', '_mid', 'string', 'property', NULL),
    ('property', '_type', 'reference', NULL, 'property'),
    ('property', 'name', 'string', 'property', NULL),

    ('menu', '_mid', 'string', 'menu', NULL),
    ('menu', '_type', 'reference', NULL, 'entity'),
    ('menu', 'name', 'string', 'menu', NULL),
    ('menu', 'add_from_menu', 'reference', NULL, 'menu_conf_menu'),
    ('menu', 'optional_parent', 'reference', NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0));


/* conf rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    'entity',
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
) AS users;

INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    'property',
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
) AS users;

INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    'menu',
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
) AS users;
