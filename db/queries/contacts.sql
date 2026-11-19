-- ==========================================
-- CONTACTS
-- ==========================================

-- name: CreateContact :one
INSERT INTO contacts (
    name,
    email,
    company_id,
    contact_type_id,
    is_helpfull
) VALUES (
    $1, $2, $3, $4, $5
)
RETURNING *;

-- name: GetContactByID :one
SELECT *
FROM contacts
WHERE id = $1;

-- name: ListContacts :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM contacts
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%'
       OR email ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('contact_type_id')::int IS NULL OR contact_type_id = sqlc.narg('contact_type_id'))
  AND (sqlc.narg('is_helpfull')::boolean IS NULL OR is_helpfull = sqlc.narg('is_helpfull'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountContacts :one
-- Total rows for the same filters as ListContacts (for pagination metadata).
SELECT COUNT(*)
FROM contacts
WHERE (sqlc.narg('search')::text IS NULL
       OR name ILIKE '%' || sqlc.narg('search') || '%'
       OR email ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('contact_type_id')::int IS NULL OR contact_type_id = sqlc.narg('contact_type_id'))
  AND (sqlc.narg('is_helpfull')::boolean IS NULL OR is_helpfull = sqlc.narg('is_helpfull'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateContact :one
-- Partial update: NULL params keep the existing value.
UPDATE contacts
SET name = COALESCE(sqlc.narg('name'), name),
    email = COALESCE(sqlc.narg('email'), email),
    company_id = COALESCE(sqlc.narg('company_id'), company_id),
    contact_type_id = COALESCE(sqlc.narg('contact_type_id'), contact_type_id),
    is_helpfull = COALESCE(sqlc.narg('is_helpfull'), is_helpfull),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetContactActive :exec
-- Soft delete (false) / restore (true).
UPDATE contacts
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteContact :exec
-- Hard delete.
DELETE FROM contacts
WHERE id = $1;

-- name: GetContactStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE is_helpfull) AS helpful,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM contacts;

-- name: CountContactsByCompany :many
SELECT p.id AS company_id, p.name AS company_name, COUNT(c.id) AS contacts_count
FROM companies p
LEFT JOIN contacts c ON c.company_id = p.id
GROUP BY p.id, p.name
ORDER BY contacts_count DESC, p.name;

-- name: CountContactsByContactType :many
SELECT p.id AS contact_type_id, p.name AS contact_type_name, COUNT(c.id) AS contacts_count
FROM contact_types p
LEFT JOIN contacts c ON c.contact_type_id = p.id
GROUP BY p.id, p.name
ORDER BY contacts_count DESC, p.name;
