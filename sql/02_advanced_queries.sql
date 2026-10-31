-- HR Analytics project: advanced queries (SQLite)
-- Topics: HAVING, CTE (WITH), window functions (RANK, AVG OVER, ROW_NUMBER)

-- 1. HAVING: filter groups, not rows
-- WHERE filters **rows before** grouping. HAVING filters **groups after** grouping. Here we keep only job roles that have at least 30 employees, because a rate calculated on 5 people is not reliable.
SELECT
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM employee
GROUP BY JobRole
HAVING COUNT(*) >= 30
ORDER BY attrition_rate_pct DESC;

-- 2. WHERE and HAVING together
-- First WHERE keeps only employees who work overtime (row filter). Then we group by department, and HAVING keeps only departments where at least 10 of these employees left (group filter).
SELECT
    Department,
    COUNT(*) AS overtime_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM employee
WHERE OverTime = 'Yes'
GROUP BY Department
HAVING SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) >= 10
ORDER BY employees_left DESC;

-- 3. CTE: compare each job role with the company average
-- A **CTE** (Common Table Expression) starts with WITH. It is a temporary named result that exists only during this query. We build two: overall (one row with the company rate) and by_role (one row per job role). Then we join them and calculate the difference. CROSS JOIN attaches the single overall row to every role.
WITH overall AS (
    SELECT 100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS overall_rate
    FROM employee
),
by_role AS (
    SELECT
        JobRole,
        COUNT(*) AS employees,
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS role_rate
    FROM employee
    GROUP BY JobRole
    HAVING COUNT(*) >= 30
)
SELECT
    r.JobRole,
    r.employees,
    ROUND(r.role_rate, 1) AS role_rate_pct,
    ROUND(o.overall_rate, 1) AS company_rate_pct,
    ROUND(r.role_rate - o.overall_rate, 1) AS difference_pct_points
FROM by_role r
CROSS JOIN overall o
ORDER BY difference_pct_points DESC;

-- 4. Salary of people who left vs stayed, inside the same job role
-- This answers the question from my notes: is the salary gap only because of different jobs? CASE WHEN without ELSE gives NULL for the other group, and AVG ignores NULL, so each AVG only uses its own group.
SELECT
    JobRole,
    COUNT(*) AS employees,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN Salary END)) AS avg_salary_left,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN Salary END)) AS avg_salary_stayed,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN Salary END)
        - AVG(CASE WHEN Attrition = 'Yes' THEN Salary END)) AS gap
FROM employee
GROUP BY JobRole
HAVING COUNT(*) >= 30
ORDER BY gap DESC;

-- 5. Window function: RANK inside each department
-- A **window function** calculates over a group of rows **without merging them** (unlike GROUP BY). PARTITION BY Department starts a new ranking for each department. ORDER BY avg_salary DESC ranks the highest salary as 1. The CTE first calculates the average salary per job role.
WITH role_salary AS (
    SELECT Department, JobRole, COUNT(*) AS employees, ROUND(AVG(Salary)) AS avg_salary
    FROM employee
    GROUP BY Department, JobRole
)
SELECT
    Department,
    JobRole,
    employees,
    avg_salary,
    RANK() OVER (PARTITION BY Department ORDER BY avg_salary DESC) AS salary_rank_in_department
FROM role_salary
ORDER BY Department, salary_rank_in_department;

-- 6. Window function: each employee vs the average of their job role
-- AVG(Salary) OVER (PARTITION BY JobRole) puts the average salary of the job role next to every employee, **keeping all rows**. Then we subtract it. The result shows the 10 employees paid the most above their role average.
SELECT
    EmployeeID,
    JobRole,
    Salary,
    ROUND(AVG(Salary) OVER (PARTITION BY JobRole)) AS role_avg_salary,
    ROUND(Salary - AVG(Salary) OVER (PARTITION BY JobRole)) AS difference_from_role_avg
FROM employee
ORDER BY difference_from_role_avg DESC
LIMIT 10;

-- 7. ROW_NUMBER: take only the latest review of each employee
-- Each employee can have several reviews. ROW_NUMBER() numbers the reviews of each employee from the newest (1) to the oldest. Keeping review_number = 1 gives one row per employee. Then we compare the average manager rating of employees who left and who stayed. Only employees with at least one review are included (because of the plain JOIN).
WITH ranked_reviews AS (
    SELECT
        EmployeeID,
        ManagerRating,
        ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY ReviewDate DESC) AS review_number
    FROM performance
)
SELECT
    e.Attrition,
    COUNT(*) AS employees,
    ROUND(AVG(r.ManagerRating), 2) AS avg_latest_manager_rating
FROM ranked_reviews r
JOIN employee e ON r.EmployeeID = e.EmployeeID
WHERE r.review_number = 1
GROUP BY e.Attrition;
