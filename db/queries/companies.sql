-- ==========================================
-- COMPANIES
-- ==========================================

-- name: CreateCompany :one
INSERT INTO companies (
    name,
    official_name,
    website,
    registered_address_id,
    corporate_address_id
) VALUES (
    $1, $2, $3, $4, $5
)
RETURNING *;

-- name: GetCompanyByID :one
SELECT *
FROM companies
WHERE id = $1;

-- name: ListCompanies :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM companies
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%'
       OR official_name ILIKE '%' || sqlc.narg('search') || '%'
       OR website ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountCompanies :one
-- Total rows for the same filters as ListCompanies (for pagination metadata).
SELECT COUNT(*)
FROM companies
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%'
       OR official_name ILIKE '%' || sqlc.narg('search') || '%'
       OR website ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateCompany :one
-- Partial update: NULL params keep the existing value.
UPDATE companies
SET name = COALESCE(sqlc.narg('name'), name),
    official_name = COALESCE(sqlc.narg('official_name'), official_name),
    website = COALESCE(sqlc.narg('website'), website),
    registered_address_id = COALESCE(sqlc.narg('registered_address_id'), registered_address_id),
    corporate_address_id = COALESCE(sqlc.narg('corporate_address_id'), corporate_address_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetCompanyActive :exec
-- Soft delete (false) / restore (true).
UPDATE companies
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteCompany :exec
-- Hard delete.
DELETE FROM companies
WHERE id = $1;

-- name: GetCompanyStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM companies;
