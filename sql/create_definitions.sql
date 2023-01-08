/* id */
INSERT INTO props (
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
WHERE keyname IN (SELECT keyname FROM props_keyname);


/* key */
INSERT INTO props (
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
WHERE keyname IN (SELECT keyname FROM props_keyname);


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
WHERE keyname IN (SELECT keyname FROM props_keyname);


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
WHERE keyname IN (SELECT keyname FROM props_keyname);


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
WHERE open_after_add = 1
AND keyname IN (SELECT keyname FROM props_keyname);


/* translation (label, label_plural, ...) fields */
INSERT INTO props (
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
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE relationship_definition_keyname IN ('allowed-child', 'default-parent', 'optional-parent')
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname)
GROUP BY entity_definition_keyname;


/* property key */
INSERT INTO props (
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
WHERE dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property datatype */
INSERT INTO props (
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
        ELSE NULLIF(LOWER(TRIM(REPLACE(datatype, '-', '_'))), '')
    END
FROM property_definition
WHERE dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property default value */
INSERT INTO props (
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
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property decimal places */
INSERT INTO props (
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
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property is formula */
INSERT INTO props (
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
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE visible = 0
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE ordinal IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(multilingual < 1, 1) IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(multiplicity < 1, 1) IS NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(readonly < 1, 1) IS NOT NULL
AND NULLIF(formula < 1, 1) IS NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(public < 1, 1) IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(mandatory < 1, 1) IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE NULLIF(search < 1, 1) IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property is in tableview */
INSERT INTO props (
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
AND pd.dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND pd.entity_definition_keyname IN (SELECT keyname FROM props_keyname);


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
WHERE classifying_entity_definition_keyname IS NOT NULL
AND dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* property translation (label, ...) fields */
INSERT INTO props (
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
AND t.field IN ('label', 'label_plural', 'description', 'fieldset')
AND pd.dataproperty NOT IN (
    'analytics-code',
    'auth-erply',
    'auth-facebook',
    'auth-google',
    'auth-live',
    'auth-mailgun',
    'auth-mobileid',
    'auth-s3',
    'database-host',
    'database-password',
    'database-port',
    'database-ssl-ca',
    'database-ssl-path',
    'database-user',
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by',
    'entu-url',
    'mongodb',
    'tablepagesize',
    'tagcloud'
)
AND pd.entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* missing name (formula) */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_string,
    value_reference
) SELECT DISTINCT
    CONCAT(LOWER(TRIM(REPLACE(t.entity_definition_keyname, '-', '_'))), '_name'),
    x.type,
    x.datatype,
    CASE x.type
        WHEN '_mid' THEN CONCAT(LOWER(TRIM(REPLACE(t.entity_definition_keyname, '-', '_'))), '_name')
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
    END
FROM
    translation AS t,
    (
              SELECT '_mid' AS type, 'string' AS datatype
        UNION SELECT '_type', 'reference'
        UNION SELECT '_parent', 'reference'
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
AND t.entity_definition_keyname IN (SELECT keyname FROM props_keyname);


/* missing name (formula) rights */
INSERT INTO props (
    entity,
    type,
    datatype,
    value_reference
) SELECT DISTINCT
    CONCAT(LOWER(TRIM(REPLACE(entities.entity_definition_keyname, '-', '_'))), '_name'),
    CASE TRIM(users.user)
        WHEN 'argoroots@gmail.com' THEN '_owner'
        WHEN 'mihkel.putrinsh@gmail.com' THEN '_owner'
        ELSE '_viewer'
    END,
    'reference',
    users.id
FROM (
    SELECT DISTINCT entity_definition_keyname
    FROM translation
    WHERE field = 'displayname'
    AND entity_definition_keyname NOT IN (
        SELECT entity_definition_keyname
        FROM property_definition
        WHERE TRIM(LOWER(dataproperty)) IN ('name', 'title')
    )
    AND entity_definition_keyname IN (
        SELECT DISTINCT entity_definition_keyname
        FROM entity
        WHERE entity_definition_keyname NOT LIKE 'conf-%'
    )
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
