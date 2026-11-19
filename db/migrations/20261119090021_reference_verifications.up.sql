CREATE TABLE IF NOT EXISTS reference_verifications (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees (id),
    verification_status_id INTEGER NOT NULL REFERENCES verification_statuses (id),
    client_review TEXT,
    initiated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reference_verifications_employee_id ON reference_verifications (employee_id);
CREATE INDEX IF NOT EXISTS idx_reference_verifications_verification_status_id ON reference_verifications (verification_status_id);
