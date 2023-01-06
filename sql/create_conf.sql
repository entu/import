/* conf */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_string,
    value_integer,
    value_reference,
    conf
) VALUES
    ('entity', '_mid', NULL, 'string', 'entity', NULL, NULL, 1),
    ('entity', '_type', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity', 'name', NULL, 'string', 'entity', NULL, NULL, 1),
    ('entity', 'label', 'en', 'string', 'Entity', NULL, NULL, 1),
    ('entity', 'label', 'et', 'string', 'Entity', NULL, NULL, 1),
    ('entity', 'label_plural', 'en', 'string', 'Entities', NULL, NULL, 1),
    ('entity', 'allowed_child', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_entity', 1),
    ('entity', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0), 1),
    ('entity', 'open_after_add', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_name', '_mid', NULL, 'string', 'entity_name', NULL, NULL, 1),
    ('entity_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_name', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('entity_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('entity_name', 'label', 'et', 'string', 'Name', NULL, NULL, 1),
    ('entity_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_name', 'ordinal', NULL, 'integer', NULL, 1, NULL, 1),

    ('entity_label', '_mid', NULL, 'string', 'entity_label', NULL, NULL, 1),
    ('entity_label', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_label', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_label', 'name', NULL, 'string', 'label', NULL, NULL, 1),
    ('entity_label', 'label', 'en', 'string', 'Label', NULL, NULL, 1),
    ('entity_label', 'label', 'et', 'string', 'Label', NULL, NULL, 1),
    ('entity_label', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_label', 'ordinal', NULL, 'integer', NULL, 2, NULL, 1),
    ('entity_label', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_label_plural', '_mid', NULL, 'string', 'entity_label_plural', NULL, NULL, 1),
    ('entity_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_label_plural', 'name', NULL, 'string', 'label_plural', NULL, NULL, 1),
    ('entity_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL, 1),
    ('entity_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL, 1),
    ('entity_label_plural', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL, 1),
    ('entity_label_plural', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_allowed_child', '_mid', NULL, 'string', 'entity_allowed_child', NULL, NULL, 1),
    ('entity_allowed_child', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_allowed_child', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_allowed_child', 'name', NULL, 'string', 'allowed_child', NULL, NULL, 1),
    ('entity_allowed_child', 'label', 'en', 'string', 'Allowed child', NULL, NULL, 1),
    ('entity_allowed_child', 'label', 'et', 'string', 'Allowed child', NULL, NULL, 1),
    ('entity_allowed_child', 'label_plural', 'en', 'string', 'Allowed childs', NULL, NULL, 1),
    ('entity_allowed_child', 'type', NULL, 'string', 'reference', NULL, NULL, 1),
    ('entity_allowed_child', 'ordinal', NULL, 'integer', NULL, 4, NULL, 1),

    ('entity_add_from_menu', '_mid', NULL, 'string', 'entity_add_from_menu', NULL, NULL, 1),
    ('entity_add_from_menu', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_add_from_menu', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_add_from_menu', 'name', NULL, 'string', 'add_from_menu', NULL, NULL, 1),
    ('entity_add_from_menu', 'label', 'en', 'string', 'Add from menu', NULL, NULL, 1),
    ('entity_add_from_menu', 'label', 'et', 'string', 'Add from menu', NULL, NULL, 1),
    ('entity_add_from_menu', 'label_plural', 'en', 'string', 'Add from menus', NULL, NULL, 1),
    ('entity_add_from_menu', 'type', NULL, 'string', 'reference', NULL, NULL, 1),
    ('entity_add_from_menu', 'ordinal', NULL, 'integer', NULL, 5, NULL, 1),

    ('entity_optional_parent', '_mid', NULL, 'string', 'entity_optional_parent', NULL, NULL, 1),
    ('entity_optional_parent', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_optional_parent', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_optional_parent', 'name', NULL, 'string', 'optional_parent', NULL, NULL, 1),
    ('entity_optional_parent', 'label', 'en', 'string', 'Optional parent', NULL, NULL, 1),
    ('entity_optional_parent', 'label', 'et', 'string', 'Optional parent', NULL, NULL, 1),
    ('entity_optional_parent', 'label_plural', 'en', 'string', 'Optional parents', NULL, NULL, 1),
    ('entity_optional_parent', 'type', NULL, 'string', 'reference', NULL, NULL, 1),
    ('entity_optional_parent', 'ordinal', NULL, 'integer', NULL, 6, NULL, 1),

    ('entity_open_after_add', '_mid', NULL, 'string', 'entity_open_after_add', NULL, NULL, 1),
    ('entity_open_after_add', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_open_after_add', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_open_after_add', 'name', NULL, 'string', 'open_after_add', NULL, NULL, 1),
    ('entity_open_after_add', 'label', 'en', 'string', 'Open after add', NULL, NULL, 1),
    ('entity_open_after_add', 'label', 'et', 'string', 'Open after add', NULL, NULL, 1),
    ('entity_open_after_add', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('entity_open_after_add', 'ordinal', NULL, 'integer', NULL, 7, NULL, 1),

    ('property', '_mid', NULL, 'string', 'property', NULL, NULL, 1),
    ('property', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property', 'name', NULL, 'string', 'property', NULL, NULL, 1),
    ('property', 'label', 'en', 'string', 'Property', NULL, NULL, 1),
    ('property', 'label', 'et', 'string', 'Property', NULL, NULL, 1),
    ('property', 'label_plural', 'en', 'string', 'Properties', NULL, NULL, 1),

    ('property_name', '_mid', NULL, 'string', 'property_name', NULL, NULL, 1),
    ('property_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_name', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('property_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('property_name', 'label', 'et', 'string', 'Name', NULL, NULL, 1),
    ('property_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_name', 'ordinal', NULL, 'integer', NULL, 1, NULL, 1),

    ('property_label', '_mid', NULL, 'string', 'property_label', NULL, NULL, 1),
    ('property_label', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label', 'name', NULL, 'string', 'label', NULL, NULL, 1),
    ('property_label', 'label', 'en', 'string', 'Label', NULL, NULL, 1),
    ('property_label', 'label', 'et', 'string', 'Label', NULL, NULL, 1),
    ('property_label', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_label', 'ordinal', NULL, 'integer', NULL, 2, NULL, 1),
    ('property_label', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_label_plural', '_mid', NULL, 'string', 'property_label_plural', NULL, NULL, 1),
    ('property_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label_plural', 'name', NULL, 'string', 'label_plural', NULL, NULL, 1),
    ('property_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL, 1),
    ('property_label_plural', 'label', 'et', 'string', 'Label (plural)', NULL, NULL, 1),
    ('property_label_plural', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_label_plural', 'ordinal', NULL, 'integer', NULL, 3, NULL, 1),
    ('property_label_plural', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_group', '_mid', NULL, 'string', 'property_group', NULL, NULL, 1),
    ('property_group', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_group', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_group', 'name', NULL, 'string', 'group', NULL, NULL, 1),
    ('property_group', 'label', 'en', 'string', 'group', NULL, NULL, 1),
    ('property_group', 'label', 'et', 'string', 'group', NULL, NULL, 1),
    ('property_group', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_group', 'ordinal', NULL, 'integer', NULL, 4, NULL, 1),
    ('property_group', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_type', '_mid', NULL, 'string', 'property_type', NULL, NULL, 1),
    ('property_type', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_type', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_type', 'name', NULL, 'string', 'type', NULL, NULL, 1),
    ('property_type', 'label', 'en', 'string', 'Type', NULL, NULL, 1),
    ('property_type', 'label', 'et', 'string', 'Type', NULL, NULL, 1),
    ('property_type', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_type', 'ordinal', NULL, 'integer', NULL, 5, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'date', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'datetime', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'double', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'file', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'integer', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'reference', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'set', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'string', NULL, NULL, 1),

    ('property_ordinal', '_mid', NULL, 'string', 'property_ordinal', NULL, NULL, 1),
    ('property_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL, 1),
    ('property_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL, 1),
    ('property_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL, 1),
    ('property_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL, 1),
    ('property_ordinal', 'ordinal', NULL, 'integer', NULL, 6, NULL, 1),

    ('property_list', '_mid', NULL, 'string', 'property_list', NULL, NULL, 1),
    ('property_list', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_list', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_list', 'name', NULL, 'string', 'list', NULL, NULL, 1),
    ('property_list', 'label', 'en', 'string', 'Is list', NULL, NULL, 1),
    ('property_list', 'label', 'et', 'string', 'Is list', NULL, NULL, 1),
    ('property_list', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_list', 'ordinal', NULL, 'integer', NULL, 7, NULL, 1),

    ('property_multilingual', '_mid', NULL, 'string', 'property_multilingual', NULL, NULL, 1),
    ('property_multilingual', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_multilingual', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_multilingual', 'name', NULL, 'string', 'multilingual', NULL, NULL, 1),
    ('property_multilingual', 'label', 'en', 'string', 'Is multilingual', NULL, NULL, 1),
    ('property_multilingual', 'label', 'et', 'string', 'Is multilingual', NULL, NULL, 1),
    ('property_multilingual', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_multilingual', 'ordinal', NULL, 'integer', NULL, 8, NULL, 1),

    ('property_readonly', '_mid', NULL, 'string', 'property_readonly', NULL, NULL, 1),
    ('property_readonly', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_readonly', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_readonly', 'name', NULL, 'string', 'readonly', NULL, NULL, 1),
    ('property_readonly', 'label', 'en', 'string', 'Is read-only', NULL, NULL, 1),
    ('property_readonly', 'label', 'et', 'string', 'Is read-only', NULL, NULL, 1),
    ('property_readonly', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_readonly', 'ordinal', NULL, 'integer', NULL, 9, NULL, 1),

    ('property_mandatory', '_mid', NULL, 'string', 'property_mandatory', NULL, NULL, 1),
    ('property_mandatory', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_mandatory', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_mandatory', 'name', NULL, 'string', 'mandatory', NULL, NULL, 1),
    ('property_mandatory', 'label', 'en', 'string', 'Is mandatory', NULL, NULL, 1),
    ('property_mandatory', 'label', 'et', 'string', 'Is mandatory', NULL, NULL, 1),
    ('property_mandatory', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_mandatory', 'ordinal', NULL, 'integer', NULL, 10, NULL, 1),

    ('property_public', '_mid', NULL, 'string', 'property_public', NULL, NULL, 1),
    ('property_public', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_public', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_public', 'name', NULL, 'string', 'public', NULL, NULL, 1),
    ('property_public', 'label', 'en', 'string', 'Is public', NULL, NULL, 1),
    ('property_public', 'label', 'et', 'string', 'Is public', NULL, NULL, 1),
    ('property_public', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_public', 'ordinal', NULL, 'integer', NULL, 11, NULL, 1),

    ('property_search', '_mid', NULL, 'string', 'property_search', NULL, NULL, 1),
    ('property_search', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', 'name', NULL, 'string', 'search', NULL, NULL, 1),
    ('property_search', 'label', 'en', 'string', 'Is searchable', NULL, NULL, 1),
    ('property_search', 'label', 'et', 'string', 'Is searchable', NULL, NULL, 1),
    ('property_search', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_search', 'ordinal', NULL, 'integer', NULL, 12, NULL, 1),

    ('property_search', '_mid', NULL, 'string', 'property_table', NULL, NULL, 1),
    ('property_search', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', 'name', NULL, 'string', 'table', NULL, NULL, 1),
    ('property_search', 'label', 'en', 'string', 'Is in table viev', NULL, NULL, 1),
    ('property_search', 'label', 'et', 'string', 'Is in table viev', NULL, NULL, 1),
    ('property_search', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_search', 'ordinal', NULL, 'integer', NULL, 13, NULL, 1),

    ('property_classifier', '_mid', NULL, 'string', 'property_classifier', NULL, NULL, 1),
    ('property_classifier', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_classifier', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_classifier', 'name', NULL, 'string', 'classifier', NULL, NULL, 1),
    ('property_classifier', 'label', 'en', 'string', 'Classifier', NULL, NULL, 1),
    ('property_classifier', 'label', 'et', 'string', 'Classifier', NULL, NULL, 1),
    ('property_classifier', 'label_plural', 'en', 'string', 'Classifierss', NULL, NULL, 1),
    ('property_classifier', 'type', NULL, 'string', 'reference', NULL, NULL, 1),
    ('property_classifier', 'ordinal', NULL, 'integer', NULL, 14, NULL, 1),

    ('property_formula', '_mid', NULL, 'string', 'property_formula', NULL, NULL, 1),
    ('property_formula', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_formula', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_formula', 'name', NULL, 'string', 'formula', NULL, NULL, 1),
    ('property_formula', 'label', 'en', 'string', 'Formula', NULL, NULL, 1),
    ('property_formula', 'label', 'et', 'string', 'Formula', NULL, NULL, 1),
    ('property_formula', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_formula', 'ordinal', NULL, 'integer', NULL, 15, NULL, 1),

    ('property_set', '_mid', NULL, 'string', 'property_set', NULL, NULL, 1),
    ('property_set', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_set', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_set', 'name', NULL, 'string', 'set', NULL, NULL, 1),
    ('property_set', 'label', 'en', 'string', 'Set', NULL, NULL, 1),
    ('property_set', 'label', 'et', 'string', 'Set', NULL, NULL, 1),
    ('property_set', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_set', 'ordinal', NULL, 'integer', NULL, 15, NULL, 1),
    ('property_set', 'list', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu', '_mid', NULL, 'string', 'menu', NULL, NULL, 1),
    ('menu', '_type', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('menu', 'name', NULL, 'string', 'menu', NULL, NULL, 1),
    ('menu', 'label', 'en', 'string', 'Menu', NULL, NULL, 1),
    ('menu', 'label', 'et', 'string', 'Menu', NULL, NULL, 1),
    ('menu', 'label_plural', 'en', 'string', 'Menus', NULL, NULL, 1),
    ('menu', 'add_from_menu', NULL, 'reference', NULL, NULL, 'menu_conf_menu', 1),
    ('menu', 'optional_parent', NULL, 'reference', NULL, NULL, (SELECT CONVERT(MIN(id), CHAR) FROM entity WHERE is_deleted = 0), 1),

    ('menu_name', '_mid', NULL, 'string', 'menu_name', NULL, NULL, 1),
    ('menu_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_name', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('menu_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('menu_name', 'label', 'et', 'string', 'Name', NULL, NULL, 1),
    ('menu_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_name', 'ordinal', NULL, 'integer', NULL, 1, NULL, 1),
    ('menu_name', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu_group', '_mid', NULL, 'string', 'menu_group', NULL, NULL, 1),
    ('menu_group', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_group', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_group', 'name', NULL, 'string', 'group', NULL, NULL, 1),
    ('menu_group', 'label', 'en', 'string', 'Group', NULL, NULL, 1),
    ('menu_group', 'label', 'et', 'string', 'Group', NULL, NULL, 1),
    ('menu_group', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_group', 'ordinal', NULL, 'integer', NULL, 2, NULL, 1),
    ('menu_group', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu_query', '_mid', NULL, 'string', 'menu_query', NULL, NULL, 1),
    ('menu_query', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_query', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_query', 'name', NULL, 'string', 'query', NULL, NULL, 1),
    ('menu_query', 'label', 'en', 'string', 'Query', NULL, NULL, 1),
    ('menu_query', 'label', 'et', 'string', 'Query', NULL, NULL, 1),
    ('menu_query', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_query', 'ordinal', NULL, 'integer', NULL, 3, NULL, 1),

    ('menu_ordinal', '_mid', NULL, 'string', 'menu_ordinal', NULL, NULL, 1),
    ('menu_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL, 1),
    ('menu_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL, 1),
    ('menu_ordinal', 'label', 'et', 'string', 'Ordinal', NULL, NULL, 1),
    ('menu_ordinal', 'type', NULL, 'string', 'integer', NULL, NULL, 1),
    ('menu_ordinal', 'ordinal', NULL, 'integer', NULL, 4, NULL, 1),

    ('menu_text', '_mid', NULL, 'string', 'menu_text', NULL, NULL, 1),
    ('menu_text', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_text', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_text', 'name', NULL, 'string', 'text', NULL, NULL, 1),
    ('menu_text', 'label', 'en', 'string', 'Text', NULL, NULL, 1),
    ('menu_text', 'label', 'et', 'string', 'Text', NULL, NULL, 1),
    ('menu_text', 'type', NULL, 'string', 'text', NULL, NULL, 1),
    ('menu_text', 'ordinal', NULL, 'integer', NULL, 5, NULL, 1),
    ('menu_text', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1);


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
    SELECT DISTINCT
        entity
    FROM props
    WHERE conf = 1
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
