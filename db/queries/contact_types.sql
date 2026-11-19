-- ==========================================
-- CONTACT_TYPES
-- ==========================================

-- name: CreateContactType :one
INSERT INTO contact_types (
    name
) VALUES (
    $1
)
RETURNING *;

-- name: GetContactTypeByID :one
SELECT *
FROM contact_types
WHERE id = $1;

-- name: ListContactTypes :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM contact_types
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY name, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountContactTypes :one
-- Total rows for the same filters as ListContactTypes (for pagination metadata).
SELECT COUNT(*)
FROM contact_types
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateContactType :one
-- Partial update: NULL params keep the existing value.
UPDATE contact_types
SET name = COALESCE(sqlc.narg('name'), name),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetContactTypeActive :exec
-- Soft delete (false) / restore (true).
UPDATE contact_types
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteContactType :exec
-- Hard delete.
DELETE FROM contact_types
WHERE id = $1;

-- name: GetContactTypeStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM contact_types;
