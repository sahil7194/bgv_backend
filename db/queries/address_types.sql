-- ==========================================
-- ADDRESS_TYPES
-- ==========================================

-- name: CreateAddressType :one
INSERT INTO address_types (
    name
) VALUES (
    $1
)
RETURNING *;

-- name: GetAddressTypeByID :one
SELECT *
FROM address_types
WHERE id = $1;

-- name: ListAddressTypes :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM address_types
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountAddressTypes :one
-- Total rows for the same filters as ListAddressTypes (for pagination metadata).
SELECT COUNT(*)
FROM address_types
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateAddressType :one
-- Partial update: NULL params keep the existing value.
UPDATE address_types
SET name = COALESCE(sqlc.narg('name'), name),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetAddressTypeActive :exec
-- Soft delete (false) / restore (true).
UPDATE address_types
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteAddressType :exec
-- Hard delete.
DELETE FROM address_types
WHERE id = $1;

-- name: GetAddressTypeStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM address_types;
