-- Data cleaning

 -- 1. Remove Duplicates
 -- 2. Standardize the data
 -- 3. Null/Blank Values
 -- 4. Remove unnecessary columns

select *
from mall_customer;

create table mall_customer_staging
like mall_customer;

insert mall_customer_staging
select *
from mall_customer;

select *
from mall_customer_staging;

alter table mall_customer_staging
change column `annual income (k$)` annual_income_thousand int;

alter table mall_customer_staging
change column `spending score (1-100)` spending_score int;

alter table mall_customer_staging
change column `Age group` age_group text;

alter table mall_customer_staging
change column `estimated savings (k$)` estimated_savings_thousand double;

alter table mall_customer_staging
change column `Credit Score` credit_score int;

alter table mall_customer_staging
change column `loyalty years` loyalty_years int;

alter table mall_customer_staging
change column `preferred category` preferred_category text;

with duplicates_cte as 
(
select *, row_number() over (partition by customerid, gender,age,annual_income_thousand,
spending_score,age_group,estimated_savings_thousand,credit_score,loyalty_years,preferred_category) as row_num
from mall_customer_staging
)
select *
from duplicates_cte
where row_num>1; #No duplicated records

-- Standardizing the data

select *
from mall_customer_staging;

select distinct gender 
from mall_customer_staging;

select distinct preferred_category
from mall_customer_staging;

-- dealing with null values
select *
from mall_customer_staging
where (gender is null or gender ='') or
(age is null or age ='') or
(annual_income_thousand is null or annual_income_thousand ='') or
(spending_score is null or spending_score ='') or
(age_group is null or age_group ='') or
(estimated_savings_thousand is null or estimated_savings_thousand ='') or
(credit_score is null or credit_score ='') or
(loyalty_years is null or loyalty_years ='') or
(preferred_category is null or preferred_category ='') ;

select distinct age_group
from mall_customer_staging;

Create table mall_customer_staging2
like mall_customer_staging;

insert mall_customer_staging2
select *
from mall_customer_staging;

update mall_customer_staging
set age_group = null 
where age_group ='';

update mall_customer_staging2
set age_group = CASE
	when age between 18 and 25 then '18-25'
	when age between 26 and 35 then '26-35'
	when age between 36 and 50 then '36-50'
	when age between 51 and 65 then '51-65'
	when age > 65 then '65+'
    End
where age_group='';

select *
from mall_customer_staging2;

rename table mall_customer_staging2 to mall_customer_cleaned;

-- EDA
select count(*)
from mall_customer_cleaned;

select *
from mall_customer_cleaned;
select 
sum(case when gender is null then 1 else 0 end) as missing_gender,
sum(case when age is null then 1 else 0 end) as missing_age,
sum(case when annual_income_thousand is null then 1 else 0 end) as missing_annual_income,
sum(case when spending_score is null then 1 else 0 end) as missing_spending_score,
sum(case when age_group is null then 1 else 0 end) as missing_age_group,
sum(case when estimated_savings_thousand is null then 1 else 0 end) as missing_estimated_savings_thousand,
sum(case when credit_score is null then 1 else 0 end) as missing_credit_score,
sum(case when loyalty_years is null then 1 else 0 end) as missing_loyalty_years,
sum(case when preferred_category is null then 1 else 0 end) as missing_preferred_category
from mall_customer_cleaned;

select min(age), max(age), avg(age),min(annual_income_thousand),max(annual_income_thousand),avg(annual_income_thousand),
min(spending_score), max(spending_score), avg(spending_score),min(estimated_savings_thousand),
max(estimated_savings_thousand),avg(estimated_savings_thousand),min(credit_score),max(credit_score),avg(credit_score),min(loyalty_years),
max(loyalty_years),avg(loyalty_years)
from mall_customer_cleaned;

SELECT gender, COUNT(*) as total, 100.0*COUNT(*)/SUM(COUNT(*)) OVER() AS percentage
FROM mall_customer_cleaned
GROUP BY gender;

select age_group, count(*) as `count`
from mall_customer_cleaned
group by age_group
order by age_group;


select age_group, count(*) as `count`
from mall_customer_cleaned
group by age_group
order by `count` desc
limit 1;

select gender, avg(age)
from mall_customer_cleaned
group by gender;

select avg(annual_income_thousand)
from mall_customer_cleaned;

select age_group,avg(annual_income_thousand)
from mall_customer_cleaned
group by age_group
order by age_group;

select case
	when spending_score <40 then 'low_spending_group'
	when spending_score between 40 and 70 then 'medium_spending_group'
	when spending_score >70 then 'high_spending_group' 
end as spending_group,count(*) as customer_count
from mall_customer_cleaned
group by spending_group
order by customer_count;

select 
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end as income_group,avg(spending_score)
from mall_customer_cleaned
group by income_group;

Select avg(estimated_savings_thousand)
from mall_customer_cleaned;

select 
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end as income_group,avg(estimated_savings_thousand)
from mall_customer_cleaned
group by income_group;

select case
	when credit_score <450 then 'low_credit_score'
	when credit_score between 450 and 750 then 'medium_credit_score'
	when credit_score >750 then 'high_credit_score' 
end as credit_score_group,count(*) as customer_count
from mall_customer_cleaned
group by credit_score_group
order by customer_count;

select avg(credit_score), age_group
from mall_customer_cleaned
group by age_group
order by age_group;

select avg(credit_score), gender
from mall_customer_cleaned
group by gender;

select 
case
	when loyalty_years < 4 then 'new_customer'
	when loyalty_years between 4 and 7 then 'mid_term_customer'
	when loyalty_years > 7 then 'long_term_customer'
end as loyalty_group, 
count(*) as customer_count
from mall_customer_cleaned
group by loyalty_group;

select 
case
	when loyalty_years < 4 then 'new_customer'
	when loyalty_years between 4 and 7 then 'mid_term_customer'
	when loyalty_years > 7 then 'long_term_customer'
end as loyalty_group,
avg(spending_score) as avg_spending_score
from mall_customer_cleaned
group by loyalty_group
order by avg_spending_score;

select 
case
	when loyalty_years < 4 then 'new_customer'
	when loyalty_years between 4 and 7 then 'mid_term_customer'
	when loyalty_years > 7 then 'long_term_customer'
end as loyalty_group, 
avg(estimated_savings_thousand) as avg_estimated_savings
from mall_customer_cleaned
group by loyalty_group;

select 
case
	when loyalty_years < 4 then 'new_customer'
	when loyalty_years between 4 and 7 then 'mid_term_customer'
	when loyalty_years > 7 then 'long_term_customer'
end as loyalty_group, 
avg(credit_score) as avg_credit_score
from mall_customer_cleaned
group by loyalty_group;

select preferred_category, count(*) as customer_count
from mall_customer_cleaned
group by preferred_category;

with category_age as 
(
Select preferred_category,age_group, count(*) as customer_count,
row_number() over (partition by age_group order by count(*) desc) as ranking
from mall_customer_cleaned
group by preferred_category, age_group
)
select preferred_category, age_group, customer_count
from category_age
where ranking=1
order by age_group;

With category_income as
(
Select preferred_category,
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end as income_group, count(*) as customer_count,
row_number() over (partition by
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end order by count(*) desc) as ranking
from mall_customer_cleaned
group by preferred_category,income_group
)
select preferred_category,income_group,customer_count
from category_income
where ranking = 1;

select preferred_category, max(spending_score) as highest_spending_score
from mall_customer_cleaned
group by preferred_category
order by 2 desc;

select *
from
(
select *, 
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end as income_group,
case
	when spending_score <40 then 'low_spending_group'
	when spending_score between 40 and 70 then 'medium_spending_group'
	when spending_score >70 then 'high_spending_group' 
end as spending_group
from mall_customer_cleaned
) t
where income_group='high_income_group' and spending_group='high_spending_group';

select age_group, avg(spending_score) as avg_spending_score
from mall_customer_cleaned
group by age_group
order by avg_spending_score desc;


select gender, avg(spending_score) as avg_spending_score
from mall_customer_cleaned
group by gender
order by avg_spending_score;


select 
case
	when annual_income_thousand < 40 then 'low_income_group'
	when annual_income_thousand between 40 and 70 then 'medium_income_group'
	when annual_income_thousand > 70 then 'high_income_group'
end as income_group,
case
	when spending_score <40 then 'low_spending_group'
	when spending_score between 40 and 70 then 'medium_spending_group'
	when spending_score >70 then 'high_spending_group' 
end as spending_group, count(*) as customer_count
from mall_customer_cleaned
group by income_group, spending_group
order by customer_count desc;