-- HR Analytics project: basic queries (SQLite)
-- Tables: employee, performance, education_level, rating_level, satisfied_level

-- 1. Look at the first rows
-- Shows 5 employees. LIMIT 5 means: stop after 5 rows.
SELECT EmployeeID, FirstName, LastName, Department, JobRole, Salary
FROM employee
LIMIT 5;

-- 2. Overall attrition rate
-- COUNT(*) counts all rows. CASE WHEN works like an IF: it gives 1 for employees who left and 0 for the others, and SUM adds them up.
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM employee;

-- 3. Attrition rate by department
-- GROUP BY splits the rows into groups (one per department) and runs the calculation on each group. ORDER BY ... DESC sorts from the highest to the lowest.
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM employee
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 4. Does overtime change the attrition rate?
-- Same idea as query 3, but we group by OverTime (Yes / No).
SELECT
    OverTime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM employee
GROUP BY OverTime;

-- 5. Average salary: employees who left vs stayed
-- AVG calculates the average. ROUND removes the decimals.
SELECT
    Attrition,
    COUNT(*) AS employees,
    ROUND(AVG(Salary)) AS avg_salary
FROM employee
GROUP BY Attrition;

-- 6. Employees by education level (JOIN)
-- The employee table only has a number (1 to 5) in Education. JOIN connects it to the education_level table to get the real name. ON says which two columns match.
SELECT
    el.EducationLevel AS education,
    COUNT(*) AS employees
FROM employee e
JOIN education_level el ON e.Education = el.EducationLevelID
GROUP BY el.EducationLevelID, el.EducationLevel
ORDER BY el.EducationLevelID;

-- 7. Employees with no performance review (LEFT JOIN)
-- LEFT JOIN keeps every employee, even without a matching review. For those employees the review columns are NULL (empty), so WHERE p.EmployeeID IS NULL finds them.
SELECT COUNT(*) AS employees_without_reviews
FROM employee e
LEFT JOIN performance p ON e.EmployeeID = p.EmployeeID
WHERE p.EmployeeID IS NULL;

-- 8. Self rating vs manager rating by department
-- Joins employees with their reviews, then compares the average self rating with the average manager rating in each department.
SELECT
    e.Department,
    COUNT(*) AS reviews,
    ROUND(AVG(p.SelfRating), 2) AS avg_self_rating,
    ROUND(AVG(p.ManagerRating), 2) AS avg_manager_rating
FROM employee e
JOIN performance p ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department
ORDER BY e.Department;
