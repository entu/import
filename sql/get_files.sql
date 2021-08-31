-- UPDATE file SET changed = NULL, changed_by = NULL;

SELECT
    id,
    md5,
    s3_key,
    url,
    filesize
FROM file
WHERE s3_key IS NOT NULL
AND s3_key != ''
AND changed_by IS NULL
-- AND filesize <= 2147483647
ORDER BY filesize;
