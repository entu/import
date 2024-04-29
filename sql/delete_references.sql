UPDATE
  mongo,
  (
    SELECT
        e.id,
        e.deleted,
        IF(TRIM(e.deleted_by) REGEXP '^-?[0-9]+$', TRIM(e.deleted_by), NULL) AS deleted_by
    FROM
        entity AS e,
        mongo_entity_keyname AS mek
    WHERE mek.keyname = e.entity_definition_keyname
    AND e.is_deleted = 1
  ) AS entity
SET
  mongo.deleted_at = entity.deleted,
  mongo.deleted_by = entity.deleted_by
WHERE entity.id = mongo.value_reference
AND mongo.datatype = 'reference'
AND mongo.deleted_at IS NULL;
