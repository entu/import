-- UPDATE file SET changed = NULL, changed_by = NULL WHERE changed_by != DO;

SELECT
    id,
    md5,
    s3_key,
    url,
    filesize
FROM file
WHERE s3_key IS NOT NULL
AND s3_key != ''
-- AND changed_by IS NULL
AND (changed_by != 'DO' OR changed_by IS NULL)
-- AND filesize <= 2147483647
-- AND filesize > 1000000000
ORDER BY filesize;
