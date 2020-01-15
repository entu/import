/* id */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_mid',
    'string',
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), '')
FROM entity_definition
WHERE keyname NOT LIKE 'conf-%';


/* key */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    'name',
    'string',
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), '')
FROM entity_definition
WHERE keyname NOT LIKE 'conf-%';


/* type */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_type',
    'reference',
    'entity'
FROM entity_definition
WHERE keyname NOT LIKE 'conf-%';


/* rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
WHERE keyname NOT LIKE 'conf-%';


/* open-after-add properties */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    'open_after_add',
    'boolean',
    1
FROM entity_definition
WHERE keyname NOT LIKE 'conf-%'
AND open_after_add = 1;


/* translation (label, label_plural, ...) fields */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    TRIM(field),
    CASE language
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    'string',
    REPLACE(TRIM(value), '@title@', '@name@')
FROM translation
WHERE entity_definition_keyname NOT LIKE 'conf-%'
AND field IN ('label', 'label_plural', 'description')
AND entity_definition_keyname IS NOT NULL;


/* allowed-child, default-parent, optional-parent */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    NULLIF(LOWER(TRIM(REPLACE(relationship_definition_keyname, '-', '_'))), ''),
    'reference',
    IFNULL(related_entity_id, NULLIF(LOWER(TRIM(REPLACE(related_entity_definition_keyname, '-', '_'))), ''))
FROM relationship
WHERE entity_definition_keyname IS NOT NULL
AND relationship_definition_keyname IN ('allowed-child', 'default-parent', 'optional-parent');


/* add from menu */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    'add_from_menu',
    'reference',
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))))
FROM relationship
WHERE relationship_definition_keyname = 'optional-parent'
AND is_deleted = 0
GROUP BY
    entity_definition_keyname;


/* property key */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'name',
    'string',
    IF(dataproperty = 'title', 'name', NULLIF(LOWER(TRIM(REPLACE(dataproperty, '-', '_'))), ''))
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition);


/* property type */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    '_type',
    'reference',
    'property'
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition);


/* property rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
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
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition);


/* property parent entity */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    '_parent',
    'reference',
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '')
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition);


/* property datatype */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'type',
    'string',
    NULLIF(LOWER(TRIM(REPLACE(datatype, '-', '_'))), '')
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition);


/* property default value */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'default',
    'string',
    TRIM(defaultvalue)
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(formula < 1, 1) IS NULL
AND NULLIF(TRIM(defaultvalue), '') IS NOT NULL;


/* property is formula */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_text
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'formula',
    'string',
    TRIM(defaultvalue)
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(formula < 1, 1) IS NOT NULL;


/* property is hidden */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'hidden',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND visible = 0;


/* property ordinal */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'ordinal',
    'integer',
    ordinal
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND ordinal IS NOT NULL;


/* property is multilingual */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'multilingual',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(multilingual < 1, 1) IS NOT NULL;


/* property is list */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'list',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(multiplicity < 1, 1) IS NULL;


/* property is readonly */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'readonly',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(readonly < 1, 1) IS NOT NULL
AND NULLIF(formula < 1, 1) IS NULL;


/* property is public */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'public',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(public < 1, 1) IS NOT NULL;


/* property is mandatory */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'mandatory',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(mandatory < 1, 1) IS NOT NULL;


/* property is searchable */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'search',
    'boolean',
    1
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND NULLIF(search < 1, 1) IS NOT NULL;


/* property has classifier (reference property) */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'classifier',
    'reference',
    NULLIF(LOWER(TRIM(REPLACE(classifying_entity_definition_keyname, '-', '_'))), '')
FROM property_definition
WHERE dataproperty NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND entity_definition_keyname NOT LIKE 'conf-%'
AND entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND classifying_entity_definition_keyname IS NOT NULL;


/* property translation (label, ...) fields */
INSERT INTO props (
    entity,
    type,
    language,
    datatype,
    value_text
) SELECT DISTINCT
    CONCAT(pd.entity_definition_keyname, '_', pd.dataproperty),
    TRIM(t.field),
    CASE t.language
        WHEN 'estonian' THEN 'et'
        WHEN 'english' THEN 'en'
        ELSE NULL
    END,
    'string',
    TRIM(t.value)
FROM
    translation AS t,
    property_definition AS pd
WHERE pd.keyname = t.property_definition_keyname
AND t.property_definition_keyname NOT IN ('entu-changed-at', 'entu-changed-by', 'entu-created-at', 'entu-created-by')
AND pd.entity_definition_keyname NOT LIKE 'conf-%'
AND pd.entity_definition_keyname IN (SELECT keyname FROM entity_definition)
AND t.field IN ('label', 'label_plural', 'description', 'fieldset')
AND t.property_definition_keyname IS NOT NULL;
