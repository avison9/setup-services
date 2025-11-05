---indexes creation
\c :"tenant"-analytics

-- Example indexes (adjust to real tables)
CREATE INDEX IF NOT EXISTS ix_staging_data_id
    ON staging.data (id) WITH (fillfactor = 80);

CREATE INDEX IF NOT EXISTS ix_processed_metrics_timestamp
    ON processed.metrics USING btree (timestamp DESC) WITH (fillfactor = 90);