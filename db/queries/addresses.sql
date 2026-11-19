-- ==========================================
-- ADDRESSES
-- ==========================================

-- name: CreateAddress :one
INSERT INTO addresses (
    address_type_id,
    line_one,
    line_two,
    pin_code,
    country_id,
    state_id,
    district_id,
    taluka_id
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
)
RETURNING *;

-- name: GetAddressByID :one
SELECT *
FROM addresses
WHERE id = $1;

-- name: ListAddresses :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT *
FROM addresses
WHERE (sqlc.narg('search')::text IS NULL
       OR line_one ILIKE '%' || sqlc.narg('search') || '%'
       OR line_two ILIKE '%' || sqlc.narg('search') || '%'
       OR pin_code ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('address_type_id')::int IS NULL OR address_type_id = sqlc.narg('address_type_id'))
  AND (sqlc.narg('country_id')::int IS NULL OR country_id = sqlc.narg('country_id'))
  AND (sqlc.narg('state_id')::int IS NULL OR state_id = sqlc.narg('state_id'))
  AND (sqlc.narg('district_id')::int IS NULL OR district_id = sqlc.narg('district_id'))
  AND (sqlc.narg('taluka_id')::int IS NULL OR taluka_id = sqlc.narg('taluka_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountAddresses :one
-- Total rows for the same filters as ListAddresses (for pagination metadata).
SELECT COUNT(*)
FROM addresses
WHERE (sqlc.narg('search')::text IS NULL
       OR line_one ILIKE '%' || sqlc.narg('search') || '%'
       OR line_two ILIKE '%' || sqlc.narg('search') || '%'
       OR pin_code ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('address_type_id')::int IS NULL OR address_type_id = sqlc.narg('address_type_id'))
  AND (sqlc.narg('country_id')::int IS NULL OR country_id = sqlc.narg('country_id'))
  AND (sqlc.narg('state_id')::int IS NULL OR state_id = sqlc.narg('state_id'))
  AND (sqlc.narg('district_id')::int IS NULL OR district_id = sqlc.narg('district_id'))
  AND (sqlc.narg('taluka_id')::int IS NULL OR taluka_id = sqlc.narg('taluka_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateAddress :one
-- Partial update: NULL params keep the existing value.
UPDATE addresses
SET address_type_id = COALESCE(sqlc.narg('address_type_id'), address_type_id),
    line_one = COALESCE(sqlc.narg('line_one'), line_one),
    line_two = COALESCE(sqlc.narg('line_two'), line_two),
    pin_code = COALESCE(sqlc.narg('pin_code'), pin_code),
    country_id = COALESCE(sqlc.narg('country_id'), country_id),
    state_id = COALESCE(sqlc.narg('state_id'), state_id),
    district_id = COALESCE(sqlc.narg('district_id'), district_id),
    taluka_id = COALESCE(sqlc.narg('taluka_id'), taluka_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: SetAddressActive :exec
-- Soft delete (false) / restore (true).
UPDATE addresses
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteAddress :exec
-- Hard delete.
DELETE FROM addresses
WHERE id = $1;

-- name: GetAddressStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM addresses;

-- name: CountAddressesByAddressType :many
SELECT p.id AS address_type_id, p.name AS address_type_name, COUNT(c.id) AS addresses_count
FROM address_types p
LEFT JOIN addresses c ON c.address_type_id = p.id
GROUP BY p.id, p.name
ORDER BY addresses_count DESC, p.name;
