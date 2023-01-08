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

DROP TABLE IF EXISTS props;

CREATE TABLE `props` (
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
    `conf` int(1) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `entity` (`entity`),
    KEY `type` (`type`),
    KEY `language` (`language`),
    KEY `datatype` (`datatype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS props_keyname;

CREATE TABLE `props_keyname` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `keyname` varchar(32) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO props_keyname (keyname)
SELECT DISTINCT entity_definition_keyname
FROM entity
WHERE id NOT IN (
    SELECT id FROM entity
    WHERE entity_definition_keyname LIKE 'conf-%'
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
