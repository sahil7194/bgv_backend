-- ==========================================
-- EMPLOYEES
-- ==========================================

-- name: CreateEmployee :one
INSERT INTO employees (
    first_name,
    last_name,
    gender,
    date_of_birth,
    email,
    mobile,
    password,
    company_id,
    lot_id
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
)
RETURNING id, first_name, last_name, gender, date_of_birth, email, mobile, company_id, lot_id, is_active, created_at, updated_at;

-- name: GetEmployeeByID :one
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile, company_id, lot_id, is_active, created_at, updated_at
FROM employees
WHERE id = $1;

-- name: ListEmployees :many
-- Paginated list. All filters are optional (pass NULL to skip).
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile, company_id, lot_id, is_active, created_at, updated_at
FROM employees
WHERE (sqlc.narg('search')::text IS NULL
       OR first_name ILIKE '%' || sqlc.narg('search') || '%'
       OR last_name ILIKE '%' || sqlc.narg('search') || '%'
       OR email ILIKE '%' || sqlc.narg('search') || '%'
       OR mobile ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('lot_id')::int IS NULL OR lot_id = sqlc.narg('lot_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'))
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('limit') OFFSET sqlc.arg('offset');

-- name: CountEmployees :one
-- Total rows for the same filters as ListEmployees (for pagination metadata).
SELECT COUNT(*)
FROM employees
WHERE (sqlc.narg('search')::text IS NULL
       OR first_name ILIKE '%' || sqlc.narg('search') || '%'
       OR last_name ILIKE '%' || sqlc.narg('search') || '%'
       OR email ILIKE '%' || sqlc.narg('search') || '%'
       OR mobile ILIKE '%' || sqlc.narg('search') || '%')
  AND (sqlc.narg('company_id')::int IS NULL OR company_id = sqlc.narg('company_id'))
  AND (sqlc.narg('lot_id')::int IS NULL OR lot_id = sqlc.narg('lot_id'))
  AND (sqlc.narg('is_active')::boolean IS NULL OR is_active = sqlc.narg('is_active'));

-- name: UpdateEmployee :one
-- Partial update: NULL params keep the existing value.
UPDATE employees
SET first_name = COALESCE(sqlc.narg('first_name'), first_name),
    last_name = COALESCE(sqlc.narg('last_name'), last_name),
    gender = COALESCE(sqlc.narg('gender'), gender),
    date_of_birth = COALESCE(sqlc.narg('date_of_birth'), date_of_birth),
    email = COALESCE(sqlc.narg('email'), email),
    mobile = COALESCE(sqlc.narg('mobile'), mobile),
    company_id = COALESCE(sqlc.narg('company_id'), company_id),
    lot_id = COALESCE(sqlc.narg('lot_id'), lot_id),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING id, first_name, last_name, gender, date_of_birth, email, mobile, company_id, lot_id, is_active, created_at, updated_at;

-- name: SetEmployeeActive :exec
-- Soft delete (false) / restore (true).
UPDATE employees
SET is_active = $2,
    updated_at = NOW()
WHERE id = $1;

-- name: DeleteEmployee :exec
-- Hard delete.
DELETE FROM employees
WHERE id = $1;

-- name: GetEmployeeStats :one
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE is_active) AS active,
    COUNT(*) FILTER (WHERE NOT is_active) AS inactive,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())) AS created_today,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('week', NOW())) AS created_this_week,
    COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())) AS created_this_month
FROM employees;

-- name: CountEmployeesByCompany :many
SELECT p.id AS company_id, p.name AS company_name, COUNT(c.id) AS employees_count
FROM companies p
LEFT JOIN employees c ON c.company_id = p.id
GROUP BY p.id, p.name
ORDER BY employees_count DESC, p.name;

-- name: CountEmployeesByLot :many
SELECT p.id AS lot_id, p.name AS lot_name, COUNT(c.id) AS employees_count
FROM lots p
LEFT JOIN employees c ON c.lot_id = p.id
GROUP BY p.id, p.name
ORDER BY employees_count DESC, p.name;

-- name: GetEmployeeByEmail :one
SELECT id, first_name, last_name, gender, date_of_birth, email, mobile,
       company_id, lot_id, is_active, created_at, updated_at
FROM employees
WHERE email = $1;

-- name: GetEmployeeByEmailForAuth :one
SELECT id, email, password, is_active
FROM employees
WHERE email = $1;

-- name: UpdateEmployeePassword :exec
UPDATE employees
SET password = $2,
    updated_at = NOW()
WHERE id = $1;
