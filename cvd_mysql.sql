-- selecting database to use ---
use project;

-- creating the table --------
create table cvd (General_Health varchar(255),
Checkup varchar(255),
Exercise varchar(255),	
Heart_Disease varchar(255),	
Skin_Cancer varchar(255),	
Other_Cancer varchar(255),	
Depression varchar(255),	
Diabetes varchar(255),	
Arthritis varchar(255),	
Sex varchar(255),	
Age_Category varchar(255),	
Height_cm int,	
Weight_kg int,	
BMI	int, 
Smoking_History	varchar(255), 
Alcohol_Consumption	int,
Fruit_Consumption int,	
Green_Vegetables_Consumption int,	
FriedPotato_Consumption int );

drop table cvd;

-- viewing the datatypes -----
describe cvd;

-- importing dataset into the table -----
load data infile 'C:/Users/admin/OneDrive/data_analysis/CVD_cleaned_mysql.csv'
into table cvd
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows; -- 308854 records imported 

-- view the table ---
select * from cvd;


-- lets fill the table with distinct values as duplicate values were checked in excel sheets ---
create temporary table temp
select distinct * from cvd; -- 308760 distinct values in the temp 

truncate cvd; -- to delete all the values to fill it with distinct values from the temp table

insert into cvd
select * from temp; -- 308760 values distinct values inserted

drop table temp; 

-------------------------------------------------------------------------------------------------------------
-- lets begin with analysis phase  

-- to find the percentage of general health the people have --
with cte(general_health,sex, con, total) as 
(select general_health, sex, count(*) as con, (select count(general_health) from cvd) as total from cvd
group by 1,2)
select general_health, sex, con, (con / total) * 100  as percentage from cte
group by 1,2
order by 4 desc;

-- to find the percentage of general health who exercise 
with cte(general_health,sex, ex, con, total) as 
(select general_health, sex, exercise as ex, count(*) as con, (select count(general_health) from cvd) as total from cvd
group by 1,2,3)
select general_health,sex, ex, con, total, (con / total) * 100  as percentage from cte
order by 2;

-------------------------------------------------------------------------------------------------------------

-- to find the relationship between exercise done by people and heart disease --
with cte(heal, sex,ex, hd, con, total) as 
(select general_health as heal, sex, exercise as ex, heart_disease as hd, 
 count(*) as con, (select count(general_health) from cvd) as total from cvd
 where heart_disease = 'yes' and exercise = 'no'
group by 1,2,3)
select heal ,sex, ex,hd,con, (con/total)*100 as percentage from cte 
order by 2,6 ; -- this is to find people who have heart disease but dont exercise 


with ct(heal,sex, ex, hd, con, total) as 
(select general_health as heal,sex, exercise as ex, heart_disease as hd, 
 count(*) as con, (select count(general_health) from cvd) as total from cvd
 where heart_disease = 'no' and exercise = 'yes'
group by 1,2,3)
select heal ,sex, ex,hd,con, (con/total)*100 as percentage from ct 
order by 2,6 ; -- this is to find people who exercise and have no heart disease 


with ct(heal,sex, ex, hd, con, total) as 
(select general_health as heal,sex, exercise as ex, heart_disease as hd, 
 count(*) as con, (select count(general_health) from cvd) as total from cvd
 where heart_disease = 'no' and exercise = 'no'
group by 1,2,3)
select heal,sex, ex,hd,con, (con/total)*100 from ct
order by 2,6; -- this is to find people who exercise and have no heart disease 

---------------------------------------------------------------------------------------------------------------


-- to find people who have all the types of disease and if they do exercise or not ---
select general_health, sex, exercise, heart_disease, skin_cancer, other_cancer, depression, diabetes, arthritis ,count(*) from cvd
where heart_disease = 'yes' and skin_cancer = 'yes' and other_cancer = 'yes' and depression = 'yes' and 
diabetes = 'yes' and arthritis = 'yes' and exercise = 'yes'
group by 1, 2,3
order by 2,10;


select general_health, sex, exercise, heart_disease, skin_cancer, other_cancer, depression, diabetes, arthritis ,count(*) from cvd
where heart_disease = 'yes' and skin_cancer = 'yes' and other_cancer = 'yes' and depression = 'yes' and 
diabetes = 'yes' and arthritis = 'yes' and exercise = 'no'
group by 1, 2
order by 2,10; -- this is to find people with all disease who dont do exercise



with cte (general_health,age_category,exercise,con,total) as 
(select general_health, age_category, exercise, count(*) as con, (select count(general_health) from cvd) as total from cvd 
where heart_disease = 'yes' and skin_cancer = 'yes' and other_cancer = 'yes' and depression = 'yes' and 
diabetes = 'yes' and arthritis = 'yes'
group by 1, 2, 3
order by 2,3)
select sum((con)/total)*100 as percentage from cte; -- this is to find percentage of people who have all disease

--------------------------------------------------------------------------------------------------------------
-- smoking history with general health of people and heart disease 

with cte (general_health, smoking_history, heart_disease, con, total) as
(select general_health, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where smoking_history = 'yes' and heart_disease = 'no'
group by 1,2,3)
select general_health, smoking_history, heart_disease, con, (con/total)*100 as percentage from cte
order by 2,4,3;

with cte (general_health, smoking_history, heart_disease, con, total) as
(select general_health, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where smoking_history = 'no' and heart_disease = 'yes'
group by 1,2,3)
select general_health, smoking_history, heart_disease, con, (con/total)*100 as percentage from cte
order by 2,4,3;

with cte (general_health, smoking_history, heart_disease, con, total) as
(select general_health, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where smoking_history = 'no' and heart_disease = 'no'
group by 1,2,3)
select general_health, smoking_history, heart_disease, con, (con/total)*100 as percentage from cte
order by 2,4,3;

with cte (general_health, smoking_history, heart_disease, con, total) as
(select general_health, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where smoking_history = 'yes' and heart_disease = 'yes'
group by 1,2,3)
select general_health, smoking_history, heart_disease, con, (con/total)*100 as percentage from cte
order by 2,4,3;

-------------------------------------------------------------------------------------------------------------

-- to find the general health of people and checkup relationship -------

with cte(general_health, checkup, sex,con,total) as 
(select general_health, checkup, sex, count(*) as con,(select count(general_health) from cvd) as total  from cvd
group by 1,2,3)
select *, (con/total)*100 as percentage from cte;


with ct(general_health, checkup, sex,con,total,percentage) as
(with cte(general_health, checkup, sex,con,total) as 
(select general_health, checkup, sex, count(*) as con,(select count(general_health) from cvd) as total  from cvd
group by 1,2,3)
select *, (con/total)*100 as percentage from cte
where sex = 'female')
select sum(percentage) from ct;-- 51.86 percent female

with ct(general_health, checkup, sex,con,total,percentage) as
(with cte(general_health, checkup, sex,con,total) as 
(select general_health, checkup, sex, count(*) as con,(select count(general_health) from cvd) as total  from cvd
group by 1,2,3)
select *, (con/total)*100 as percentage from cte
where sex = 'male')
select sum(percentage) from ct; -- 48.13 percent male

------------------------------------------------------------------------------------------------------------
use project;

-- lets find the relation between smoking and cancer 
with cte(skin_cancer, other_cancer, smoking_history, heart_disease,con,total) as 
(select skin_cancer, other_cancer, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
group by 1,2,3,4)
select *, (con/total)*100 as percentage from cte;


with ct(sex,skin_cancer, other_cancer, smoking_history, heart_disease,con,total,percentage) as 
( with cte(sex,skin_cancer, other_cancer, smoking_history, heart_disease,con,total) as 
(select sex, skin_cancer, other_cancer, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where sex = 'female'
group by 1,2,3,4,5)
select *, (con/total)*100 as percentage from cte )
select sum(percentage) from ct; -- 51.8668 percent women 


with cte(sex,skin_cancer, other_cancer, smoking_history, heart_disease,con,total) as 
(select sex, skin_cancer, other_cancer, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where sex = 'female' and smoking_history = 'yes' and skin_cancer = 'yes' and other_cancer = 'yes' and heart_disease = 'yes'
group by 1,2,3,4,5)
select *, (con/total)*100 as percentage from cte; -- over 272 people or 0.0881 percent women who have all the disease from smoking


with cte(sex,skin_cancer, other_cancer, smoking_history, heart_disease,con,total) as 
(select sex, skin_cancer, other_cancer, smoking_history, heart_disease, count(*) as con, (select count(general_health) from cvd) as total from cvd
where sex = 'male' and smoking_history = 'yes' and skin_cancer = 'yes' and other_cancer = 'yes' and heart_disease = 'yes'
group by 1,2,3,4,5)
select *, (con/total)*100 as percentage from cte;-- over 543 people or 0.1759 percent male who have all the disease from smoking

-------------------------------------------------------------------------------------------------------------------------------

-- finding the relation diabetis, bmi, weight, height and sex 
select avg(height_cm), avg(weight_kg) from cvd; -- so the average height is 170 cm and avg weight is 83 kgs 

with ct(diabetes, weight_kg, bmi, age_category,sex,con,total,summ)as
(
with cte (diabetes, weight_kg, bmi, age_category,sex,con,total) as 
(
select diabetes, weight_kg, bmi, age_category,sex,  count(*) as con, (select count(general_health) from cvd)as total from cvd
where diabetes = 'yes' and bmi >= 40 and weight_kg >= 150 
group by 1,2,3,4,5-- 1234 rows 
)
select*, (select sum(con) from cte) as summ from cte
)
select (summ/total)*100 as percentage from ct
limit 1; -- 0.2895 percentage of people have diabetes and high bmi count with heavy weight


with ct(diabetes, weight_kg, bmi, age_category,sex,con,total,summ)as
(
with cte (diabetes, weight_kg, bmi, age_category,sex,con,total) as 
(
select diabetes, weight_kg, bmi, age_category,sex,  count(*) as con, (select count(general_health) from cvd)as total from cvd
where diabetes = 'no' and bmi >= 40 and weight_kg >= 150 
group by 1,2,3,4,5-- 1234 rows 
)
select*, (select sum(con) from cte) as summ from cte
)
select (summ/total)*100 as percentage from ct
limit 1; -- 0.5888 percentage of people have no diabetes and high bmi count with heavy weight

-------------------------------------------------------------------------------------------------------------------------------

-- depression on sex and age category
with ct(depression, age_category, sex,con,pop,total) as
(with cte(depression, age_category, sex,con,pop) as 
(select depression, age_category, sex,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where depression = 'yes'
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total/pop * 100 as percentage from ct
limit 1;-- 20.0476 percent people have depression 

with ct(depression, age_category, sex,con,pop,total) as
(with cte(depression, age_category, sex,con,pop) as 
(select depression, age_category, sex,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where depression = 'no'
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total/pop * 100 as percentage from ct
limit 1;-- 79.9524 percent people dont have depression

with ct(depression, age_category, sex,con,pop,total) as
(with cte(depression, age_category, sex,con,pop) as 
(select depression, age_category, sex,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where depression = 'yes' and sex = 'female' 
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total/pop * 100 as percentage from ct
limit 1; -- 13.2281 percent female have depression 

with ct(depression, age_category, sex,con,pop,total) as
(with cte(depression, age_category, sex,con,pop) as 
(select depression, age_category, sex,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where depression = 'yes' and sex = 'male' 
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total/pop * 100 as percentage from ct
limit 1; -- 6.8195 percent male have depression 

--------------------------------------------------------------------------------------------------------------------------------

-- arthritis with height, weight, sex and age catgeory relationship -----------

with ct(arthritis, sex, weight_kg, height_cm, age_category,con,pop,total) as
(with cte(arthritis, sex, weight_kg, height_cm, age_category,con,pop) as 
(select arthritis, sex, weight_kg, height_cm, age_category,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where arthritis = 'yes'
group by 2,3,4,5)
select *, (select sum(con) from cte) as total from cte)
select total/pop *100 as percentage from ct
limit 1; -- 32.7312 percent people have arthritis 


with ct(arthritis, sex, weight_kg, height_cm, age_category,con,pop,total) as
(with cte(arthritis, sex, weight_kg, height_cm, age_category,con,pop) as 
(select arthritis, sex, weight_kg, height_cm, age_category,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where arthritis = 'no'
group by 2,3,4,5)
select *, (select sum(con) from cte) as total from cte)
select total/pop *100 as percentage from ct
limit 1; -- 67.2688 percent people dont have arthritis 


with ct(arthritis, sex, weight_kg, height_cm, age_category,con,pop,total) as
(with cte(arthritis, sex, weight_kg, height_cm, age_category,con,pop) as 
(select arthritis, sex, weight_kg, height_cm, age_category,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where arthritis = 'yes' and sex = 'female'
group by 2,3,4,5)
select *, (select sum(con) from cte) as total from cte)
select total/pop *100 as percentage from ct
limit 1; -- 19.3225 percent female have arthritis 

with ct(arthritis, sex, weight_kg, height_cm, age_category,con,pop,total) as
(with cte(arthritis, sex, weight_kg, height_cm, age_category,con,pop) as 
(select arthritis, sex, weight_kg, height_cm, age_category,count(*) as con, (select count(general_health) from cvd) as pop from cvd
where arthritis = 'yes' and sex = 'male'
group by 2,3,4,5)
select *, (select sum(con) from cte) as total from cte)
select total/pop *100 as percentage from ct
limit 1; -- 13.4088 percent male have arthritis 

--------------------------------------------------------------------------------------------------------------------------------

-- fried potato consumption by sex ----
select avg(friedpotato_consumption) from cvd; -- around 6 is the avg potato consumption


with ct (sex, weight_kg, age_category,con,pop, total) as
(with cte(sex, weight_kg, age_category,con,pop) as
(select sex, weight_kg, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where friedpotato_consumption >= 15
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total/pop * 100 as percentage from ct
limit 1;

with ct (sex, weight_kg, age_category,con,pop, total) as
(with cte(sex, weight_kg, age_category,con,pop) as
(select sex, weight_kg, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where friedpotato_consumption >= 15 and sex = 'female'
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 3.8742 percent or 11962 female consume fried potato 

with ct (sex, weight_kg, age_category,con,pop, total) as
(with cte(sex, weight_kg, age_category,con,pop) as
(select sex, weight_kg, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where friedpotato_consumption >= 15 and sex = 'male'
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 6.5225 percent or 20139 male consume fried potato 

------------------------------------------------------------------------------------------------------------------------------

-- percentage of all disease ---



with heart (heart_disease, sex, age_category,con,pop, total) as
(with cte(heart_disease, sex, age_category,con,pop) as
(select heart_disease, sex, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where heart_disease = 'yes'
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from heart
limit 1; -- 8.0872 percent or 24970 people have heart disease 

with ct (skin_cancer, sex, age_category,con,pop, total) as
(with cte(skin_cancer, sex, age_category,con,pop) as
(select skin_cancer, sex, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where skin_cancer = 'yes'
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 9.7130 percent or 29990 people have skin cancer 

with ct (other_cancer, sex, age_category,con,pop, total) as
(with cte(other_cancer, sex, age_category,con,pop) as
(select other_cancer, sex, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where other_cancer = 'yes'
group by 1,2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 9.6758 percent or 29875 people have other cancer 

with ct (diabetes, sex, age_category,con,pop, total) as
(with cte(diabetes, sex, age_category,con,pop) as
(select diabetes, sex, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where diabetes = 'yes'
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 13.0101 percent or 40170 people have diabetes

with ct(arthritis, sex, age_category,con,pop, total) as
(with cte(arthritis, sex, age_category,con,pop) as
(select arthritis, sex, age_category, count(*) as con, (select count(general_health) from cvd) as pop from cvd
where arthritis = 'yes'
group by 2,3)
select *, (select sum(con) from cte) as total from cte)
select total, total/pop * 100 as percentage from ct
limit 1; -- 32.7312 percent or 101061 people have arthritis


with ct(heart,skin,other_cancer,diabetes,arthritis,total,total_no) as 
(with cte(heart,skin,other_cancer,diabetes,arthritis,total) as 
(select
count(case when heart_disease = 'yes' then 1 end) as heart,
count(case when skin_cancer = 'yes' then 1 end) as skin,
count(case when other_cancer = 'yes' then 1 end) as other_cancer,
count(case when diabetes = 'yes' then 1 end) as diabetes,
count(case when arthritis = 'yes' then 1 end) as arthritis, (select count(general_health) from cvd) as population
from cvd)
select * , (heart + skin + other_cancer + diabetes + arthritis) as total_no from cte)
select *, total_no/total * 100 as percentage from ct; -- 73.2174 percent or 226066 people have atleast one disease 

-------------------------------------------------------------------------------------------------------------------------------

-- alcohol consumption based on sex and heart disease ---------
select avg(alcohol_consumption) from cvd; -- 5.0978 is the avg consumption of alcohol 

with ct(sex, age_category, heart_disease,alcohol_consumption,con,population,total) as 
(with cte(sex, age_category, heart_disease,alcohol_consumption,con,population) as 
(select sex, age_category, heart_disease,alcohol_consumption, count(*) as con, (select count(general_health) from cvd) as population from cvd
where heart_disease = 'yes' and alcohol_consumption >= 10
group by 1,2,4)
select *, (select sum(con) from cte)as total from cte)
select total, total/population * 100 as percentage from ct
limit 1; -- 1.2126 percent or 3744 people have high alcohol consumption with heart disease 

with ct(sex, age_category, heart_disease,alcohol_consumption,con,population,total) as 
(with cte(sex, age_category, heart_disease,alcohol_consumption,con,population) as 
(select sex, age_category, heart_disease,alcohol_consumption, count(*) as con, (select count(general_health) from cvd) as population from cvd
where heart_disease = 'yes' and alcohol_consumption >= 10 and sex = 'female'
group by 1,2,4)
select *, (select sum(con) from cte)as total from cte)
select total, total/population * 100 as percentage from ct
limit 1; -- 0.2798 percent or 864 female have high alcohol consumption with heart disease 

with ct(sex, age_category, heart_disease,alcohol_consumption,con,population,total) as 
(with cte(sex, age_category, heart_disease,alcohol_consumption,con,population) as 
(select sex, age_category, heart_disease,alcohol_consumption, count(*) as con, (select count(general_health) from cvd) as population from cvd
where heart_disease = 'yes' and alcohol_consumption >= 10 and sex = 'male'
group by 1,2,4)
select *, (select sum(con) from cte)as total from cte)
select total, total/population * 100 as percentage from ct
limit 1; -- 0.9328 percent or 2880 male have high alcohol consumption with heart disease 

-------------------------------------------------------------------------------------------------------------------------------

-- finding fruit consumption on sex and the general health ---------
select avg(fruit_consumption) from cvd; -- 29.8338 is the avg consumption


with c(poor,percentage1,good,percentage2,very_good,percentage3,fair,percentage4,excellent,percentage5) as 
(with ct(sex, age_category, fruit_consumption,poor,good,very_good,fair,excellent,population) as 
(with cte(general_health, sex, age_category, fruit_consumption,population,poor,good,vgood,fair,excell) as
(select general_health, sex, age_category, fruit_consumption, (select count(general_health) from cvd) as population,
count(case when general_health = 'poor' then 1 end) as poor,
count(case when general_health = 'good' then 1 end) as good,
count(case when general_health = 'Very Good' then 1 end) as vgood,
count(case when general_health = 'fair' then 1 end) as fair,
count(case when general_health = 'Excellent' then 1 end) as excell
from cvd
where fruit_consumption >= 30 
group by 1,2,3,4)
select sex, age_category, fruit_consumption, sum(poor) as poor , sum(good) good , sum(vgood) very_good, sum(fair) fair, sum(excell) excellent, population from cte
group by 1,2,3)
select poor, (poor/population) * 100 percentage1, good, (good/population) * 100 percentage2, very_good,(very_good/population) * 100 percentage3, 
fair, (fair/population) * 100 percentage4, excellent, (excellent/population) * 100 percentage5 from ct)
select sum(poor) poor_count , sum(percentage1) percent, sum(good) good_count, sum(percentage2) percent, sum(very_good) vgood_count, sum(percentage3) percent, sum(fair) fair_count, 
sum(percentage4) percent, sum(excellent) excellent_count, sum(percentage5) percent from c; -- this is to find each health category values and percentage 


with ct(general_health, sex, age_category, fruit_consumption,con,population, total) as
(with cte(general_health, sex, age_category, fruit_consumption,con,population) as 
(select general_health, sex, age_category, fruit_consumption, count(*) as con, (select count(general_health) from cvd) as population from cvd
where fruit_consumption >= 30 
group by 1,2,3,4)
select *, (select sum(con) from cte) total from cte)
select  total, total/population * 100 percentage from ct limit 1; -- 52.2710 percent or 161392 people consume above avg fruit 


--------------------------------------------------------------------------------------------------------------------------------

-- finding relation between green vege, sex and general_health ----------------------

select avg(green_vegetables_consumption) from cvd; -- 15.1090 vege is avg consuming value by people 

with c(poor,percentage1,good,percentage2,very_good,percentage3,fair,percentage4,excellent,percentage5) as 
(with ct(sex, age_category, green_vegetables_consumption,poor,good,very_good,fair,excellent,population) as 
(with cte(general_health, sex, age_category, green_vegetables_consumption,population,poor,good,vgood,fair,excell) as
(select general_health, sex, age_category, green_vegetables_consumption, (select count(general_health) from cvd) as population,
count(case when general_health = 'poor' then 1 end) as poor,
count(case when general_health = 'good' then 1 end) as good,
count(case when general_health = 'Very Good' then 1 end) as vgood,
count(case when general_health = 'fair' then 1 end) as fair,
count(case when general_health = 'Excellent' then 1 end) as excell
from cvd
where green_vegetables_consumption >= 30 
group by 1,2,3,4)
select sex, age_category, green_vegetables_consumption, sum(poor) as poor , sum(good) good , sum(vgood) very_good, sum(fair) fair, sum(excell) excellent, population from cte
group by 1,2,3)
select poor, (poor/population) * 100 percentage1, good, (good/population) * 100 percentage2, very_good,(very_good/population) * 100 percentage3, 
fair, (fair/population) * 100 percentage4, excellent, (excellent/population) * 100 percentage5 from ct)
select sum(poor) poor_count , sum(percentage1) percent, sum(good) good_count, sum(percentage2) percent, sum(very_good) vgood_count, sum(percentage3) percent, sum(fair) fair_count, 
sum(percentage4) percent, sum(excellent) excellent_count, sum(percentage5) percent from c; -- this is to find each health category values and percentage 

with ct(general_health, sex, age_category, green_vegetables_consumption,con,population, total) as
(with cte(general_health, sex, age_category, green_vegetables_consumption,con,population) as 
(select general_health, sex, age_category, green_vegetables_consumption, count(*) as con, (select count(general_health) from cvd) as population from cvd
where green_vegetables_consumption >= 30 
group by 1,2,3,4)
select *, (select sum(con) from cte) total from cte)
select  total, total/population * 100 percentage from ct limit 1; -- 20.7737 percent or 64141 people have above avg green vegetable intake


---------------------------------------------------------XXXXXXXXXXX----------------------------------------------------------

