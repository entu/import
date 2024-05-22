INSERT INTO mongo (
    entity,
    type,
    datatype,
    value_string,
    value_integer,
    value_decimal,
    value_reference,
    created_at,
    deleted_at
) SELECT DISTINCT
    CONCAT('database_entity_', ?),
    u.type,
    u.datatype,
    u.value_string,
    u.value_integer,
    u.value_decimal,
    u.value_reference,
    IFNULL(IF(u.created >= '2000-01-01', u.created, NULL), IF(e.created >= '2000-01-01', e.created, NULL)) AS created_at,
    IF(u.is_deleted = 1, IF(u.deleted >= '2000-01-01', u.deleted, NOW()), NULL) AS deleted_at
FROM (

    SELECT
        '_mid' AS type,
        'string' AS datatype,
        CONCAT('database_entity_', ?) AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        NULL AS created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-database-name'
    AND is_deleted = 0

    UNION SELECT
        '_type' AS type,
        'reference' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        'database' AS value_reference,
        NULL AS created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-database-name'
    AND is_deleted = 0

    UNION SELECT
        '_inheritrights' AS type,
        'boolean' AS datatype,
        NULL AS value_string,
        1 AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        NULL AS created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-database-name'
    AND is_deleted = 0

    UNION SELECT
        '_sharing' AS type,
        'string' AS datatype,
        'domain' AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        NULL AS created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-database-name'
    AND is_deleted = 0

    UNION SELECT
        '_created',
        'atby',
        NULL AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created AS created,
        NULL AS deleted,
        NULL AS is_deleted,
        id AS entity_id
    FROM entu.entity
    WHERE entity_definition_keyname = 'customer'
    AND (created IS NOT NULL OR IF(TRIM(created_by) REGEXP ?, TRIM(created_by), NULL) IS NOT NULL)

    UNION SELECT
        '_owner' AS type,
        'reference' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        property.entity_id AS value_reference,
        NULL AS created,
        NULL AS deleted,
        NULL AS is_deleted,
        -1 AS entity_id
    FROM
        property,
        entity,
        property_definition
    WHERE entity.id = property.entity_id
    AND property_definition.keyname = property_definition_keyname
    AND property.is_deleted = 0
    AND entity.is_deleted = 0
    AND property_definition.dataproperty = 'entu-user'
    AND property.value_string IN ('argoroots@gmail.com', 'mihkel.putrinsh@gmail.com')

    UNION SELECT
        'name' AS type,
        'string' AS datatype,
        value_string AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-database-name'

    UNION SELECT
        'organization' AS type,
        'string' AS datatype,
        value_string AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-name'

    UNION SELECT
        'address' AS type,
        'string' AS datatype,
        value_string AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-address'

    UNION SELECT
        'email' AS type,
        'string' AS datatype,
        value_string AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-billing-email'

    UNION SELECT
        'photo' AS type,
        'file' AS datatype,
        (
            SELECT TRIM(CONCAT(
                'A:',
                IFNULL(TRIM(filename), ''),
                '\nB:',
                IFNULL(TRIM(md5), ''),
                '\nC:',
                IFNULL(TRIM(s3_key), ''),
                '\nD:',
                IFNULL(TRIM(url), ''),
                '\nE:',
                IFNULL(filesize, '')
            )) FROM entu.file WHERE id = value_file LIMIT 1
        ) AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-photo'

    UNION SELECT
        'add_user' AS type,
        'reference' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        NULL AS value_decimal,
        value_integer AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-user-parent'

    UNION SELECT
        'billing_entities_limit' AS type,
        'integer' AS datatype,
        NULL AS value_string,
        value_integer AS value_integer,
        NULL AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-quota-entities'

    UNION SELECT
        'billing_data_limit' AS type,
        'decimal' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        value_decimal AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-quota-data'

    UNION SELECT
        'price' AS type,
        'decimal' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        value_decimal AS value_decimal,
        NULL AS value_reference,
        created,
        deleted,
        is_deleted,
        entity_id
    FROM entu.property
    WHERE property_definition_keyname = 'customer-monthly-fee'

) AS u,
    entu.property AS p,
    entu.entity AS e
WHERE (p.entity_id = u.entity_id OR u.entity_id = -1)
AND e.id = p.entity_id
AND e.is_deleted = 0
AND p.property_definition_keyname = 'customer-database-name'
AND p.is_deleted = 0
AND p.value_string = ?;
