-- ==========================================
-- USERS
-- Reads exclude the password column; use GetUserByEmailForAuth for login.
-- ==========================================

-- name: CreateUser :one
INSERT INTO users (
    first_name,
    last_name,
    gender,
    date_of_birth,
    email,
    mobile,
    password,
    team_id,
    level_id
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
)
RETURNING id, first_name, last_name, gender, date_of_birth, email, mobile,
          is_active, team_id, level_id, created_at, updated_at;

-- name: GetUserByID :one
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile,
       is_active, team_id, level_id, created_at, updated_at
FROM users
WHERE id = $1;

-- name: GetUserByEmail :one
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile,
       is_active, team_id, level_id, created_at, updated_at
FROM users
WHERE email = $1;

-- name: GetUserByEmailForAuth :one
SELECT id, email, password, is_active
FROM users
WHERE email = $1;

-- name: ListUsers :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile,
       is_active, team_id, level_id, created_at, updated_at
FROM users
WHERE (sqlc.narg('search')::text IS NULL
       OR first_name ILIKE '%' || sqlc.narg('search') || '%'
       OR last_name  ILIKE '%' || sqlc.narg('search') || '%'
       OR email      ILIKE '%' || sqlc.narg('search') || '%'
       OR mobile     ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('team_id')::int   IS NULL OR team_id   = sqlc.narg('team_id'))
  AND (sqlc.narg('level_id')::int  IS NULL OR level_id  = sqlc.narg('level_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountUsers :one
-- Total rows for the same filters as ListUsers (for pagination metadata).
SELECT COUNT(*)
FROM users
WHERE (sqlc.narg('search')::text IS NULL
       OR first_name ILIKE '%' || sqlc.narg('search') || '%'
       OR last_name  ILIKE '%' || sqlc.narg('search') || '%'
       OR email      ILIKE '%' || sqlc.narg('search') || '%'
       OR mobile     ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('team_id')::int   IS NULL OR team_id   = sqlc.narg('team_id'))
  AND (sqlc.narg('level_id')::int  IS NULL OR level_id  = sqlc.narg('level_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateUser :one
-- Partial update: NULL params keep the existing value.
UPDATE users
SET first_name    = COALESCE(sqlc.narg('first_name'), first_name),
    last_name     = COALESCE(sqlc.narg('last_name'), last_name),
    gender        = COALESCE(sqlc.narg('gender'), gender),
    date_of_birth = COALESCE(sqlc.narg('date_of_birth'), date_of_birth),
    email         = COALESCE(sqlc.narg('email'), email),
    mobile        = COALESCE(sqlc.narg('mobile'), mobile),
    team_id       = COALESCE(sqlc.narg('team_id'), team_id),
    level_id      = COALESCE(sqlc.narg('level_id'), level_id),
    updated_at    = NOW()
WHERE id = sqlc.arg('id')
RETURNING id, first_name, last_name, gender, date_of_birth, email, mobile,
          is_active, team_id, level_id, created_at, updated_at;

-- name: UpdateUserPassword :exec
UPDATE users
SET password = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: SetUserActive :exec
-- Soft delete (false) / restore (true).
UPDATE users
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteUser :exec
-- Hard delete.
DELETE FROM users
WHERE id = $1;

-- name: GetUserStats :one
SELECT
    COUNT(*)                                                         AS total,
    COUNT(*) FILTER (WHERE is_active)                                AS active,
    COUNT(*) FILTER (WHERE NOT is_active)                            AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW()))   AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW()))  AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM users;

-- name: CountUsersByTeam :many
SELECT t.id AS team_id, t.name AS team_name, COUNT(u.id) AS users_count
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
GROUP BY t.id, t.name
ORDER BY users_count DESC, t.name;
