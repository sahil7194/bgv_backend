-- ==========================================
-- TALUKAS
-- ==========================================

-- name: CreateTaluka :one
INSERT INTO talukas (
    name,
    district_id
) VALUES (
    $1, $2
)
RETURNING *;

-- name: GetTalukaByID :one
SELECT *
FROM talukas
WHERE id = $1;

-- name: ListTalukas :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM talukas
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('district_id')::int IS NULL OR district_id = sqlc.narg('district_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountTalukas :one
-- Total rows for the same filters as ListTalukas (for pagination metadata).
SELECT COUNT(*)
FROM talukas
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('district_id')::int IS NULL OR district_id = sqlc.narg('district_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateTaluka :one
-- Partial update: NULL params keep the existing value.
UPDATE talukas
SET name = COALESCE(sqlc.narg('name'), name),
    district_id = COALESCE(sqlc.narg('district_id'), district_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetTalukaActive :exec
-- Soft delete (false) / restore (true).
UPDATE talukas
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteTaluka :exec
-- Hard delete.
DELETE FROM talukas
WHERE id = $1;

-- name: GetTalukaStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM talukas;

-- name: CountTalukasByDistrict :many
SELECT p.id AS district_id, p.name AS district_name, COUNT(c.id) AS talukas_count
FROM districts p
LEFT JOIN talukas c ON c.district_id = p.id
GROUP BY p.id, p.name
ORDER BY talukas_count DESC, p.name;
