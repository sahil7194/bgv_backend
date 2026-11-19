-- ==========================================
-- REFERENCE_VERIFICATIONS
-- ==========================================

-- name: CreateReferenceVerification :one
INSERT INTO reference_verifications (
    employee_id,
    verification_status_id,
    client_review,
    initiated_at
) VALUES (
    $1, $2, $3, $4
)
RETURNING *;

-- name: GetReferenceVerificationByID :one
SELECT *
FROM reference_verifications
WHERE id = $1;

-- name: ListReferenceVerifications :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM reference_verifications
WHERE (sqlc.narg('employee_id')::int IS NULL OR employee_id = sqlc.narg('employee_id'))
  AND (sqlc.narg('verification_status_id')::int IS NULL OR verification_status_id = sqlc.narg('verification_status_id'))
  AND (sqlc.narg('is_initiated')::boolean IS NULL OR (initiated_at IS NOT NULL) = sqlc.narg('is_initiated'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountReferenceVerifications :one
-- Total rows for the same filters as ListReferenceVerifications (for pagination metadata).
SELECT COUNT(*)
FROM reference_verifications
WHERE (sqlc.narg('employee_id')::int IS NULL OR employee_id = sqlc.narg('employee_id'))
  AND (sqlc.narg('verification_status_id')::int IS NULL OR verification_status_id = sqlc.narg('verification_status_id'))
  AND (sqlc.narg('is_initiated')::boolean IS NULL OR (initiated_at IS NOT NULL) = sqlc.narg('is_initiated'));

-- name: UpdateReferenceVerification :one
-- Partial update: NULL params keep the existing value.
UPDATE reference_verifications
SET employee_id = COALESCE(sqlc.narg('employee_id'), employee_id),
    verification_status_id = COALESCE(sqlc.narg('verification_status_id'), verification_status_id),
    client_review = COALESCE(sqlc.narg('client_review'), client_review),
    initiated_at = COALESCE(sqlc.narg('initiated_at'), initiated_at),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: DeleteReferenceVerification :exec
-- Hard delete.
DELETE FROM reference_verifications
WHERE id = $1;

-- name: GetReferenceVerificationStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE initiated_at IS NOT NULL) AS initiated,
    COUNT(*) FILTER (WHERE initiated_at IS NULL) AS not_initiated,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM reference_verifications;

-- name: CountReferenceVerificationsByStatus :many
SELECT p.id AS verification_status_id, p.title AS verification_status_title, COUNT(c.id) AS reference_verifications_count
FROM verification_statuses p
LEFT JOIN reference_verifications c ON c.verification_status_id = p.id
GROUP BY p.id, p.title
ORDER BY reference_verifications_count DESC, p.title;

-- name: GetReferenceVerificationsByEmployee :many
SELECT *
FROM reference_verifications
WHERE employee_id = $1
ORDER BY created_at DESC, id DESC;
