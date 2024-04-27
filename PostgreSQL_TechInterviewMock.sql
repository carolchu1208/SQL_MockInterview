SELECT * FROM books;

-- 1. third last records from books
-- OFFSET: SKIP ROW
SELECT *, 
ROW_NUMBER()
OVER(ORDER BY book_id DESC) as RN
FROM books
OFFSET 2 LIMIT 1;

-- OTHER CASE: GET ALL rn = 3 in each category
SELECT * FROM(
	SELECT *, 
	ROW_NUMBER()
	OVER(PARTITION BY genre ORDER BY book_id DESC) as RN
	FROM books) as subtable
WHERE rn =3;

--2. SECOND HIGHEST PRICE IN EACH GENRE
WITH pricetable as (
	SELECT * FROM(
	SELECT *, 
	ROW_NUMBER()
	OVER(PARTITION BY genre ORDER BY price DESC) as RN
	FROM books))
SELECT * 
FROM pricetable
WHERE RN = 2;

--OTHER CASE: RETURN ALL SAME SECOND HIGHEST PRICE
WITH pricetable as (
	SELECT * FROM(
	SELECT *, 
	RANK()
	OVER(PARTITION BY genre ORDER BY price DESC) as RN
	FROM books))
SELECT * 
FROM pricetable
WHERE RN = 2;

--3. book priced above the average price in their own genre category
WITH avg_price AS(
	SELECT *, 
	AVG(PRICE)
	OVER(PARTITION BY genre) AS avg_p
	FROM books)
SELECT *
FROM avg_price
WHERE price > avg_p

--OTHER CASE: Correlated Subquery
SELECT * FROM books AS b1
WHERE PRICE > (
	SELECT AVG(price) as avg_p
	FROM books AS b2
	WHERE b1.genre = b2.genre);

--4. Highes or lowest priced book in each genre
SELECT *
FROM books AS b1
WHERE price IN (
	SELECT MIN(price)
	FROM books AS b2
	WHERE b1.genre = b2.genre)
UNION
SELECT *
FROM books AS b1
WHERE price IN (
	SELECT MAX(price)
	FROM books AS b2
	WHERE b1.genre = b2.genre)

--OTHER WAY: WINDOW FUNCTION
WITH either_price AS(
	SELECT *,
		FIRST_VALUE(price)OVER(PARTITION BY genre ORDER BY price DESC) as max_price,
		FIRST_VALUE(price)OVER(PARTITION BY genre ORDER BY price ASC
							  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as min_price
	FROM books)
SELECT * FROM either_price
WHERE price = max_price OR price = min_price;

--5. delete duplocate records from table (unique here is determined on the team_name and stadium)
DROP TABLE team_table
select * from premier_league_teams;

SELECT distinct(team_name)
FROM premier_league_teams;

SELECT MAX(id), COUNT(*)
FROM premier_league_teams
GROUP BY team_name, stadium
HAVING COUNT(*) > 1

CREATE TABLE team_table AS TABLE premier_league_teams;

DELETE FROM team_table
WHERE ID IN (
	SELECT MAX(id)
	FROM team_table
	GROUP BY team_name, stadium
	HAVING COUNT(*) > 1)

SELECT * FROM team_table --success!


--DELETE THE DUPLICATE HAVING LESS ID NUMBER
DELETE FROM team_table
WHERE ID IN (
	SELECT MIN(id)
	FROM team_table
	GROUP BY team_name, stadium
	HAVING COUNT(*) > 1)

SELECT * FROM team_table --success!
-- 6.
CREATE TABLE window_teams AS TABLE premier_league_teams;


SELECT id
FROM (
	SELECT *,
	ROW_NUMBER ()
	OVER(PARTITION BY team_name, stadium) AS od
	FROM window_teams) as rn
	WHERE od > 1;


--8. return output
select * from product_feedback

select
CASE 
WHEN comment IS NULL THEN review
ELSE comment
END AS result
FROM product_feedback 

-- OTHER WAY coalesce
SELECT COALESCE(comment, review) AS result
FROM product_feedback;
--9. return output
WITH CombinedData AS (
    SELECT id, authors AS output, 'author' AS source
    FROM authors
    UNION ALL
    SELECT id, books1 AS output, 'books1' AS source
    FROM books1
)

SELECT 
    id,
    CASE 
        WHEN COUNT(DISTINCT source) = 2 THEN output
        WHEN COUNT(DISTINCT source) = 1 AND MAX(source) = 'author' THEN 'only match in authors'
        WHEN COUNT(DISTINCT source) = 1 AND MAX(source) = 'books1' THEN 'only match in books'
        ELSE 'no match'
    END AS output
FROM CombinedData
GROUP BY id;

-- 10. The salary table contains salary information of all employees in various departments of XYZ company. 
-- A partial view of both EE_information and EE_Salary tables is given above. 
-- Write a SQL statement to calculate average salary per department.

SELECT department, avg(yearly_salary)
FROM EE_salary as sal
RIGHT JOIN EE_information as info
ON sal.emp_id = info.emp_id
GROUP BY department

--11. Write a SQL statement to find employees whose names start with 'J'.
SELECT name
FROM EE_salary
WHERE name like 'J%'

--12. Write a SQL statement to find the number of employees who work in the Finance department.
SELECT count(*) FROM EE_information
WHERE department ='Finance'

--13. Write a SQL statement to find the highest salaried employee in each department.
SELECT department, MAX(yearly_salary)
FROM EE_salary as sal
INNER JOIN EE_information as info
ON sal.emp_id = info.emp_id
GROUP BY department

--OTHER: WINDOW FUNCTION
with salary_max as (
	SELECT name, department, yearly_salary,
	RANK() OVER(PARTITION BY department ORDER BY yearly_salary DESC) as rnk
	FROM EE_information as ee
	INNER JOIN EE_salary as ss
	ON ee.emp_id = ss.emp_id)
SELECT * FROM salary_max
WHERE rnk =1

--14. Write a SQL statement to list employee names their tenure in the company.
SELECT AGE(CURRENT_DATE, '2005-10-21')

SELECT *, AGE(COALESCE(termination_date, CURRENT_DATE), hire_date) as tenure
FROM EE_information;


--15. Write a SQL statement to find employees who have been in the company 5+ years.
SELECT *, AGE(COALESCE(termination_date, CURRENT_DATE), hire_date) as tenure
FROM EE_information
WHERE tenure > '5 years'



--16. Write a SQL statement to list employees with the highest tenure in each department
SELECT * FROM EE_information;
SELECT * FROM EE_salary;

SELECT i.emp_id, i.department,FIRST_VALUE(yearly_salary)OVER(
	PARTITION BY i.emp_id 
	ORDER BY yearly_salary) AS salary_rank
FROM EE_information AS i
RIGHT JOIN EE_salary AS s
USING(emp_id);

--Extra Practice: Write a SQL statement to list employees with the highest tenure in each department (with name listing)
SELECT i.emp_id, name, department,FIRST_VALUE(yearly_salary)OVER(
	PARTITION BY i.emp_id 
	ORDER BY yearly_salary) AS salary_rank
FROM EE_information AS i
RIGHT JOIN EE_salary AS s
USING(emp_id);








