-- ==========================================
-- STATES
-- ==========================================

-- name: CreateState :one
INSERT INTO states (
    name,
    country_id
) VALUES (
    $1, $2
)
RETURNING *;

-- name: GetStateByID :one
SELECT *
FROM states
WHERE id = $1;

-- name: ListStates :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM states
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('country_id')::int IS NULL OR country_id = sqlc.narg('country_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountStates :one
-- Total rows for the same filters as ListStates (for pagination metadata).
SELECT COUNT(*)
FROM states
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('country_id')::int IS NULL OR country_id = sqlc.narg('country_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateState :one
-- Partial update: NULL params keep the existing value.
UPDATE states
SET name = COALESCE(sqlc.narg('name'), name),
    country_id = COALESCE(sqlc.narg('country_id'), country_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetStateActive :exec
-- Soft delete (false) / restore (true).
UPDATE states
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteState :exec
-- Hard delete.
DELETE FROM states
WHERE id = $1;

-- name: GetStateStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM states;

-- name: CountStatesByCountry :many
SELECT p.id AS country_id, p.name AS country_name, COUNT(c.id) AS states_count
FROM countries p
LEFT JOIN states c ON c.country_id = p.id
GROUP BY p.id, p.name
ORDER BY states_count DESC, p.name;
