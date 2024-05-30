/* id */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_mid',
    'string',
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), '')
FROM entity_definition
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* key */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    'name',
    'string',
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), '')
FROM entity_definition
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* type */
INSERT INTO mongo (
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
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* parent (database) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_parent',
    'reference',
    CONCAT('database_entity_', ?)
FROM entity_definition
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* inherit rights */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_inheritrights',
    'boolean',
    1
FROM entity_definition
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* sharing - domain */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    '_sharing',
    'string',
    'domain'
FROM entity_definition
WHERE keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* translation (label, label_plural, ...) fields */
INSERT INTO mongo (
    entity,
    type,
    language,
    datatype,
    value_string
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
WHERE field IN ('label', 'label_plural', 'description')
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* default-parent */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    'default_parent',
    'reference',
    related_entity_id
FROM relationship
WHERE relationship_definition_keyname = 'default-parent'
AND related_entity_id IS NOT NULL
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);

/* add from (allowed-child) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    IFNULL(related_entity_id, NULLIF(LOWER(TRIM(REPLACE(related_entity_definition_keyname, '-', '_'))), '')),
    'add_from',
    'reference',
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '')
FROM relationship
WHERE relationship_definition_keyname = 'allowed-child'
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname)
AND related_entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* add from (optional-parent) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    'add_from',
    'reference',
    related_entity_id
FROM relationship
WHERE relationship_definition_keyname = 'optional-parent'
AND related_entity_id IS NOT NULL
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* add from (menu) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT
    NULLIF(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), ''),
    'add_from',
    'reference',
    CONCAT('menu_', LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))))
FROM relationship
WHERE relationship_definition_keyname = 'optional-parent'
AND is_deleted = 0
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname)
GROUP BY entity_definition_keyname;


/* ester plugin */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    'plugin',
    'reference',
    'plugin_ester'
FROM entity_definition
WHERE actions_add LIKE '%ester%'
AND keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* csv plugin */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    NULLIF(LOWER(TRIM(REPLACE(keyname, '-', '_'))), ''),
    'plugin',
    'reference',
    'plugin_csv'
FROM entity_definition
WHERE actions_add LIKE '%csv%'
AND keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property key */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'name',
    'string',
    IF(dataproperty = 'title', 'name', NULLIF(LOWER(TRIM(REPLACE(dataproperty, '-', '_'))), ''))
FROM property_definition
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property type */
INSERT INTO mongo (
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
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property sharing - domain */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    '_sharing',
    'string',
    'domain'
FROM property_definition
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property inherit rights */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    '_inheritrights',
    'boolean',
    1
FROM property_definition
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property parent entity */
INSERT INTO mongo (
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
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property datatype */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'type',
    'string',
    CASE NULLIF(LOWER(TRIM(REPLACE(datatype, '-', '_'))), '')
        WHEN 'decimal' THEN 'number'
        WHEN 'integer' THEN 'number'
        WHEN 'text' THEN 'string'
        WHEN 'counter_value' THEN 'counter'
        ELSE NULLIF(LOWER(TRIM(REPLACE(datatype, '-', '_'))), '')
    END
FROM property_definition
WHERE keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property default value */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'default',
    'string',
    TRIM(defaultvalue)
FROM property_definition
WHERE NULLIF(formula < 1, 1) IS NULL
AND NULLIF(TRIM(defaultvalue), '') IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property decimal places */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'decimals',
    'integer',
    CASE NULLIF(LOWER(TRIM(REPLACE(datatype, '-', '_'))), '')
        WHEN 'decimal' THEN 2
        ELSE 0
    END
FROM property_definition
WHERE datatype IN ('decimal', 'integer')
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is markdown */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'markdown',
    'boolean',
    1
FROM property_definition
WHERE datatype IN ('text')
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is formula */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'formula',
    'string',
    TRIM(defaultvalue)
FROM property_definition
WHERE NULLIF(formula < 1, 1) IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is hidden */
INSERT INTO mongo (
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
WHERE visible = 0
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property ordinal */
INSERT INTO mongo (
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
WHERE ordinal IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is multilingual */
INSERT INTO mongo (
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
WHERE NULLIF(multilingual < 1, 1) IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is list */
INSERT INTO mongo (
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
WHERE NULLIF(multiplicity < 1, 1) IS NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is readonly */
INSERT INTO mongo (
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
WHERE NULLIF(readonly < 1, 1) IS NOT NULL
AND NULLIF(formula < 1, 1) IS NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is public */
INSERT INTO mongo (
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
WHERE NULLIF(public < 1, 1) IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is mandatory */
INSERT INTO mongo (
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
WHERE NULLIF(mandatory < 1, 1) IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is searchable */
INSERT INTO mongo (
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
WHERE NULLIF(search < 1, 1) IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property is in tableview */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_integer
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(pd.entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(pd.dataproperty, '-', '_')))), '_'),
    'table',
    'boolean',
    1
FROM
    translation AS t,
    property_definition AS pd
WHERE pd.entity_definition_keyname = t.entity_definition_keyname
AND t.field = 'displaytable'
AND INSTR(LOWER(t.value), CONCAT('@', LOWER(pd.dataproperty), '@')) > 0
AND pd.keyname IN (SELECT keyname FROM mongo_property_keyname)
AND pd.entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property has reference_query (reference property) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(dataproperty, '-', '_')))), '_'),
    'reference_query',
    'string',
    CONCAT('_type.string=', LOWER(TRIM(REPLACE(classifying_entity_definition_keyname, '-', '_'))), '&sort=name.string')
FROM property_definition
WHERE classifying_entity_definition_keyname IS NOT NULL
AND keyname IN (SELECT keyname FROM mongo_property_keyname)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* property translation (label, ...) fields */
INSERT INTO mongo (
    entity,
    type,
    language,
    datatype,
    value_string
) SELECT DISTINCT
    NULLIF(CONCAT(LOWER(TRIM(REPLACE(pd.entity_definition_keyname, '-', '_'))), '_', LOWER(TRIM(REPLACE(pd.dataproperty, '-', '_')))), '_'),
    CASE TRIM(t.field)
        WHEN 'fieldset' THEN 'group'
    	 ELSE TRIM(t.field)
    END,
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
AND (
    t.field IN ('label', 'label_plural', 'description')
    OR (t.field = 'fieldset' AND t.property_definition_keyname NOT LIKE 'person-%')
)
AND pd.keyname IN (SELECT keyname FROM mongo_property_keyname)
AND pd.entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);


/* missing name (formula) */
INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string,
    value_reference,
    value_integer
) SELECT DISTINCT
    CONCAT(LOWER(TRIM(REPLACE(t.entity_definition_keyname, '-', '_'))), '_name'),
    x.type,
    x.datatype,
    CASE x.type
        WHEN '_mid' THEN CONCAT(LOWER(TRIM(REPLACE(t.entity_definition_keyname, '-', '_'))), '_name')
        WHEN '_sharing' THEN 'domain'
        WHEN 'name' THEN 'name'
        WHEN 'label' THEN 'Name'
        WHEN 'type' THEN 'string'
        WHEN 'formula' THEN t.value
        ELSE NULL
    END,
    CASE x.type
        WHEN '_type' THEN 'property'
        WHEN '_parent' THEN LOWER(TRIM(REPLACE(t.entity_definition_keyname, '-', '_')))
        ELSE NULL
    END,
    CASE x.type
        WHEN '_inheritrights' THEN 1
        ELSE NULL
    END
FROM
    translation AS t,
    (
              SELECT '_mid' AS type, 'string' AS datatype
        UNION SELECT '_type', 'reference'
        UNION SELECT '_parent', 'reference'
        UNION SELECT '_sharing', 'string'
        UNION SELECT '_inheritrights', 'boolean'
        UNION SELECT 'name', 'string'
        UNION SELECT 'label', 'string'
        UNION SELECT 'type', 'string'
        UNION SELECT 'formula', 'string'
    ) AS x
WHERE t.field = 'displayname'
AND t.entity_definition_keyname NOT IN (
    SELECT entity_definition_keyname
    FROM property_definition
    WHERE TRIM(LOWER(dataproperty)) IN ('name', 'title')
)
AND t.entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);
