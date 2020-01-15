/* conf */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_text,
    value_integer,
    value_reference
) VALUES
    ('entity', '_mid', NULL, 'string', 'entity', NULL, NULL),
    ('entity', '_type', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity', 'name', NULL, 'string', 'entity', NULL, NULL),
    ('entity', 'label', 'en', 'string', 'Entity', NULL, NULL),
    ('entity', 'label', 'et', 'string', 'Entity', NULL, NULL),
    ('entity', 'label_plural', 'en', 'string', 'Entities', NULL, NULL),
    ('entity', 'allowed_child', NULL, 'reference', NULL, NULL, 'property'),
    ('entity', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_entity'),
    ('entity', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),
    ('entity', 'open_after_add', NULL, 'boolean', NULL, 1, NULL),

    ('entity_name', '_mid', NULL, 'string', 'entity_name', NULL, NULL),
    ('entity_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_name', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('entity_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('entity_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('entity_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('entity_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('entity_label', '_mid', NULL, 'string', 'entity_label', NULL, NULL),
    ('entity_label', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_label', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_label', 'name', NULL, 'string', 'label', 'en', NULL),
    ('entity_label', 'name', NULL, 'string', 'label', 'et', NULL),
    ('entity_label', 'label', 'en', 'string', 'Label', NULL, NULL),
    ('entity_label', 'label', 'et', 'string', 'Label', NULL, NULL),
    ('entity_label', 'type', NULL, 'string', 'string', NULL, NULL),
    ('entity_label', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('entity_label_plural', '_mid', NULL, 'string', 'entity_label_plural', NULL, NULL),
    ('entity_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_label_plural', 'name', NULL, 'string', 'label_plural', 'en', NULL),
    ('entity_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL),
    ('entity_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL),
    ('entity_label_plural', 'type', NULL, 'string', 'string', NULL, NULL),
    ('entity_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('entity_allowed_child', '_mid', NULL, 'string', 'entity_allowed_child', NULL, NULL),
    ('entity_allowed_child', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_allowed_child', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_allowed_child', 'name', NULL, 'string', 'allowed_child', NULL, NULL),
    ('entity_allowed_child', 'label', 'en', 'string', 'Allowed child', NULL, NULL),
    ('entity_allowed_child', 'label', 'et', 'string', 'Allowed child', NULL, NULL),
    ('entity_allowed_child', 'label_plural', 'en', 'string', 'Allowed childs', NULL, NULL),
    ('entity_allowed_child', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('entity_allowed_child', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('entity_add_from_menu', '_mid', NULL, 'string', 'entity_add_from_menu', NULL, NULL),
    ('entity_add_from_menu', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_add_from_menu', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_add_from_menu', 'name', NULL, 'string', 'add_from_menu', NULL, NULL),
    ('entity_add_from_menu', 'label', 'en', 'string', 'Add from menu', NULL, NULL),
    ('entity_add_from_menu', 'label', 'et', 'string', 'Add from menu', NULL, NULL),
    ('entity_add_from_menu', 'label_plural', 'en', 'string', 'Add from menus', NULL, NULL),
    ('entity_add_from_menu', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('entity_add_from_menu', 'ordinal', NULL, 'integer', NULL, 5, NULL),

    ('entity_optional_parent', '_mid', NULL, 'string', 'entity_optional_parent', NULL, NULL),
    ('entity_optional_parent', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_optional_parent', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_optional_parent', 'name', NULL, 'string', 'optional_parent', NULL, NULL),
    ('entity_optional_parent', 'label', 'en', 'string', 'Optional parent', NULL, NULL),
    ('entity_optional_parent', 'label', 'et', 'string', 'Optional parent', NULL, NULL),
    ('entity_optional_parent', 'label_plural', 'en', 'string', 'Optional parents', NULL, NULL),
    ('entity_optional_parent', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('entity_optional_parent', 'ordinal', NULL, 'integer', NULL, 6, NULL),

    ('entity_open_after_add', '_mid', NULL, 'string', 'entity_open_after_add', NULL, NULL),
    ('entity_open_after_add', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('entity_open_after_add', '_parent', NULL, 'reference', NULL, NULL, 'entity'),
    ('entity_open_after_add', 'name', NULL, 'string', 'open_after_add', NULL, NULL),
    ('entity_open_after_add', 'label', 'en', 'string', 'Open after add', NULL, NULL),
    ('entity_open_after_add', 'label', 'et', 'string', 'Open after add', NULL, NULL),
    ('entity_open_after_add', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('entity_open_after_add', 'ordinal', NULL, 'integer', NULL, 7, NULL),

    ('property', '_mid', NULL, 'string', 'property', NULL, NULL),
    ('property', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property', 'name', NULL, 'string', 'property', NULL, NULL),
    ('property', 'label', 'en', 'string', 'Property', NULL, NULL),
    ('property', 'label', 'et', 'string', 'Property', NULL, NULL),
    ('property', 'label_plural', 'en', 'string', 'Properties', NULL, NULL),

    ('property_name', '_mid', NULL, 'string', 'property_name', NULL, NULL),
    ('property_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_name', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('property_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('property_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('property_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('property_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('property_label', '_mid', NULL, 'string', 'property_label', NULL, NULL),
    ('property_label', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_label', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_label', 'name', NULL, 'string', 'label', 'en', NULL),
    ('property_label', 'name', NULL, 'string', 'label', 'et', NULL),
    ('property_label', 'label', 'en', 'string', 'Label', NULL, NULL),
    ('property_label', 'label', 'et', 'string', 'Label', NULL, NULL),
    ('property_label', 'type', NULL, 'string', 'string', NULL, NULL),
    ('property_label', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('property_label_plural', '_mid', NULL, 'string', 'property_label_plural', NULL, NULL),
    ('property_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_label_plural', 'name', NULL, 'string', 'label_plural', 'en', NULL),
    ('property_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL),
    ('property_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL),
    ('property_label_plural', 'type', NULL, 'string', 'string', NULL, NULL),
    ('property_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('property_fieldset', '_mid', NULL, 'string', 'property_fieldset', NULL, NULL),
    ('property_fieldset', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_fieldset', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_fieldset', 'name', NULL, 'string', 'fieldset', NULL, NULL),
    ('property_fieldset', 'label', 'en', 'string', 'Fieldset', NULL, NULL),
    ('property_fieldset', 'label', 'et', 'string', 'Fieldset', NULL, NULL),
    ('property_fieldset', 'type', NULL, 'string', 'string', NULL, NULL),
    ('property_fieldset', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('property_type', '_mid', NULL, 'string', 'property_type', NULL, NULL),
    ('property_type', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_type', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_type', 'name', NULL, 'string', 'type', NULL, NULL),
    ('property_type', 'label', 'en', 'string', 'Type', NULL, NULL),
    ('property_type', 'label', 'et', 'string', 'Type', NULL, NULL),
    ('property_type', 'type', NULL, 'string', 'string', NULL, NULL),
    ('property_type', 'ordinal', NULL, 'integer', NULL, 5, NULL),

    ('property_ordinal', '_mid', NULL, 'string', 'property_ordinal', NULL, NULL),
    ('property_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL),
    ('property_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL),
    ('property_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL),
    ('property_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL),
    ('property_ordinal', 'ordinal', NULL, 'integer', NULL, 6, NULL),

    ('property_list', '_mid', NULL, 'string', 'property_list', NULL, NULL),
    ('property_list', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_list', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_list', 'name', NULL, 'string', 'list', NULL, NULL),
    ('property_list', 'label', 'en', 'string', 'Is list', NULL, NULL),
    ('property_list', 'label', 'et', 'string', 'Is list', NULL, NULL),
    ('property_list', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('property_list', 'ordinal', NULL, 'integer', NULL, 7, NULL),

    ('property_multilingual', '_mid', NULL, 'string', 'property_multilingual', NULL, NULL),
    ('property_multilingual', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_multilingual', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_multilingual', 'name', NULL, 'string', 'multilingual', NULL, NULL),
    ('property_multilingual', 'label', 'en', 'string', 'Is multilingual', NULL, NULL),
    ('property_multilingual', 'label', 'et', 'string', 'Is multilingual', NULL, NULL),
    ('property_multilingual', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('property_multilingual', 'ordinal', NULL, 'integer', NULL, 8, NULL),

    ('property_mandatory', '_mid', NULL, 'string', 'property_mandatory', NULL, NULL),
    ('property_mandatory', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_mandatory', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_mandatory', 'name', NULL, 'string', 'mandatory', NULL, NULL),
    ('property_mandatory', 'label', 'en', 'string', 'Is mandatory', NULL, NULL),
    ('property_mandatory', 'label', 'et', 'string', 'Is mandatory', NULL, NULL),
    ('property_mandatory', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('property_mandatory', 'ordinal', NULL, 'integer', NULL, 9, NULL),

    ('property_public', '_mid', NULL, 'string', 'property_public', NULL, NULL),
    ('property_public', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_public', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_public', 'name', NULL, 'string', 'public', NULL, NULL),
    ('property_public', 'label', 'en', 'string', 'Is public', NULL, NULL),
    ('property_public', 'label', 'et', 'string', 'Is public', NULL, NULL),
    ('property_public', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('property_public', 'ordinal', NULL, 'integer', NULL, 10, NULL),

    ('property_search', '_mid', NULL, 'string', 'property_search', NULL, NULL),
    ('property_search', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_search', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_search', 'name', NULL, 'string', 'search', NULL, NULL),
    ('property_search', 'label', 'en', 'string', 'Is searchable', NULL, NULL),
    ('property_search', 'label', 'et', 'string', 'Is searchable', NULL, NULL),
    ('property_search', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('property_search', 'ordinal', NULL, 'integer', NULL, 10, NULL),

    ('property_classifier', '_mid', NULL, 'string', 'property_classifier', NULL, NULL),
    ('property_classifier', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('property_classifier', '_parent', NULL, 'reference', NULL, NULL, 'property'),
    ('property_classifier', 'name', NULL, 'string', 'classifier', NULL, NULL),
    ('property_classifier', 'label', 'en', 'string', 'Classifier', NULL, NULL),
    ('property_classifier', 'label', 'et', 'string', 'Classifier', NULL, NULL),
    ('property_classifier', 'label_plural', 'en', 'string', 'Classifierss', NULL, NULL),
    ('property_classifier', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('property_classifier', 'ordinal', NULL, 'integer', NULL, 11, NULL),

    ('menu', '_mid', NULL, 'string', 'menu', NULL, NULL),
    ('menu', '_type', NULL, 'reference', NULL, NULL, 'entity'),
    ('menu', 'name', NULL, 'string', 'menu', NULL, NULL),
    ('menu', 'label', 'en', 'string', 'Menu', NULL, NULL),
    ('menu', 'label', 'et', 'string', 'Menu', NULL, NULL),
    ('menu', 'label_plural', 'en', 'string', 'Menus', NULL, NULL),
    ('menu', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_menu'),
    ('menu', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),

    ('menu_name', '_mid', NULL, 'string', 'menu_name', NULL, NULL),
    ('menu_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('menu_name', '_parent', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('menu_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('menu_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('menu_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('menu_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('menu_group', '_mid', NULL, 'string', 'menu_group', NULL, NULL),
    ('menu_group', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('menu_group', '_parent', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_group', 'name', NULL, 'string', 'group', NULL, NULL),
    ('menu_group', 'label', 'en', 'string', 'Group', NULL, NULL),
    ('menu_group', 'label', 'et', 'string', 'Group', NULL, NULL),
    ('menu_group', 'type', NULL, 'string', 'string', NULL, NULL),
    ('menu_group', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('menu_query', '_mid', NULL, 'string', 'menu_query', NULL, NULL),
    ('menu_query', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('menu_query', '_parent', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_query', 'name', NULL, 'string', 'query', NULL, NULL),
    ('menu_query', 'label', 'en', 'string', 'Query', NULL, NULL),
    ('menu_query', 'label', 'et', 'string', 'Query', NULL, NULL),
    ('menu_query', 'type', NULL, 'string', 'string', NULL, NULL),
    ('menu_query', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('menu_ordinal', '_mid', NULL, 'string', 'menu_ordinal', NULL, NULL),
    ('menu_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('menu_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL),
    ('menu_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL),
    ('menu_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL),
    ('menu_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL),
    ('menu_ordinal', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('menu_text', '_mid', NULL, 'string', 'menu_text', NULL, NULL),
    ('menu_text', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('menu_text', '_parent', NULL, 'reference', NULL, NULL, 'menu'),
    ('menu_text', 'name', NULL, 'string', 'text', NULL, NULL),
    ('menu_text', 'label', 'en', 'string', 'Text', NULL, NULL),
    ('menu_text', 'label', 'et', 'string', 'Text', NULL, NULL),
    ('menu_text', 'type', NULL, 'string', 'text', NULL, NULL),
    ('menu_text', 'ordinal', NULL, 'integer', NULL, 5, NULL);


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
