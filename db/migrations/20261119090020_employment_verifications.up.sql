CREATE TABLE IF NOT EXISTS employment_verifications (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees (id),
    verification_status_id INTEGER NOT NULL REFERENCES verification_statuses (id),
    client_review TEXT,
    initiated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_employment_verifications_employee_id ON employment_verifications (employee_id);
CREATE INDEX IF NOT EXISTS idx_employment_verifications_verification_status_id ON employment_verifications (verification_status_id);
