UPDATE mongo
SET imported = 1
WHERE id IN (?);
