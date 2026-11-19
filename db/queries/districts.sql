-- ==========================================
-- DISTRICTS
-- ==========================================

-- name: CreateDistrict :one
INSERT INTO districts (
    name,
    state_id
) VALUES (
    $1, $2
)
RETURNING *;

-- name: GetDistrictByID :one
SELECT *
FROM districts
WHERE id = $1;

-- name: ListDistricts :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM districts
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('state_id')::int IS NULL OR state_id = sqlc.narg('state_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountDistricts :one
-- Total rows for the same filters as ListDistricts (for pagination metadata).
SELECT COUNT(*)
FROM districts
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('state_id')::int IS NULL OR state_id = sqlc.narg('state_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateDistrict :one
-- Partial update: NULL params keep the existing value.
UPDATE districts
SET name = COALESCE(sqlc.narg('name'), name),
    state_id = COALESCE(sqlc.narg('state_id'), state_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetDistrictActive :exec
-- Soft delete (false) / restore (true).
UPDATE districts
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteDistrict :exec
-- Hard delete.
DELETE FROM districts
WHERE id = $1;

-- name: GetDistrictStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM districts;

-- name: CountDistrictsByState :many
SELECT p.id AS state_id, p.name AS state_name, COUNT(c.id) AS districts_count
FROM states p
LEFT JOIN districts c ON c.state_id = p.id
GROUP BY p.id, p.name
ORDER BY districts_count DESC, p.name;
