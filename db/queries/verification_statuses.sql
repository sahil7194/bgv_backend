-- ==========================================
-- VERIFICATION_STATUSES
-- ==========================================

-- name: CreateVerificationStatus :one
INSERT INTO verification_statuses (
    title,
    description,
    type,
    show_on_report
) VALUES (
    $1, $2, $3, $4
)
RETURNING *;

-- name: GetVerificationStatusByID :one
SELECT *
FROM verification_statuses
WHERE id = $1;

-- name: ListVerificationStatuses :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM verification_statuses
WHERE (sqlc.narg('search')::text IS NULL
       OR title ILIKE '%' || sqlc.narg('search') || '%'
       OR description ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('type')::text IS NULL OR type = sqlc.narg('type'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY title, id
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountVerificationStatuses :one
-- Total rows for the same filters as ListVerificationStatuses (for pagination metadata).
SELECT COUNT(*)
FROM verification_statuses
WHERE (sqlc.narg('search')::text IS NULL
       OR title ILIKE '%' || sqlc.narg('search') || '%'
       OR description ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('type')::text IS NULL OR type = sqlc.narg('type'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateVerificationStatus :one
-- Partial update: NULL params keep the existing value.
UPDATE verification_statuses
SET title = COALESCE(sqlc.narg('title'), title),
    description = COALESCE(sqlc.narg('description'), description),
    type = COALESCE(sqlc.narg('type'), type),
    show_on_report = COALESCE(sqlc.narg('show_on_report'), show_on_report),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetVerificationStatusActive :exec
-- Soft delete (false) / restore (true).
UPDATE verification_statuses
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteVerificationStatus :exec
-- Hard delete.
DELETE FROM verification_statuses
WHERE id = $1;

-- name: GetVerificationStatusStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM verification_statuses;

-- name: CountVerificationStatusesByType :many
SELECT type, COUNT(*) AS verification_statuses_count
FROM verification_statuses
GROUP BY type
ORDER BY verification_statuses_count DESC, type;
