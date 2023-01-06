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
    `value_double` decimal(15,4) DEFAULT NULL,
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
