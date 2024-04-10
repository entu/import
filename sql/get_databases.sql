SELECT DISTINCT TABLE_SCHEMA AS db
FROM information_schema.TABLES
WHERE TABLE_SCHEMA NOT IN (
    '_template',
    '_template_minimal',
    'information_schema',
    'mysql',
    'performance_schema',
    'sys',

    'estdev',
    'emi',
    'roots'
)
ORDER BY TABLE_SCHEMA;
