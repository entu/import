/* conf */
INSERT INTO mongo (
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
    ('entity', 'label', 'et', 'string', 'Objekt', NULL, NULL, 1),
    ('entity', 'label_plural', 'en', 'string', 'Entities', NULL, NULL, 1),
    ('entity', 'label_plural', 'et', 'string', 'Objektid', NULL, NULL, 1),
    ('entity', 'add_from', NULL, 'reference', NULL, NULL, 'menu_conf_entity', 1),

    ('entity_name', '_mid', NULL, 'string', 'entity_name', NULL, NULL, 1),
    ('entity_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_name', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('entity_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('entity_name', 'label', 'et', 'string', 'Nimi', NULL, NULL, 1),
    ('entity_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_name', 'ordinal', NULL, 'integer', NULL, 10, NULL, 1),
    ('entity_name', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('entity_name', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_label', '_mid', NULL, 'string', 'entity_label', NULL, NULL, 1),
    ('entity_label', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_label', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_label', 'name', NULL, 'string', 'label', NULL, NULL, 1),
    ('entity_label', 'label', 'en', 'string', 'Label', NULL, NULL, 1),
    ('entity_label', 'label', 'et', 'string', 'Silt', NULL, NULL, 1),
    ('entity_label', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_label', 'ordinal', NULL, 'integer', NULL, 20, NULL, 1),
    ('entity_label', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('entity_label', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('entity_label', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_label_plural', '_mid', NULL, 'string', 'entity_label_plural', NULL, NULL, 1),
    ('entity_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_label_plural', 'name', NULL, 'string', 'label_plural', NULL, NULL, 1),
    ('entity_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL, 1),
    ('entity_label_plural', 'label', 'et', 'string', 'Silt (mitmuses)', NULL, NULL, 1),
    ('entity_label_plural', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('entity_label_plural', 'ordinal', NULL, 'integer', NULL, 30, NULL, 1),
    ('entity_label_plural', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('entity_label_plural', 'search', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_description', '_mid', NULL, 'string', 'entity_description', NULL, NULL, 1),
    ('entity_description', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_description', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_description', 'name', NULL, 'string', 'description', NULL, NULL, 1),
    ('entity_description', 'label', 'en', 'string', 'Description (help text)', NULL, NULL, 1),
    ('entity_description', 'label', 'et', 'string', 'Kirjeldus (abi tekst)', NULL, NULL, 1),
    ('entity_description', 'type', NULL, 'string', 'text', NULL, NULL, 1),
    ('entity_description', 'ordinal', NULL, 'integer', NULL, 50, NULL, 1),
    ('entity_description', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('entity_description', 'markdown', NULL, 'boolean', NULL, 1, NULL, 1),

    ('entity_add_from', '_mid', NULL, 'string', 'entity_add_from', NULL, NULL, 1),
    ('entity_add_from', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('entity_add_from', '_parent', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('entity_add_from', 'name', NULL, 'string', 'add_from', NULL, NULL, 1),
    ('entity_add_from', 'label', 'en', 'string', 'Add from', NULL, NULL, 1),
    ('entity_add_from', 'label', 'et', 'string', 'Lisa menüüst/objektist', NULL, NULL, 1),
    ('entity_add_from', 'type', NULL, 'string', 'reference', NULL, NULL, 1),
    ('entity_add_from', 'ordinal', NULL, 'integer', NULL, 60, NULL, 1),
    ('entity_add_from', 'list', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property', '_mid', NULL, 'string', 'property', NULL, NULL, 1),
    ('property', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property', 'name', NULL, 'string', 'property', NULL, NULL, 1),
    ('property', 'label', 'en', 'string', 'Property', NULL, NULL, 1),
    ('property', 'label', 'et', 'string', 'Parameeter', NULL, NULL, 1),
    ('property', 'label_plural', 'en', 'string', 'Properties', NULL, NULL, 1),
    ('property', 'label_plural', 'et', 'string', 'Parameetrid', NULL, NULL, 1),
    ('property', 'add_from', NULL, 'reference', NULL, NULL, 'entity', 1),

    ('property_name', '_mid', NULL, 'string', 'property_name', NULL, NULL, 1),
    ('property_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_name', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('property_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('property_name', 'label', 'et', 'string', 'Nimi', NULL, NULL, 1),
    ('property_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_name', 'ordinal', NULL, 'integer', NULL, 10, NULL, 1),
    ('property_name', 'table', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_name', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_name', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_type', '_mid', NULL, 'string', 'property_type', NULL, NULL, 1),
    ('property_type', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_type', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_type', 'name', NULL, 'string', 'type', NULL, NULL, 1),
    ('property_type', 'label', 'en', 'string', 'Type', NULL, NULL, 1),
    ('property_type', 'label', 'et', 'string', 'Tüüp', NULL, NULL, 1),
    ('property_type', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_type', 'ordinal', NULL, 'integer', NULL, 15, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'date', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'datetime', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'file', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'number', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'reference', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'set', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_type', 'set', NULL, 'string', 'text', NULL, NULL, 1),
    ('property_type', 'table', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_type', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_type', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_label', '_mid', NULL, 'string', 'property_label', NULL, NULL, 1),
    ('property_label', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label', 'name', NULL, 'string', 'label', NULL, NULL, 1),
    ('property_label', 'label', 'en', 'string', 'Label', NULL, NULL, 1),
    ('property_label', 'label', 'et', 'string', 'Silt', NULL, NULL, 1),
    ('property_label', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_label', 'ordinal', NULL, 'integer', NULL, 20, NULL, 1),
    ('property_label', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_label', 'table', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_label', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_label', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_label_plural', '_mid', NULL, 'string', 'property_label_plural', NULL, NULL, 1),
    ('property_label_plural', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label_plural', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_label_plural', 'name', NULL, 'string', 'label_plural', NULL, NULL, 1),
    ('property_label_plural', 'label', 'en', 'string', 'Label (plural)', NULL, NULL, 1),
    ('property_label_plural', 'label', 'et', 'string', 'Silt (mitmuses)', NULL, NULL, 1),
    ('property_label_plural', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_label_plural', 'ordinal', NULL, 'integer', NULL, 30, NULL, 1),
    ('property_label_plural', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_label_plural', 'search', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_description', '_mid', NULL, 'string', 'property_description', NULL, NULL, 1),
    ('property_description', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_description', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_description', 'name', NULL, 'string', 'description', NULL, NULL, 1),
    ('property_description', 'label', 'en', 'string', 'Description (help text)', NULL, NULL, 1),
    ('property_description', 'label', 'et', 'string', 'Kirjeldus (abi tekst)', NULL, NULL, 1),
    ('property_description', 'type', NULL, 'string', 'text', NULL, NULL, 1),
    ('property_description', 'ordinal', NULL, 'integer', NULL, 35, NULL, 1),
    ('property_description', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_description', 'markdown', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_group', '_mid', NULL, 'string', 'property_group', NULL, NULL, 1),
    ('property_group', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_group', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_group', 'name', NULL, 'string', 'group', NULL, NULL, 1),
    ('property_group', 'label', 'en', 'string', 'Group', NULL, NULL, 1),
    ('property_group', 'label', 'et', 'string', 'Grupp', NULL, NULL, 1),
    ('property_group', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_group', 'ordinal', NULL, 'integer', NULL, 40, NULL, 1),
    ('property_group', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_group', 'table', NULL, 'boolean', NULL, 1, NULL, 1),
    ('property_group', 'search', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_ordinal', '_mid', NULL, 'string', 'property_ordinal', NULL, NULL, 1),
    ('property_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL, 1),
    ('property_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL, 1),
    ('property_ordinal', 'label', 'et', 'string', 'Järjekord', NULL, NULL, 1),
    ('property_ordinal', 'type', NULL, 'string', 'number', NULL, NULL, 1),
    ('property_ordinal', 'ordinal', NULL, 'integer', NULL, 60, NULL, 1),
    ('property_ordinal', 'table', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_list', '_mid', NULL, 'string', 'property_list', NULL, NULL, 1),
    ('property_list', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_list', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_list', 'name', NULL, 'string', 'list', NULL, NULL, 1),
    ('property_list', 'label', 'en', 'string', 'Is list', NULL, NULL, 1),
    ('property_list', 'label', 'et', 'string', 'On nimekiri', NULL, NULL, 1),
    ('property_list', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_list', 'ordinal', NULL, 'integer', NULL, 70, NULL, 1),

    ('property_markdown', '_mid', NULL, 'string', 'property_markdown', NULL, NULL, 1),
    ('property_markdown', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_markdown', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_markdown', 'name', NULL, 'string', 'markdown', NULL, NULL, 1),
    ('property_markdown', 'label', 'en', 'string', 'Is markdown', NULL, NULL, 1),
    ('property_markdown', 'label', 'et', 'string', 'On markdown', NULL, NULL, 1),
    ('property_markdown', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_markdown', 'ordinal', NULL, 'integer', NULL, 75, NULL, 1),

    ('property_multilingual', '_mid', NULL, 'string', 'property_multilingual', NULL, NULL, 1),
    ('property_multilingual', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_multilingual', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_multilingual', 'name', NULL, 'string', 'multilingual', NULL, NULL, 1),
    ('property_multilingual', 'label', 'en', 'string', 'Is multilingual', NULL, NULL, 1),
    ('property_multilingual', 'label', 'et', 'string', 'On mitmekeelne', NULL, NULL, 1),
    ('property_multilingual', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_multilingual', 'ordinal', NULL, 'integer', NULL, 80, NULL, 1),

    ('property_readonly', '_mid', NULL, 'string', 'property_readonly', NULL, NULL, 1),
    ('property_readonly', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_readonly', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_readonly', 'name', NULL, 'string', 'readonly', NULL, NULL, 1),
    ('property_readonly', 'label', 'en', 'string', 'Is read-only', NULL, NULL, 1),
    ('property_readonly', 'label', 'et', 'string', 'On vaid loetav', NULL, NULL, 1),
    ('property_readonly', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_readonly', 'ordinal', NULL, 'integer', NULL, 90, NULL, 1),

    ('property_mandatory', '_mid', NULL, 'string', 'property_mandatory', NULL, NULL, 1),
    ('property_mandatory', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_mandatory', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_mandatory', 'name', NULL, 'string', 'mandatory', NULL, NULL, 1),
    ('property_mandatory', 'label', 'en', 'string', 'Is mandatory', NULL, NULL, 1),
    ('property_mandatory', 'label', 'et', 'string', 'On kohustuslik', NULL, NULL, 1),
    ('property_mandatory', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_mandatory', 'ordinal', NULL, 'integer', NULL, 100, NULL, 1),
    ('property_mandatory', 'table', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_public', '_mid', NULL, 'string', 'property_public', NULL, NULL, 1),
    ('property_public', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_public', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_public', 'name', NULL, 'string', 'public', NULL, NULL, 1),
    ('property_public', 'label', 'en', 'string', 'Is public', NULL, NULL, 1),
    ('property_public', 'label', 'et', 'string', 'On avalik', NULL, NULL, 1),
    ('property_public', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_public', 'ordinal', NULL, 'integer', NULL, 110, NULL, 1),
    ('property_public', 'table', NULL, 'boolean', NULL, 1, NULL, 1),

    ('property_search', '_mid', NULL, 'string', 'property_search', NULL, NULL, 1),
    ('property_search', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_search', 'name', NULL, 'string', 'search', NULL, NULL, 1),
    ('property_search', 'label', 'en', 'string', 'Is searchable', NULL, NULL, 1),
    ('property_search', 'label', 'et', 'string', 'On otsitav', NULL, NULL, 1),
    ('property_search', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_search', 'ordinal', NULL, 'integer', NULL, 120, NULL, 1),

    ('property_table', '_mid', NULL, 'string', 'property_table', NULL, NULL, 1),
    ('property_table', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_table', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_table', 'name', NULL, 'string', 'table', NULL, NULL, 1),
    ('property_table', 'label', 'en', 'string', 'Is in table viev', NULL, NULL, 1),
    ('property_table', 'label', 'et', 'string', 'On tabelvaates', NULL, NULL, 1),
    ('property_table', 'type', NULL, 'string', 'boolean', NULL, NULL, 1),
    ('property_table', 'ordinal', NULL, 'integer', NULL, 130, NULL, 1),

    ('property_decimals', '_mid', NULL, 'string', 'property_decimals', NULL, NULL, 1),
    ('property_decimals', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_decimals', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_decimals', 'name', NULL, 'string', 'decimals', NULL, NULL, 1),
    ('property_decimals', 'label', 'en', 'string', 'Decimal places', NULL, NULL, 1),
    ('property_decimals', 'label', 'et', 'string', 'Kümnendkohti', NULL, NULL, 1),
    ('property_decimals', 'type', NULL, 'string', 'number', NULL, NULL, 1),
    ('property_decimals', 'ordinal', NULL, 'integer', NULL, 140, NULL, 1),
    ('property_decimals', 'decimals', NULL, 'integer', NULL, 0, NULL, 1),

    ('property_formula', '_mid', NULL, 'string', 'property_formula', NULL, NULL, 1),
    ('property_formula', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_formula', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_formula', 'name', NULL, 'string', 'formula', NULL, NULL, 1),
    ('property_formula', 'label', 'en', 'string', 'Formula', NULL, NULL, 1),
    ('property_formula', 'label', 'et', 'string', 'Valem', NULL, NULL, 1),
    ('property_formula', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_formula', 'ordinal', NULL, 'integer', NULL, 150, NULL, 1),

    ('property_reference_query', '_mid', NULL, 'string', 'property_reference_query', NULL, NULL, 1),
    ('property_reference_query', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_reference_query', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_reference_query', 'name', NULL, 'string', 'reference_query', NULL, NULL, 1),
    ('property_reference_query', 'label', 'en', 'string', 'Reference query', NULL, NULL, 1),
    ('property_reference_query', 'label', 'et', 'string', 'Viidatavate päring', NULL, NULL, 1),
    ('property_reference_query', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_reference_query', 'ordinal', NULL, 'integer', NULL, 160, NULL, 1),
    ('property_reference_query', 'description', 'en', 'string', 'Entu API query to find the objects that can be referenced in this parameter. For example "_type.string=person&sort=name.string"', NULL, NULL, 1),
    ('property_reference_query', 'description', 'et', 'string', 'Entu API päring objektide leidmiseks, millele saab selles parameetris viidata. Näiteks "_type.string=person&sort=name.string"', NULL, NULL, 1),

    ('property_set', '_mid', NULL, 'string', 'property_set', NULL, NULL, 1),
    ('property_set', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_set', '_parent', NULL, 'reference', NULL, NULL, 'property', 1),
    ('property_set', 'name', NULL, 'string', 'set', NULL, NULL, 1),
    ('property_set', 'label', 'en', 'string', 'Set', NULL, NULL, 1),
    ('property_set', 'label', 'et', 'string', 'Hulk', NULL, NULL, 1),
    ('property_set', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('property_set', 'ordinal', NULL, 'integer', NULL, 170, NULL, 1),
    ('property_set', 'list', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu', '_mid', NULL, 'string', 'menu', NULL, NULL, 1),
    ('menu', '_type', NULL, 'reference', NULL, NULL, 'entity', 1),
    ('menu', 'name', NULL, 'string', 'menu', NULL, NULL, 1),
    ('menu', 'label', 'en', 'string', 'Menu', NULL, NULL, 1),
    ('menu', 'label', 'et', 'string', 'Menüü', NULL, NULL, 1),
    ('menu', 'label_plural', 'en', 'string', 'Menus', NULL, NULL, 1),
    ('menu', 'add_from', NULL, 'reference', NULL, NULL, 'menu_conf_menu', 1),

    ('menu_name', '_mid', NULL, 'string', 'menu_name', NULL, NULL, 1),
    ('menu_name', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_name', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_name', 'name', NULL, 'string', 'name', NULL, NULL, 1),
    ('menu_name', 'label', 'en', 'string', 'Name', NULL, NULL, 1),
    ('menu_name', 'label', 'et', 'string', 'Nimi', NULL, NULL, 1),
    ('menu_name', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_name', 'ordinal', NULL, 'integer', NULL, 1, NULL, 1),
    ('menu_name', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_name', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_name', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu_group', '_mid', NULL, 'string', 'menu_group', NULL, NULL, 1),
    ('menu_group', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_group', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_group', 'name', NULL, 'string', 'group', NULL, NULL, 1),
    ('menu_group', 'label', 'en', 'string', 'Group', NULL, NULL, 1),
    ('menu_group', 'label', 'et', 'string', 'Grupp', NULL, NULL, 1),
    ('menu_group', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_group', 'ordinal', NULL, 'integer', NULL, 2, NULL, 1),
    ('menu_group', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_group', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_group', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),

    ('menu_ordinal', '_mid', NULL, 'string', 'menu_ordinal', NULL, NULL, 1),
    ('menu_ordinal', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_ordinal', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_ordinal', 'name', NULL, 'string', 'ordinal', NULL, NULL, 1),
    ('menu_ordinal', 'label', 'en', 'string', 'Ordinal', NULL, NULL, 1),
    ('menu_ordinal', 'label', 'et', 'string', 'Järjekord', NULL, NULL, 1),
    ('menu_ordinal', 'type', NULL, 'string', 'number', NULL, NULL, 1),
    ('menu_ordinal', 'ordinal', NULL, 'integer', NULL, 3, NULL, 1),

    ('menu_query', '_mid', NULL, 'string', 'menu_query', NULL, NULL, 1),
    ('menu_query', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_query', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_query', 'name', NULL, 'string', 'query', NULL, NULL, 1),
    ('menu_query', 'label', 'en', 'string', 'Query', NULL, NULL, 1),
    ('menu_query', 'label', 'et', 'string', 'Päring', NULL, NULL, 1),
    ('menu_query', 'type', NULL, 'string', 'string', NULL, NULL, 1),
    ('menu_query', 'ordinal', NULL, 'integer', NULL, 4, NULL, 1),
    ('menu_query', 'search', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_query', 'mandatory', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_query', 'description', 'en', 'string', 'Entu API query. For example "_type.string=person&sort=name.string"', NULL, NULL, 1),
    ('menu_query', 'description', 'et', 'string', 'Entu API päring. Näiteks "_type.string=person&sort=name.string"', NULL, NULL, 1),

    ('menu_description', '_mid', NULL, 'string', 'menu_description', NULL, NULL, 1),
    ('menu_description', '_type', NULL, 'reference', NULL, NULL, 'property', 1),
    ('menu_description', '_parent', NULL, 'reference', NULL, NULL, 'menu', 1),
    ('menu_description', 'name', NULL, 'string', 'text', NULL, NULL, 1),
    ('menu_description', 'label', 'en', 'string', 'Description', NULL, NULL, 1),
    ('menu_description', 'label', 'et', 'string', 'Kirjeldus', NULL, NULL, 1),
    ('menu_description', 'type', NULL, 'string', 'text', NULL, NULL, 1),
    ('menu_description', 'ordinal', NULL, 'integer', NULL, 5, NULL, 1),
    ('menu_description', 'multilingual', NULL, 'boolean', NULL, 1, NULL, 1),
    ('menu_description', 'markdown', NULL, 'boolean', NULL, 1, NULL, 1);


/* conf rights */
INSERT INTO mongo (
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
    FROM mongo
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
