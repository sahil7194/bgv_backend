-- ==========================================
-- TEAMS
-- ==========================================

-- name: CreateTeam :one
INSERT INTO teams (
    name
) VALUES (
    $1
)
RETURNING *;

-- name: GetTeamByID :one
SELECT *
FROM teams
WHERE id = $1;

-- name: ListTeams :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM teams
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountTeams :one
-- Total rows for the same filters as ListTeams (for pagination metadata).
SELECT COUNT(*)
FROM teams
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateTeam :one
-- Partial update: NULL params keep the existing value.
UPDATE teams
SET name = COALESCE(sqlc.narg('name'), name),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetTeamActive :exec
-- Soft delete (false) / restore (true).
UPDATE teams
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteTeam :exec
-- Hard delete.
DELETE FROM teams
WHERE id = $1;

-- name: GetTeamStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM teams;
