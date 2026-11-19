CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    gender VARCHAR(20),
    date_of_birth DATE,
    email VARCHAR(255) NOT NULL UNIQUE,
    mobile VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    team_id INTEGER REFERENCES teams (id),
    level_id INTEGER REFERENCES levels (id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_team_id ON users (team_id);
CREATE INDEX IF NOT EXISTS idx_users_level_id ON users (level_id);
