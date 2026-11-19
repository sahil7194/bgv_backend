CREATE TABLE IF NOT EXISTS talukas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES districts (id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_talukas_district_id ON talukas (district_id);
