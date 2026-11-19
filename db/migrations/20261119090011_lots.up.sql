CREATE TABLE IF NOT EXISTS lots (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    company_id INTEGER NOT NULL REFERENCES companies (id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lots_company_id ON lots (company_id);
