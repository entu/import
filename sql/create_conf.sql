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

    ('entity_name', '_mid', 'string', 'entity_name', NULL),
    ('entity_name', '_type', 'reference', NULL, 'property'),
    ('entity_name', '_parent', 'reference', NULL, 'entity'),
    ('entity_name', 'name', 'string', 'name', NULL),
    ('entity_name', 'type', 'string', 'string', NULL),

    ('entity_label', '_mid', 'string', 'entity_label', NULL),
    ('entity_label', '_type', 'reference', NULL, 'property'),
    ('entity_label', '_parent', 'reference', NULL, 'entity'),
    ('entity_label', 'name', 'string', 'label', NULL),
    ('entity_label', 'type', 'string', 'string', NULL),

    ('entity_label_plural', '_mid', 'string', 'entity_label_plural', NULL),
    ('entity_label_plural', '_type', 'reference', NULL, 'property'),
    ('entity_label_plural', '_parent', 'reference', NULL, 'entity'),
    ('entity_label_plural', 'name', 'string', 'label_plural', NULL),
    ('entity_label_plural', 'type', 'string', 'string', NULL),

    ('entity_add_from_menu', '_mid', 'string', 'entity_add_from_menu', NULL),
    ('entity_add_from_menu', '_type', 'reference', NULL, 'property'),
    ('entity_add_from_menu', '_parent', 'reference', NULL, 'entity'),
    ('entity_add_from_menu', 'name', 'string', 'add_from_menu', NULL),
    ('entity_add_from_menu', 'type', 'string', 'reference', NULL),

    ('entity_optional_parent', '_mid', 'string', 'entity_optional_parent', NULL),
    ('entity_optional_parent', '_type', 'reference', NULL, 'property'),
    ('entity_optional_parent', '_parent', 'reference', NULL, 'entity'),
    ('entity_optional_parent', 'name', 'string', 'optional_parent', NULL),
    ('entity_optional_parent', 'type', 'string', 'reference', NULL),

    ('entity_allowed_child', '_mid', 'string', 'entity_allowed_child', NULL),
    ('entity_allowed_child', '_type', 'reference', NULL, 'property'),
    ('entity_allowed_child', '_parent', 'reference', NULL, 'entity'),
    ('entity_allowed_child', 'name', 'string', 'allowed_child', NULL),
    ('entity_allowed_child', 'type', 'string', 'reference', NULL),

    ('property', '_mid', 'string', 'property', NULL),
    ('property', '_type', 'reference', NULL, 'property'),
    ('property', 'name', 'string', 'property', NULL),

    ('property_name', '_mid', 'string', 'property_name', NULL),
    ('property_name', '_type', 'reference', NULL, 'property'),
    ('property_name', '_parent', 'reference', NULL, 'property'),
    ('property_name', 'name', 'string', 'name', NULL),
    ('property_name', 'type', 'string', 'string', NULL),

    ('property_label', '_mid', 'string', 'property_label', NULL),
    ('property_label', '_type', 'reference', NULL, 'property'),
    ('property_label', '_parent', 'reference', NULL, 'property'),
    ('property_label', 'name', 'string', 'label', NULL),
    ('property_label', 'type', 'string', 'string', NULL),

    ('property_label_plural', '_mid', 'string', 'property_label_plural', NULL),
    ('property_label_plural', '_type', 'reference', NULL, 'property'),
    ('property_label_plural', '_parent', 'reference', NULL, 'property'),
    ('property_label_plural', 'name', 'string', 'label_plural', NULL),
    ('property_label_plural', 'type', 'string', 'string', NULL),

    ('property_ordinal', '_mid', 'string', 'property_ordinal', NULL),
    ('property_ordinal', '_type', 'reference', NULL, 'property'),
    ('property_ordinal', '_parent', 'reference', NULL, 'property'),
    ('property_ordinal', 'name', 'string', 'ordinal', NULL),
    ('property_ordinal', 'type', 'string', 'integer', NULL),

    ('property_list', '_mid', 'string', 'property_list', NULL),
    ('property_list', '_type', 'reference', NULL, 'property'),
    ('property_list', '_parent', 'reference', NULL, 'property'),
    ('property_list', 'name', 'string', 'list', NULL),
    ('property_list', 'type', 'string', 'boolean', NULL),

    ('property_multilingual', '_mid', 'string', 'property_multilingual', NULL),
    ('property_multilingual', '_type', 'reference', NULL, 'property'),
    ('property_multilingual', '_parent', 'reference', NULL, 'property'),
    ('property_multilingual', 'name', 'string', 'multilingual', NULL),
    ('property_multilingual', 'type', 'string', 'boolean', NULL),

    ('property_public', '_mid', 'string', 'property_public', NULL),
    ('property_public', '_type', 'reference', NULL, 'property'),
    ('property_public', '_parent', 'reference', NULL, 'property'),
    ('property_public', 'name', 'string', 'public', NULL),
    ('property_public', 'type', 'string', 'boolean', NULL),

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
    entities.entity,
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
FROM (
    SELECT 'entity' AS entity
    UNION SELECT 'entity_name'
    UNION SELECT 'entity_label'
    UNION SELECT 'entity_label_plural'
    UNION SELECT 'entity_add_from_menu'
    UNION SELECT 'entity_optional_parent'
    UNION SELECT 'entity_allowed_child'
    UNION SELECT 'property'
    UNION SELECT 'property_name'
    UNION SELECT 'property_label'
    UNION SELECT 'property_label_plural'
    UNION SELECT 'property_ordinal'
    UNION SELECT 'property_list'
    UNION SELECT 'property_multilingual'
    UNION SELECT 'property_public'
    UNION SELECT 'menu'
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
