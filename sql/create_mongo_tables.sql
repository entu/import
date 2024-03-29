/* Fix invalid dates */
UPDATE entity SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE entity SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE entity SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';

UPDATE property SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE property SET value_datetime = NULL WHERE CAST(value_datetime AS CHAR(20)) = '0000-00-00 00:00:00';

UPDATE relationship SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE relationship SET changed = NULL WHERE CAST(changed AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE relationship SET deleted = NULL WHERE CAST(deleted AS CHAR(20)) = '0000-00-00 00:00:00';

DROP TABLE IF EXISTS mongo;
DROP TABLE IF EXISTS mongo_entity_keyname;
DROP TABLE IF EXISTS mongo_property_keyname;

CREATE TABLE `mongo` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `entity` varchar(64) DEFAULT NULL,
    `type` varchar(32) DEFAULT NULL,
    `language` varchar(2) DEFAULT NULL,
    `datatype` varchar(16) DEFAULT NULL,
    `value_string` text DEFAULT NULL,
    `value_integer` int(11) DEFAULT NULL,
    `value_decimal` decimal(15,4) DEFAULT NULL,
    `value_reference` varchar(64) DEFAULT NULL,
    `value_date` datetime DEFAULT NULL,
    `created_at` datetime DEFAULT NULL,
    `created_by` varchar(64) DEFAULT NULL,
    `deleted_at` datetime DEFAULT NULL,
    `deleted_by` varchar(64) DEFAULT NULL,
    `imported` tinyint(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `entity` (`entity`),
    KEY `type` (`type`),
    KEY `language` (`language`),
    KEY `datatype` (`datatype`),
    KEY `imported` (`imported`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mongo_entity_keyname` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `keyname` varchar(64) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `keyname` (`keyname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mongo_property_keyname` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `keyname` varchar(64) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `keyname` (`keyname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO mongo_entity_keyname (keyname)
SELECT DISTINCT entity_definition_keyname
FROM entity
WHERE id NOT IN (
    SELECT id FROM entity
    WHERE entity_definition_keyname LIKE 'conf-%'
    OR entity_definition_keyname = 'maintenancegroup'
    OR (entity_definition_keyname = 'acceptance-report' AND search LIKE '%Testvastuvõtuakt%')
    OR (entity_definition_keyname = 'audiovideo' AND search LIKE '%Testauvis%')
    OR (entity_definition_keyname = 'book' AND search LIKE '%Testraamat%')
    OR (entity_definition_keyname = 'class' AND search LIKE '%Testklass%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testauvis%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testdokument%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testkaust%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testklass%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testmahakandmisakt%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testmetoodika%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testõpik%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testperioodika%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testraamat%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testsaatedokument%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testtöövihik%')
    OR (entity_definition_keyname = 'copy' AND search LIKE '%Testvastuvõtuakt%')
    OR (entity_definition_keyname = 'document' AND search LIKE '%Testdokument%')
    OR (entity_definition_keyname = 'folder' AND search LIKE '%Testkaust%')
    OR (entity_definition_keyname = 'invoice' AND search LIKE '%Testsaatedokument%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testauvis%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testdokument%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testkaust%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testklass%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testmahakandmisakt%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testmetoodika%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testõpik%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testperioodika%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testraamat%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testsaatedokument%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testtöövihik%')
    OR (entity_definition_keyname = 'lending' AND search LIKE '%Testvastuvõtuakt%')
    OR (entity_definition_keyname = 'mahakandmisakt' AND search LIKE '%Testmahakandmisakt%')
    OR (entity_definition_keyname = 'methodical' AND search LIKE '%Testmetoodika%')
    OR (entity_definition_keyname = 'periodical' AND search LIKE '%Testperioodika%')
    OR (entity_definition_keyname = 'textbook' AND search LIKE '%Testõpik%')
    OR (entity_definition_keyname = 'workbook' AND search LIKE '%Testtöövihik%')
);

INSERT INTO mongo_property_keyname (keyname)
SELECT DISTINCT keyname
FROM property_definition
WHERE keyname NOT IN (
    'customer-analytics-code',
    'customer-auth-erply',
    'customer-auth-facebook',
    'customer-auth-google',
    'customer-auth-live',
    'customer-auth-mailgun',
    'customer-auth-mobileid',
    'customer-auth-s3',
    'customer-billing-email',
    'customer-database-host',
    'customer-database-password',
    'customer-database-port',
    'customer-database-ssl-ca',
    'customer-database-ssl-path',
    'customer-database-user',
    'customer-domain',
    'customer-entu-url',
    'customer-feedback-email',
    'customer-language-ref',
    'customer-language',
    'customer-maintenancegroup',
    'customer-mongodb',
    'customer-motd',
    'customer-path',
    'customer-regnr',
    'customer-tablepagesize',
    'customer-tagcloud',
    'sw-screen-health',
    'sw-screen-last-check',
    'sw-screen-last-update'
) AND dataproperty NOT IN (
    'entu-changed-at',
    'entu-changed-by',
    'entu-created-at',
    'entu-created-by'
) AND datatype NOT IN (
    'counter'
)
AND entity_definition_keyname IN (SELECT keyname FROM mongo_entity_keyname);
