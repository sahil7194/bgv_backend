-- ==========================================
-- PASSWORD_RESETS
-- ==========================================

-- name: CreatePasswordReset :one
INSERT INTO password_resets (
    email,
    token,
    expires_at
) VALUES (
    $1, $2, $3
)
RETURNING *;

-- name: GetPasswordResetByID :one
SELECT *
FROM password_resets
WHERE id = $1;

-- name: GetValidPasswordResetByToken :one
-- Only returns a token that is unused and not expired.
SELECT *
FROM password_resets
WHERE token = $1
  AND used_at IS NULL
  AND (expires_at IS NULL OR expires_at > NOW());

-- name: ListPasswordResets :many
-- Paginated list. All filters are optional (pass NULL to skip).
-- status: 'pending' | 'used' | 'expired'
SELECT *
FROM password_resets
WHERE (sqlc.narg('email')::text IS NULL OR email ILIKE '%' || sqlc.narg('email') || '%')
  AND (sqlc.narg('status')::text IS NULL
       OR (sqlc.narg('status') = 'used'    AND used_at IS NOT NULL)
       OR (sqlc.narg('status') = 'expired' AND used_at IS NULL AND expires_at <= NOW())
       OR (sqlc.narg('status') = 'pending' AND used_at IS NULL AND (expires_at IS NULL OR expires_at > NOW())))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountPasswordResets :one
-- Total rows for the same filters as ListPasswordResets (for pagination metadata).
SELECT COUNT(*)
FROM password_resets
WHERE (sqlc.narg('email')::text IS NULL OR email ILIKE '%' || sqlc.narg('email') || '%')
  AND (sqlc.narg('status')::text IS NULL
       OR (sqlc.narg('status') = 'used'    AND used_at IS NOT NULL)
       OR (sqlc.narg('status') = 'expired' AND used_at IS NULL AND expires_at <= NOW())
       OR (sqlc.narg('status') = 'pending' AND used_at IS NULL AND (expires_at IS NULL OR expires_at > NOW())));

-- name: MarkPasswordResetUsed :exec
UPDATE password_resets
SET used_at = NOW()
WHERE token = $1
  AND used_at IS NULL;

-- name: InvalidatePasswordResetsByEmail :exec
-- Mark every open token for an email as used (e.g. before issuing a new one).
UPDATE password_resets
SET used_at = NOW()
WHERE email = $1
  AND used_at IS NULL;

-- name: DeletePasswordReset :exec
DELETE FROM password_resets
WHERE id = $1;

-- name: DeleteExpiredPasswordResets :execrows
-- Cleanup job: removes used or expired tokens. Returns rows deleted.
DELETE FROM password_resets
WHERE used_at IS NOT NULL
   OR expires_at <= NOW();

-- name: GetPasswordResetStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE used_at IS NOT NULL) AS used,
    COUNT(*) FILTER (WHERE used_at IS NULL AND (expires_at IS NULL OR expires_at > NOW())) AS pending,
    COUNT(*) FILTER (WHERE used_at IS NULL AND expires_at <= NOW()) AS expired,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM password_resets;
