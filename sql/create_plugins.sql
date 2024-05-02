/* ester, csv plugins */
INSERT INTO mongo (
    entity,
    type,
    language,
    datatype,
    value_string,
    value_integer,
    value_reference
) SELECT conf.* FROM (
    SELECT
        'plugin_ester' AS entity,
        '_type' AS type,
        NULL AS language,
        'reference' AS datatype,
        NULL AS value_string,
        NULL AS value_integer,
        'plugin' AS value_reference
    UNION SELECT 'plugin_ester', '_parent', NULL, 'reference', NULL, NULL, CONCAT('database_entity_', ?)
    UNION SELECT 'plugin_ester', '_sharing', NULL, 'string', 'domain', NULL, NULL
    UNION SELECT 'plugin_ester', '_inheritrights', NULL, 'boolean', NULL, 1, NULL
    UNION SELECT 'plugin_ester', 'name', 'et', 'string', 'ESTER kataloog', NULL, NULL
    UNION SELECT 'plugin_ester', 'name', 'en', 'string', 'ESTER catalogue', NULL, NULL
    UNION SELECT 'plugin_ester', 'type', NULL, 'string', 'entity-add', NULL, NULL
    UNION SELECT 'plugin_ester', 'url', NULL, 'string', 'https://plugin.entu.app/ester', NULL, NULL

    UNION SELECT 'plugin_csv', '_type', NULL, 'reference', NULL, NULL, 'plugin'
    UNION SELECT 'plugin_csv', '_parent', NULL, 'reference', NULL, NULL, CONCAT('database_entity_', ?)
    UNION SELECT 'plugin_csv', '_sharing', NULL, 'string', 'domain', NULL, NULL
    UNION SELECT 'plugin_csv', '_inheritrights', NULL, 'boolean', NULL, 1, NULL
    UNION SELECT 'plugin_csv', 'name', 'et', 'string', 'CSV fail', NULL, NULL
    UNION SELECT 'plugin_csv', 'name', 'en', 'string', 'CSV file', NULL, NULL
    UNION SELECT 'plugin_csv', 'type', NULL, 'string', 'entity-add', NULL, NULL
    UNION SELECT 'plugin_csv', 'url', NULL, 'string', 'https://plugin.entu.app/csv', NULL, NULL
) conf,
(
  SELECT DISTINCT 'plugin_ester' AS entity
  FROM entity_definition
  WHERE actions_add LIKE '%ester%'
  AND keyname IN (SELECT keyname FROM mongo_entity_keyname)

  UNION SELECT 'plugin_csv' AS plugin
  FROM entity_definition
  WHERE actions_add LIKE '%csv%'
  AND keyname IN (SELECT keyname FROM mongo_entity_keyname)
) AS plugin
WHERE plugin.entity = conf.entity;
