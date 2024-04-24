create database DSjobs;
select * from salaries;
-- Q1. Your assignment is to pinpoint countries which give work fully remote for the title "managers" paying salaries exceeding $90000 USD.
select distinct company_location from
(
select company_location, job_title, salary_in_usd, remote_ratio from salaries where job_title like '%manager%' and salary_in_usd > '90000' and remote_ratio=100
)t;

-- Q2. you are tasked with identifying top5 countires for freshers(entry level) having greatest count of large(company size) number of companies.

select company_location, count(company_size) as size from salaries where experience_level = 'EN' and company_size='L' group by company_location order by size desc limit 5 ;

-- Q3. Your objective is to calculate percentage of employees who works fully remote and as a salary exceeding $100,000 usd. shedding light on high paying remote positions in today's job market.

set @WFH= (select count(*) from salaries where remote_ratio='100' and salary_in_usd > 100000);
set @total  = (select count(*) from salaries where salary_in_usd > 100000);
Set @Percentag =round((((select @WFH) / (select @total))*100),2);
select @Percentag;

-- Q4. your task is to identify locations where entry level average salary exceeds average salary for that job title in the market for entry level, helping to find lucrative opportunities.
select avg(salary_in_usd) from salaries where experience_level = "EN";

select EN.job_title, round(Ent_lvl_avg_sal_per_job_title,1),company_location,round(Ent_lvl_avg_sal_per_Comp,1) from
(
select job_title, avg(salary_in_usd) as Ent_lvl_avg_sal_per_job_title from salaries where experience_level = "EN" group by job_title
)EN
inner join
(
select company_location, job_title, avg(salary_in_usd) as Ent_lvl_avg_sal_per_Comp from salaries where experience_level = "EN" group by job_title, company_location
)JT
on EN.job_title =JT.job_title where Ent_lvl_avg_sal_per_Comp > Ent_lvl_avg_sal_per_job_title;

-- Q5. Identify for each job title which country offers maximum avg salary. this data will help target those countries for the specific job roles.

Select * from
(
select *, dense_rank() over (partition by job_title order by avg desc) as ranking from
(
select company_location,  job_title, avg(salary_in_usd) avg from salaries group by job_title, company_location
)t
)m where ranking = 1 ;

-- Q6. Find out salary trend across different company location, pinpoint locations where salary has consistently increased in the last few years( countries
--      where data is available of past 3 years(present and past two years) providing insights into location experiencing sustained salary growth.

select * from salaries;

with CTE as
(
select * from salaries where company_location in
(
Select company_location from
(
select company_location, avg(salary_in_usd) AS 'Average_Sal', count(distinct(work_year)) as "count" from salaries where work_year >= (year(current_date())-2) group by company_location having count = 3
)t
)
)

select company_location, 
max(case when work_year = 2022 then Average end) as average_sal_2022,
max(case when work_year = 2023 then Average end) as average_sal_2023,
max(case when work_year = 2024 then Average end) as average_sal_2024
from
(
select company_location, work_year, avg(salary_in_usd) as Average from cte group by company_location, work_year
)t group by company_location having average_sal_2024 > average_sal_2023 and average_sal_2023 > average_sal_2022;

-- Q7. 

