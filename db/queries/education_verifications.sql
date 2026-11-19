-- ==========================================
-- EDUCATION_VERIFICATIONS
-- ==========================================

-- name: CreateEducationVerification :one
INSERT INTO education_verifications (
    employee_id,
    verification_status_id,
    client_review,
    initiated_at
) VALUES (
    $1, $2, $3, $4
)
RETURNING *;

-- name: GetEducationVerificationByID :one
SELECT *
FROM education_verifications
WHERE id = $1;

-- name: ListEducationVerifications :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM education_verifications
WHERE (sqlc.narg('employee_id')::int IS NULL OR employee_id = sqlc.narg('employee_id'))
  AND (sqlc.narg('verification_status_id')::int IS NULL OR verification_status_id = sqlc.narg('verification_status_id'))
  AND (sqlc.narg('is_initiated')::boolean IS NULL OR (initiated_at IS NOT NULL) = sqlc.narg('is_initiated'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountEducationVerifications :one
-- Total rows for the same filters as ListEducationVerifications (for pagination metadata).
SELECT COUNT(*)
FROM education_verifications
WHERE (sqlc.narg('employee_id')::int IS NULL OR employee_id = sqlc.narg('employee_id'))
  AND (sqlc.narg('verification_status_id')::int IS NULL OR verification_status_id = sqlc.narg('verification_status_id'))
  AND (sqlc.narg('is_initiated')::boolean IS NULL OR (initiated_at IS NOT NULL) = sqlc.narg('is_initiated'));

-- name: UpdateEducationVerification :one
-- Partial update: NULL params keep the existing value.
UPDATE education_verifications
SET employee_id = COALESCE(sqlc.narg('employee_id'), employee_id),
    verification_status_id = COALESCE(sqlc.narg('verification_status_id'), verification_status_id),
    client_review = COALESCE(sqlc.narg('client_review'), client_review),
    initiated_at = COALESCE(sqlc.narg('initiated_at'), initiated_at),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: DeleteEducationVerification :exec
-- Hard delete.
DELETE FROM education_verifications
WHERE id = $1;

-- name: GetEducationVerificationStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE initiated_at IS NOT NULL) AS initiated,
    COUNT(*) FILTER (WHERE initiated_at IS NULL) AS not_initiated,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM education_verifications;

-- name: CountEducationVerificationsByStatus :many
SELECT p.id AS verification_status_id, p.title AS verification_status_title, COUNT(c.id) AS education_verifications_count
FROM verification_statuses p
LEFT JOIN education_verifications c ON c.verification_status_id = p.id
GROUP BY p.id, p.title
ORDER BY education_verifications_count DESC, p.title;

-- name: GetEducationVerificationsByEmployee :many
SELECT *
FROM education_verifications
WHERE employee_id = $1
ORDER BY created_at DESC, id DESC;
