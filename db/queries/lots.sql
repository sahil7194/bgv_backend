-- ==========================================
-- LOTS
-- ==========================================

-- name: CreateLot :one
INSERT INTO lots (
    name,
    company_id
) VALUES (
    $1, $2
)
RETURNING *;

-- name: GetLotByID :one
SELECT *
FROM lots
WHERE id = $1;

-- name: ListLots :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM lots
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountLots :one
-- Total rows for the same filters as ListLots (for pagination metadata).
SELECT COUNT(*)
FROM lots
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateLot :one
-- Partial update: NULL params keep the existing value.
UPDATE lots
SET name = COALESCE(sqlc.narg('name'), name),
    company_id = COALESCE(sqlc.narg('company_id'), company_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetLotActive :exec
-- Soft delete (false) / restore (true).
UPDATE lots
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteLot :exec
-- Hard delete.
DELETE FROM lots
WHERE id = $1;

-- name: GetLotStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM lots;

-- name: CountLotsByCompany :many
SELECT p.id AS company_id, p.name AS company_name, COUNT(c.id) AS lots_count
FROM companies p
LEFT JOIN lots c ON c.company_id = p.id
GROUP BY p.id, p.name
ORDER BY lots_count DESC, p.name;
