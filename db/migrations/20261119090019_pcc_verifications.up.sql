CREATE TABLE IF NOT EXISTS pcc_verifications (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees (id),
    verification_status_id INTEGER NOT NULL REFERENCES verification_statuses (id),
    client_review TEXT,
    initiated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pcc_verifications_employee_id ON pcc_verifications (employee_id);
CREATE INDEX IF NOT EXISTS idx_pcc_verifications_verification_status_id ON pcc_verifications (verification_status_id);
