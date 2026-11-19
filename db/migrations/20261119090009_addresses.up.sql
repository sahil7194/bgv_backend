CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    address_type_id INTEGER NOT NULL REFERENCES address_types (id),
    line_one VARCHAR(255) NOT NULL,
    line_two VARCHAR(255),
    pin_code VARCHAR(20),
    country_id INTEGER REFERENCES countries (id),
    state_id INTEGER REFERENCES states (id),
    district_id INTEGER REFERENCES districts (id),
    taluka_id INTEGER REFERENCES talukas (id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_addresses_address_type_id ON addresses (address_type_id);
CREATE INDEX IF NOT EXISTS idx_addresses_country_id ON addresses (country_id);
CREATE INDEX IF NOT EXISTS idx_addresses_state_id ON addresses (state_id);
CREATE INDEX IF NOT EXISTS idx_addresses_district_id ON addresses (district_id);
CREATE INDEX IF NOT EXISTS idx_addresses_taluka_id ON addresses (taluka_id);
