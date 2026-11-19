CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    official_name VARCHAR(255),
    website VARCHAR(255),
    registered_address_id INTEGER REFERENCES addresses (id),
    corporate_address_id INTEGER REFERENCES addresses (id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_companies_registered_address_id ON companies (registered_address_id);
CREATE INDEX IF NOT EXISTS idx_companies_corporate_address_id ON companies (corporate_address_id);
