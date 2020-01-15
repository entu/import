/* conf */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text,
    value_integer,
    value_reference
) VALUES
    ('entity', '_mid', 'string', 'entity', NULL, NULL),
    ('entity', '_type', 'reference', NULL, NULL, 'entity'),
    ('entity', 'name', 'string', 'entity', NULL, NULL),
    ('entity', 'label', 'string', 'Entity', NULL, NULL),
    ('entity', 'label_plural', 'string', 'Entities', NULL, NULL),
    ('entity', 'allowed_child', 'reference', NULL, NULL, 'property'),
    ('entity', 'add_from_menu', 'reference', NULL, NULL, 'menu_conf_entity'),
    ('entity', 'optional_parent', 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),
    ('entity', 'open_after_add', 'boolean', NULL, 1, NULL),

    ('entity_name', '_mid', 'string', 'entity_name', NULL, NULL),
    ('entity_name', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_name', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_name', 'name', 'string', 'name', NULL, NULL),
    ('entity_name', 'label', 'string', 'Name', NULL, NULL),
    ('entity_name', 'type', 'string', 'string', NULL, NULL),
    ('entity_name', 'ordinal', 'integer', NULL, 1, NULL),

    ('entity_label', '_mid', 'string', 'entity_label', NULL, NULL),
    ('entity_label', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_label', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_label', 'name', 'string', 'label', NULL, NULL),
    ('entity_label', 'label', 'string', 'Label', NULL, NULL),
    ('entity_label', 'type', 'string', 'string', NULL, NULL),
    ('entity_label', 'ordinal', 'integer', NULL, 2, NULL),

    ('entity_label_plural', '_mid', 'string', 'entity_label_plural', NULL, NULL),
    ('entity_label_plural', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_label_plural', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_label_plural', 'name', 'string', 'label_plural', NULL, NULL),
    ('entity_label_plural', 'label', 'string', 'Label (plural)', NULL, NULL),
    ('entity_label_plural', 'type', 'string', 'string', NULL, NULL),
    ('entity_label_plural', 'ordinal', 'integer', NULL, 3, NULL),

    ('entity_allowed_child', '_mid', 'string', 'entity_allowed_child', NULL, NULL),
    ('entity_allowed_child', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_allowed_child', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_allowed_child', 'name', 'string', 'allowed_child', NULL, NULL),
    ('entity_allowed_child', 'label', 'string', 'Allowed child', NULL, NULL),
    ('entity_allowed_child', 'label_plural', 'string', 'Allowed childs', NULL, NULL),
    ('entity_allowed_child', 'type', 'string', 'reference', NULL, NULL),
    ('entity_allowed_child', 'ordinal', 'integer', NULL, 4, NULL),

    ('entity_add_from_menu', '_mid', 'string', 'entity_add_from_menu', NULL, NULL),
    ('entity_add_from_menu', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_add_from_menu', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_add_from_menu', 'name', 'string', 'add_from_menu', NULL, NULL),
    ('entity_add_from_menu', 'label', 'string', 'Add from menu', NULL, NULL),
    ('entity_add_from_menu', 'label_plural', 'string', 'Add from menus', NULL, NULL),
    ('entity_add_from_menu', 'type', 'string', 'reference', NULL, NULL),
    ('entity_add_from_menu', 'ordinal', 'integer', NULL, 5, NULL),

    ('entity_optional_parent', '_mid', 'string', 'entity_optional_parent', NULL, NULL),
    ('entity_optional_parent', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_optional_parent', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_optional_parent', 'name', 'string', 'optional_parent', NULL, NULL),
    ('entity_optional_parent', 'label', 'string', 'Optional parent', NULL, NULL),
    ('entity_optional_parent', 'label_plural', 'string', 'Optional parents', NULL, NULL),
    ('entity_optional_parent', 'type', 'string', 'reference', NULL, NULL),
    ('entity_optional_parent', 'ordinal', 'integer', NULL, 6, NULL),

    ('entity_open_after_add', '_mid', 'string', 'entity_open_after_add', NULL, NULL),
    ('entity_open_after_add', '_type', 'reference', NULL, NULL, 'property'),
    ('entity_open_after_add', '_parent', 'reference', NULL, NULL, 'entity'),
    ('entity_open_after_add', 'name', 'string', 'open_after_add', NULL, NULL),
    ('entity_open_after_add', 'label', 'string', 'Open after add', NULL, NULL),
    ('entity_open_after_add', 'type', 'string', 'boolean', NULL, NULL),
    ('entity_open_after_add', 'ordinal', 'integer', NULL, 7, NULL),

    ('property', '_mid', 'string', 'property', NULL, NULL),
    ('property', '_type', 'reference', NULL, NULL, 'property'),
    ('property', 'name', 'string', 'property', NULL, NULL),
    ('property', 'label', 'string', 'Property', NULL, NULL),
    ('property', 'label_plural', 'string', 'Properties', NULL, NULL),

    ('property_name', '_mid', 'string', 'property_name', NULL, NULL),
    ('property_name', '_type', 'reference', NULL, NULL, 'property'),
    ('property_name', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_name', 'name', 'string', 'name', NULL, NULL),
    ('property_name', 'label', 'string', 'Name', NULL, NULL),
    ('property_name', 'type', 'string', 'string', NULL, NULL),
    ('property_name', 'ordinal', 'integer', NULL, 1, NULL),

    ('property_label', '_mid', 'string', 'property_label', NULL, NULL),
    ('property_label', '_type', 'reference', NULL, NULL, 'property'),
    ('property_label', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_label', 'name', 'string', 'label', NULL, NULL),
    ('property_label', 'label', 'string', 'Label', NULL, NULL),
    ('property_label', 'type', 'string', 'string', NULL, NULL),
    ('property_label', 'ordinal', 'integer', NULL, 2, NULL),

    ('property_label_plural', '_mid', 'string', 'property_label_plural', NULL, NULL),
    ('property_label_plural', '_type', 'reference', NULL, NULL, 'property'),
    ('property_label_plural', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_label_plural', 'name', 'string', 'label_plural', NULL, NULL),
    ('property_label_plural', 'label', 'string', 'Label (plural)', NULL, NULL),
    ('property_label_plural', 'type', 'string', 'string', NULL, NULL),
    ('property_label_plural', 'ordinal', 'integer', NULL, 3, NULL),

    ('property_fieldset', '_mid', 'string', 'property_fieldset', NULL, NULL),
    ('property_fieldset', '_type', 'reference', NULL, NULL, 'property'),
    ('property_fieldset', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_fieldset', 'name', 'string', 'fieldset', NULL, NULL),
    ('property_fieldset', 'label', 'string', 'Fieldset', NULL, NULL),
    ('property_fieldset', 'type', 'string', 'string', NULL, NULL),
    ('property_fieldset', 'ordinal', 'integer', NULL, 4, NULL),

    ('property_type', '_mid', 'string', 'property_type', NULL, NULL),
    ('property_type', '_type', 'reference', NULL, NULL, 'property'),
    ('property_type', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_type', 'name', 'string', 'type', NULL, NULL),
    ('property_type', 'label', 'string', 'Type', NULL, NULL),
    ('property_type', 'type', 'string', 'string', NULL, NULL),
    ('property_type', 'ordinal', 'integer', NULL, 5, NULL),

    ('property_ordinal', '_mid', 'string', 'property_ordinal', NULL, NULL),
    ('property_ordinal', '_type', 'reference', NULL, NULL, 'property'),
    ('property_ordinal', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_ordinal', 'name', 'string', 'ordinal', NULL, NULL),
    ('property_ordinal', 'label', 'string', 'Ordinal', NULL, NULL),
    ('property_ordinal', 'type', 'string', 'integer', NULL, NULL),
    ('property_ordinal', 'ordinal', 'integer', NULL, 6, NULL),

    ('property_list', '_mid', 'string', 'property_list', NULL, NULL),
    ('property_list', '_type', 'reference', NULL, NULL, 'property'),
    ('property_list', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_list', 'name', 'string', 'list', NULL, NULL),
    ('property_list', 'label', 'string', 'Is list', NULL, NULL),
    ('property_list', 'type', 'string', 'boolean', NULL, NULL),
    ('property_list', 'ordinal', 'integer', NULL, 7, NULL),

    ('property_multilingual', '_mid', 'string', 'property_multilingual', NULL, NULL),
    ('property_multilingual', '_type', 'reference', NULL, NULL, 'property'),
    ('property_multilingual', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_multilingual', 'name', 'string', 'multilingual', NULL, NULL),
    ('property_multilingual', 'label', 'string', 'Is multilingual', NULL, NULL),
    ('property_multilingual', 'type', 'string', 'boolean', NULL, NULL),
    ('property_multilingual', 'ordinal', 'integer', NULL, 8, NULL),

    ('property_mandatory', '_mid', 'string', 'property_mandatory', NULL, NULL),
    ('property_mandatory', '_type', 'reference', NULL, NULL, 'property'),
    ('property_mandatory', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_mandatory', 'name', 'string', 'mandatory', NULL, NULL),
    ('property_mandatory', 'label', 'string', 'Is mandatory', NULL, NULL),
    ('property_mandatory', 'type', 'string', 'boolean', NULL, NULL),
    ('property_mandatory', 'ordinal', 'integer', NULL, 9, NULL),

    ('property_public', '_mid', 'string', 'property_public', NULL, NULL),
    ('property_public', '_type', 'reference', NULL, NULL, 'property'),
    ('property_public', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_public', 'name', 'string', 'public', NULL, NULL),
    ('property_public', 'label', 'string', 'Is public', NULL, NULL),
    ('property_public', 'type', 'string', 'boolean', NULL, NULL),
    ('property_public', 'ordinal', 'integer', NULL, 10, NULL),

    ('property_search', '_mid', 'string', 'property_search', NULL, NULL),
    ('property_search', '_type', 'reference', NULL, NULL, 'property'),
    ('property_search', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_search', 'name', 'string', 'search', NULL, NULL),
    ('property_search', 'label', 'string', 'Is searchable', NULL, NULL),
    ('property_search', 'type', 'string', 'boolean', NULL, NULL),
    ('property_search', 'ordinal', 'integer', NULL, 10, NULL),

    ('property_classifier', '_mid', 'string', 'property_classifier', NULL, NULL),
    ('property_classifier', '_type', 'reference', NULL, NULL, 'property'),
    ('property_classifier', '_parent', 'reference', NULL, NULL, 'property'),
    ('property_classifier', 'name', 'string', 'classifier', NULL, NULL),
    ('property_classifier', 'label', 'string', 'Classifier', NULL, NULL),
    ('property_classifier', 'label_plural', 'string', 'Classifierss', NULL, NULL),
    ('property_classifier', 'type', 'string', 'reference', NULL, NULL),
    ('property_classifier', 'ordinal', 'integer', NULL, 11, NULL),

    ('menu', '_mid', 'string', 'menu', NULL, NULL),
    ('menu', '_type', 'reference', NULL, NULL, 'entity'),
    ('menu', 'name', 'string', 'menu', NULL, NULL),
    ('menu', 'label', 'string', 'Menu', NULL, NULL),
    ('menu', 'label_plural', 'string', 'Menus', NULL, NULL),
    ('menu', 'add_from_menu', 'reference', NULL, NULL, 'menu_conf_menu'),
    ('menu', 'optional_parent', 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),

    ('menu_name', '_mid', 'string', 'menu_name', NULL, NULL),
    ('menu_name', '_type', 'reference', NULL, NULL, 'property'),
    ('menu_name', '_parent', 'reference', NULL, NULL, 'menu'),
    ('menu_name', 'name', 'string', 'name', NULL, NULL),
    ('menu_name', 'label', 'string', 'Name', NULL, NULL),
    ('menu_name', 'type', 'string', 'string', NULL, NULL),
    ('menu_name', 'ordinal', 'integer', NULL, 1, NULL),

    ('menu_group', '_mid', 'string', 'menu_group', NULL, NULL),
    ('menu_group', '_type', 'reference', NULL, NULL, 'property'),
    ('menu_group', '_parent', 'reference', NULL, NULL, 'menu'),
    ('menu_group', 'name', 'string', 'group', NULL, NULL),
    ('menu_group', 'label', 'string', 'Group', NULL, NULL),
    ('menu_group', 'type', 'string', 'string', NULL, NULL),
    ('menu_group', 'ordinal', 'integer', NULL, 2, NULL),

    ('menu_query', '_mid', 'string', 'menu_query', NULL, NULL),
    ('menu_query', '_type', 'reference', NULL, NULL, 'property'),
    ('menu_query', '_parent', 'reference', NULL, NULL, 'menu'),
    ('menu_query', 'name', 'string', 'query', NULL, NULL),
    ('menu_query', 'label', 'string', 'Query', NULL, NULL),
    ('menu_query', 'type', 'string', 'string', NULL, NULL),
    ('menu_query', 'ordinal', 'integer', NULL, 3, NULL),

    ('menu_text', '_mid', 'string', 'menu_text', NULL, NULL),
    ('menu_text', '_type', 'reference', NULL, NULL, 'property'),
    ('menu_text', '_parent', 'reference', NULL, NULL, 'menu'),
    ('menu_text', 'name', 'string', 'text', NULL, NULL),
    ('menu_text', 'label', 'string', 'Text', NULL, NULL),
    ('menu_text', 'type', 'string', 'text', NULL, NULL),
    ('menu_text', 'ordinal', 'integer', NULL, 4, NULL);


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
    UNION SELECT 'entity_allowed_child'
    UNION SELECT 'entity_add_from_menu'
    UNION SELECT 'entity_optional_parent'
    UNION SELECT 'entity_open_after_add'
    UNION SELECT 'property'
    UNION SELECT 'property_name'
    UNION SELECT 'property_label'
    UNION SELECT 'property_label_plural'
    UNION SELECT 'property_fieldset'
    UNION SELECT 'property_type'
    UNION SELECT 'property_ordinal'
    UNION SELECT 'property_list'
    UNION SELECT 'property_multilingual'
    UNION SELECT 'property_mandatory'
    UNION SELECT 'property_public'
    UNION SELECT 'property_search'
    UNION SELECT 'property_classifier'
    UNION SELECT 'menu'
    UNION SELECT 'menu_name'
    UNION SELECT 'menu_group'
    UNION SELECT 'menu_query'
    UNION SELECT 'menu_text'
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
