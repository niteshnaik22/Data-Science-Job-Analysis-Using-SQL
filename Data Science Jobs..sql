
/*1.You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, for the title
 'managers’ Paying salaries Exceeding $90,000 USD*/
SELECT distINct(company_locatiON) FROM salaries WHERE job_title like '%Manager%' and salary_IN_usd > 90000 and remote_ratio= 100;




/*2.AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH 
Identifying top 5 Country Having  greatest count of large(company size) number of companies.*/
SELECT company_locatiON, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_locatiON 
ORDER BY cnt DESC
LIMIT 5;




/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/
set @COUNT= (SELECT COUNT(*) FROM salaries  WHERE salary_IN_usd >100000 and remote_ratio=100);
set @total = (SELECT COUNT(*) FROM salaries where salary_in_usd>100000);
set @percentage= round((((SELECT @COUNT)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people workINg remotly and havINg salary >100,000 USD';





/*4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/
SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average
    




/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/

SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1



select year(current_date())-2



/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/

WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022 -- step 3 and havINg step 4.

         --------------------------------------
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries   group by company_location , work_year-- step 1
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries  where work_year>=year(current_date())-2  group by company_location , work_year  -- step 2
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3       -- STEP 3


 
 /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level
 
 
 
/* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1



SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL -- STEP 3


