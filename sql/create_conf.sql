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
    ('conf_entity', '_mid', NULL, 'string', 'entity', NULL, NULL),
    ('conf_entity', '_type', NULL, 'reference', NULL, NULL, 'entity'),
    ('conf_entity', 'name', NULL, 'string', 'entity', NULL, NULL),
    ('conf_entity', 'label', 'en', 'string', 'Entity', NULL, NULL),
    ('conf_entity', 'label', 'et', 'string', 'Entity', NULL, NULL),
    ('conf_entity', 'label_plural', 'en', 'string', 'Entities', NULL, NULL),
    ('conf_entity', 'allowed_child', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_entity'),
    ('conf_entity', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),
    ('conf_entity', 'open_after_add', NULL, 'boolean', NULL, 1, NULL),

    ('conf_entity_name', '_mid', NULL, 'string', 'entity_name', NULL, NULL),
    ('conf_entity_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_name', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('conf_entity_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('conf_entity_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('conf_entity_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_entity_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('conf_entity_label', '_mid', NULL, 'string', 'entity_label', NULL, NULL),
    ('conf_entity_label', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_label', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_label', 'name', NULL, 'string', 'label', 'en', NULL),
    ('conf_entity_label', 'name', NULL, 'string', 'label', 'et', NULL),
    ('conf_entity_label', 'label', 'en', 'string', 'Label', NULL, NULL),
    ('conf_entity_label', 'label', 'et', 'string', 'Label', NULL, NULL),
    ('conf_entity_label', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_entity_label', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('conf_entity_label_plural', '_mid', NULL, 'string', 'entity_label_plural', NULL, NULL),
    ('conf_entity_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_label_plural', 'name', NULL, 'string', 'label_plural', 'en', NULL),
    ('conf_entity_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL),
    ('conf_entity_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL),
    ('conf_entity_label_plural', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_entity_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('conf_entity_allowed_child', '_mid', NULL, 'string', 'entity_allowed_child', NULL, NULL),
    ('conf_entity_allowed_child', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_allowed_child', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_allowed_child', 'name', NULL, 'string', 'allowed_child', NULL, NULL),
    ('conf_entity_allowed_child', 'label', 'en', 'string', 'Allowed child', NULL, NULL),
    ('conf_entity_allowed_child', 'label', 'et', 'string', 'Allowed child', NULL, NULL),
    ('conf_entity_allowed_child', 'label_plural', 'en', 'string', 'Allowed childs', NULL, NULL),
    ('conf_entity_allowed_child', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('conf_entity_allowed_child', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('conf_entity_add_from_menu', '_mid', NULL, 'string', 'entity_add_from_menu', NULL, NULL),
    ('conf_entity_add_from_menu', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_add_from_menu', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_add_from_menu', 'name', NULL, 'string', 'add_from_menu', NULL, NULL),
    ('conf_entity_add_from_menu', 'label', 'en', 'string', 'Add from menu', NULL, NULL),
    ('conf_entity_add_from_menu', 'label', 'et', 'string', 'Add from menu', NULL, NULL),
    ('conf_entity_add_from_menu', 'label_plural', 'en', 'string', 'Add from menus', NULL, NULL),
    ('conf_entity_add_from_menu', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('conf_entity_add_from_menu', 'ordinal', NULL, 'integer', NULL, 5, NULL),

    ('conf_entity_optional_parent', '_mid', NULL, 'string', 'entity_optional_parent', NULL, NULL),
    ('conf_entity_optional_parent', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_optional_parent', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_optional_parent', 'name', NULL, 'string', 'optional_parent', NULL, NULL),
    ('conf_entity_optional_parent', 'label', 'en', 'string', 'Optional parent', NULL, NULL),
    ('conf_entity_optional_parent', 'label', 'et', 'string', 'Optional parent', NULL, NULL),
    ('conf_entity_optional_parent', 'label_plural', 'en', 'string', 'Optional parents', NULL, NULL),
    ('conf_entity_optional_parent', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('conf_entity_optional_parent', 'ordinal', NULL, 'integer', NULL, 6, NULL),

    ('conf_entity_open_after_add', '_mid', NULL, 'string', 'entity_open_after_add', NULL, NULL),
    ('conf_entity_open_after_add', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_entity_open_after_add', '_parent', NULL, 'reference', NULL, NULL, 'conf_entity'),
    ('conf_entity_open_after_add', 'name', NULL, 'string', 'open_after_add', NULL, NULL),
    ('conf_entity_open_after_add', 'label', 'en', 'string', 'Open after add', NULL, NULL),
    ('conf_entity_open_after_add', 'label', 'et', 'string', 'Open after add', NULL, NULL),
    ('conf_entity_open_after_add', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_entity_open_after_add', 'ordinal', NULL, 'integer', NULL, 7, NULL),

    ('conf_property', '_mid', NULL, 'string', 'property', NULL, NULL),
    ('conf_property', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property', 'name', NULL, 'string', 'property', NULL, NULL),
    ('conf_property', 'label', 'en', 'string', 'Property', NULL, NULL),
    ('conf_property', 'label', 'et', 'string', 'Property', NULL, NULL),
    ('conf_property', 'label_plural', 'en', 'string', 'Properties', NULL, NULL),

    ('conf_property_name', '_mid', NULL, 'string', 'property_name', NULL, NULL),
    ('conf_property_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_name', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('conf_property_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('conf_property_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('conf_property_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_property_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('conf_property_label', '_mid', NULL, 'string', 'property_label', NULL, NULL),
    ('conf_property_label', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_label', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_label', 'name', NULL, 'string', 'label', 'en', NULL),
    ('conf_property_label', 'name', NULL, 'string', 'label', 'et', NULL),
    ('conf_property_label', 'label', 'en', 'string', 'Label', NULL, NULL),
    ('conf_property_label', 'label', 'et', 'string', 'Label', NULL, NULL),
    ('conf_property_label', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_property_label', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('conf_property_label_plural', '_mid', NULL, 'string', 'property_label_plural', NULL, NULL),
    ('conf_property_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_label_plural', 'name', NULL, 'string', 'label_plural', 'en', NULL),
    ('conf_property_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL),
    ('conf_property_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL),
    ('conf_property_label_plural', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_property_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('conf_property_fieldset', '_mid', NULL, 'string', 'property_fieldset', NULL, NULL),
    ('conf_property_fieldset', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_fieldset', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_fieldset', 'name', NULL, 'string', 'fieldset', NULL, NULL),
    ('conf_property_fieldset', 'label', 'en', 'string', 'Fieldset', NULL, NULL),
    ('conf_property_fieldset', 'label', 'et', 'string', 'Fieldset', NULL, NULL),
    ('conf_property_fieldset', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_property_fieldset', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('conf_property_type', '_mid', NULL, 'string', 'property_type', NULL, NULL),
    ('conf_property_type', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_type', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_type', 'name', NULL, 'string', 'type', NULL, NULL),
    ('conf_property_type', 'label', 'en', 'string', 'Type', NULL, NULL),
    ('conf_property_type', 'label', 'et', 'string', 'Type', NULL, NULL),
    ('conf_property_type', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_property_type', 'ordinal', NULL, 'integer', NULL, 5, NULL),

    ('conf_property_ordinal', '_mid', NULL, 'string', 'property_ordinal', NULL, NULL),
    ('conf_property_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL),
    ('conf_property_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL),
    ('conf_property_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL),
    ('conf_property_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL),
    ('conf_property_ordinal', 'ordinal', NULL, 'integer', NULL, 6, NULL),

    ('conf_property_list', '_mid', NULL, 'string', 'property_list', NULL, NULL),
    ('conf_property_list', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_list', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_list', 'name', NULL, 'string', 'list', NULL, NULL),
    ('conf_property_list', 'label', 'en', 'string', 'Is list', NULL, NULL),
    ('conf_property_list', 'label', 'et', 'string', 'Is list', NULL, NULL),
    ('conf_property_list', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_property_list', 'ordinal', NULL, 'integer', NULL, 7, NULL),

    ('conf_property_multilingual', '_mid', NULL, 'string', 'property_multilingual', NULL, NULL),
    ('conf_property_multilingual', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_multilingual', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_multilingual', 'name', NULL, 'string', 'multilingual', NULL, NULL),
    ('conf_property_multilingual', 'label', 'en', 'string', 'Is multilingual', NULL, NULL),
    ('conf_property_multilingual', 'label', 'et', 'string', 'Is multilingual', NULL, NULL),
    ('conf_property_multilingual', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_property_multilingual', 'ordinal', NULL, 'integer', NULL, 8, NULL),

    ('conf_property_mandatory', '_mid', NULL, 'string', 'property_mandatory', NULL, NULL),
    ('conf_property_mandatory', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_mandatory', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_mandatory', 'name', NULL, 'string', 'mandatory', NULL, NULL),
    ('conf_property_mandatory', 'label', 'en', 'string', 'Is mandatory', NULL, NULL),
    ('conf_property_mandatory', 'label', 'et', 'string', 'Is mandatory', NULL, NULL),
    ('conf_property_mandatory', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_property_mandatory', 'ordinal', NULL, 'integer', NULL, 9, NULL),

    ('conf_property_public', '_mid', NULL, 'string', 'property_public', NULL, NULL),
    ('conf_property_public', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_public', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_public', 'name', NULL, 'string', 'public', NULL, NULL),
    ('conf_property_public', 'label', 'en', 'string', 'Is public', NULL, NULL),
    ('conf_property_public', 'label', 'et', 'string', 'Is public', NULL, NULL),
    ('conf_property_public', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_property_public', 'ordinal', NULL, 'integer', NULL, 10, NULL),

    ('conf_property_search', '_mid', NULL, 'string', 'property_search', NULL, NULL),
    ('conf_property_search', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_search', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_search', 'name', NULL, 'string', 'search', NULL, NULL),
    ('conf_property_search', 'label', 'en', 'string', 'Is searchable', NULL, NULL),
    ('conf_property_search', 'label', 'et', 'string', 'Is searchable', NULL, NULL),
    ('conf_property_search', 'type', NULL, 'string', 'boolean', NULL, NULL),
    ('conf_property_search', 'ordinal', NULL, 'integer', NULL, 10, NULL),

    ('conf_property_classifier', '_mid', NULL, 'string', 'property_classifier', NULL, NULL),
    ('conf_property_classifier', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_property_classifier', '_parent', NULL, 'reference', NULL, NULL, 'conf_property'),
    ('conf_property_classifier', 'name', NULL, 'string', 'classifier', NULL, NULL),
    ('conf_property_classifier', 'label', 'en', 'string', 'Classifier', NULL, NULL),
    ('conf_property_classifier', 'label', 'et', 'string', 'Classifier', NULL, NULL),
    ('conf_property_classifier', 'label_plural', 'en', 'string', 'Classifierss', NULL, NULL),
    ('conf_property_classifier', 'type', NULL, 'string', 'reference', NULL, NULL),
    ('conf_property_classifier', 'ordinal', NULL, 'integer', NULL, 11, NULL),

    ('conf_menu', '_mid', NULL, 'string', 'menu', NULL, NULL),
    ('conf_menu', '_type', NULL, 'reference', NULL, NULL, 'entity'),
    ('conf_menu', 'name', NULL, 'string', 'menu', NULL, NULL),
    ('conf_menu', 'label', 'en', 'string', 'Menu', NULL, NULL),
    ('conf_menu', 'label', 'et', 'string', 'Menu', NULL, NULL),
    ('conf_menu', 'label_plural', 'en', 'string', 'Menus', NULL, NULL),
    ('conf_menu', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_menu'),
    ('conf_menu', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0)),

    ('conf_menu_name', '_mid', NULL, 'string', 'menu_name', NULL, NULL),
    ('conf_menu_name', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_menu_name', '_parent', NULL, 'reference', NULL, NULL, 'conf_menu'),
    ('conf_menu_name', 'name', NULL, 'string', 'name', NULL, NULL),
    ('conf_menu_name', 'label', 'en', 'string', 'Name', NULL, NULL),
    ('conf_menu_name', 'label', 'et', 'string', 'Name', NULL, NULL),
    ('conf_menu_name', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_menu_name', 'ordinal', NULL, 'integer', NULL, 1, NULL),

    ('conf_menu_group', '_mid', NULL, 'string', 'menu_group', NULL, NULL),
    ('conf_menu_group', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_menu_group', '_parent', NULL, 'reference', NULL, NULL, 'conf_menu'),
    ('conf_menu_group', 'name', NULL, 'string', 'group', NULL, NULL),
    ('conf_menu_group', 'label', 'en', 'string', 'Group', NULL, NULL),
    ('conf_menu_group', 'label', 'et', 'string', 'Group', NULL, NULL),
    ('conf_menu_group', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_menu_group', 'ordinal', NULL, 'integer', NULL, 2, NULL),

    ('conf_menu_query', '_mid', NULL, 'string', 'menu_query', NULL, NULL),
    ('conf_menu_query', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_menu_query', '_parent', NULL, 'reference', NULL, NULL, 'conf_menu'),
    ('conf_menu_query', 'name', NULL, 'string', 'query', NULL, NULL),
    ('conf_menu_query', 'label', 'en', 'string', 'Query', NULL, NULL),
    ('conf_menu_query', 'label', 'et', 'string', 'Query', NULL, NULL),
    ('conf_menu_query', 'type', NULL, 'string', 'string', NULL, NULL),
    ('conf_menu_query', 'ordinal', NULL, 'integer', NULL, 3, NULL),

    ('conf_menu_ordinal', '_mid', NULL, 'string', 'menu_ordinal', NULL, NULL),
    ('conf_menu_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_menu_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'conf_menu'),
    ('conf_menu_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL),
    ('conf_menu_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL),
    ('conf_menu_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL),
    ('conf_menu_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL),
    ('conf_menu_ordinal', 'ordinal', NULL, 'integer', NULL, 4, NULL),

    ('conf_menu_text', '_mid', NULL, 'string', 'menu_text', NULL, NULL),
    ('conf_menu_text', '_type', NULL, 'reference', NULL, NULL, 'property'),
    ('conf_menu_text', '_parent', NULL, 'reference', NULL, NULL, 'conf_menu'),
    ('conf_menu_text', 'name', NULL, 'string', 'text', NULL, NULL),
    ('conf_menu_text', 'label', 'en', 'string', 'Text', NULL, NULL),
    ('conf_menu_text', 'label', 'et', 'string', 'Text', NULL, NULL),
    ('conf_menu_text', 'type', NULL, 'string', 'text', NULL, NULL),
    ('conf_menu_text', 'ordinal', NULL, 'integer', NULL, 5, NULL);


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
