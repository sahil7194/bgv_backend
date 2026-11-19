CREATE TABLE IF NOT EXISTS identity_verifications (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees (id),
    verification_status_id INTEGER NOT NULL REFERENCES verification_statuses (id),
    client_review TEXT,
    initiated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_identity_verifications_employee_id ON identity_verifications (employee_id);
CREATE INDEX IF NOT EXISTS idx_identity_verifications_verification_status_id ON identity_verifications (verification_status_id);
