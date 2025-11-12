"CREATE EXTENSION IF NOT EXISTS vector;",
"CREATE SCHEMA IF NOT EXISTS bedrock_integration;",
"DO $$ BEGIN CREATE ROLE bedrock_user LOGIN; EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'Role already exists'; END $$;",
"GRANT ALL ON SCHEMA bedrock_integration to bedrock_user;",
"SET SESSION AUTHORIZATION bedrock_user;",
"""
CREATE TABLE IF NOT EXISTS bedrock_integration.bedrock_kb (
    id uuid PRIMARY KEY,
    embedding vector(1536),
    chunks text,
    metadata json
);
""",
"CREATE INDEX IF NOT EXISTS bedrock_kb_embedding_idx ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops);"


"NEW SQL COMMAND YOU HAVE TO ADD IN THE END TO AVOID ERROR WHEN RUNNING terraform apply ON STACK2!"
"CREATE INDEX IF NOT EXISTS bedrock_kb_chunks_text_idx ON bedrock_integration.bedrock_kb USING gin (to_tsvector('english', chunks));"

"prueba"
"SELECT * FROM pg_extension;"
"
SELECT
        table_schema || '.' || table_name as show_tables
FROM
        information_schema.tables
WHERE
        table_type = 'BASE TABLE'
AND
        table_schema = 'bedrock_integration';
"