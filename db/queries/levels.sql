-- ==========================================
-- LEVELS
-- ==========================================

-- name: CreateLevel :one
INSERT INTO levels (
    name,
    team_id
) VALUES (
    $1, $2
)
RETURNING *;

-- name: GetLevelByID :one
SELECT *
FROM levels
WHERE id = $1;

-- name: ListLevels :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM levels
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('team_id')::int IS NULL OR team_id = sqlc.narg('team_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountLevels :one
-- Total rows for the same filters as ListLevels (for pagination metadata).
SELECT COUNT(*)
FROM levels
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('team_id')::int IS NULL OR team_id = sqlc.narg('team_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateLevel :one
-- Partial update: NULL params keep the existing value.
UPDATE levels
SET name = COALESCE(sqlc.narg('name'), name),
    team_id = COALESCE(sqlc.narg('team_id'), team_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetLevelActive :exec
-- Soft delete (false) / restore (true).
UPDATE levels
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteLevel :exec
-- Hard delete.
DELETE FROM levels
WHERE id = $1;

-- name: GetLevelStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM levels;

-- name: CountLevelsByTeam :many
SELECT p.id AS team_id, p.name AS team_name, COUNT(c.id) AS levels_count
FROM teams p
LEFT JOIN levels c ON c.team_id = p.id
GROUP BY p.id, p.name
ORDER BY levels_count DESC, p.name;
