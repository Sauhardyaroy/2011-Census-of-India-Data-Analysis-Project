select * from project.dbo.data1;

select * from project.dbo.data2;

--number of rows into our dataset

select count(*) from project..data1
select count(*) from project..data2

--dataset for tripura and rajasthan

select * from project..data1 where state in ('Tripura', 'Rajasthan')

--population of india

select sum(Population) as population from project..data2

--average growth

select avg(growth)*100 avg_growth from project..data1;

--average growth statewise

select state, avg(growth)*100 as avg_growth from project..data1 group by state;

--avg sex ratio statewise

select state, round(avg(sex_ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

--avg literacy rate

select state, round(avg(literacy),0) as avg_literacy_rate from project..data1 group by state order by avg_literacy_rate desc;

--avg literacy rate greater than 90

select state, round(avg(literacy),0) as avg_literacy_rate from project..data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_rate desc;

--top 3 states showing highest growth ratio

select top 3 state, avg(growth)*100 as avg_growth from project..data1 group by state order by avg_growth desc;

--bottom 3 states showing lowest sex ratio

select top 3 state, round(avg(sex_ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio asc;

--top 3 states in literacy

drop table if exists #topstates
create table #topstates
(state nvarchar(255),
topstate float

)

insert into #topstates
select state, round(avg(literacy),0) as avg_literacy_rate from project..data1 group by state order by avg_literacy_rate desc;

select top 3 * from #topstates order by #topstates.topstate desc;

--bottom 3 states in literacy

drop table if exists #bottomstates
create table #bottomstates
(state nvarchar(255),
bottomstate float

)

insert into #bottomstates
select state, round(avg(literacy),0) as avg_literacy_rate from project..data1 group by state order by avg_literacy_rate desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union operator

select * from(
select top 3 * from #topstates order by #topstates.topstate desc) a
 
union

select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;

--states starting with letter a or b

select distinct state from project..data1 where  lower(state) like 'a%' or lower(state) like 'b%';

--states starting with letter t and ends with letter a

select distinct state from project..data1 where  lower(state) like 't%' and lower(state) like '%a';

-- joining both the table

 select project..data1.district, project..data1.state, project..data1.sex_ratio, project..data2.population 
 from project..data1 inner join project..data2 on project..data1.district = project..data2.district;

 --number of males and females

 select a.district, a.state, round(a.population/(a.sex_ratio+1),0) as males, round((a.population*a.sex_ratio)/(a.sex_ratio+1),0) as females from
 (select project..data1.district, project..data1.state, project..data1.sex_ratio/1000 as sex_ratio , project..data2.population 
 from project..data1 inner join project..data2 on project..data1.district = project..data2.district) a

 --total number of males and females statewise

 select b.state, sum(b.males ) as total_males , sum(b.females) as total_females from 
 (select a.district, a.state, round(a.population/(a.sex_ratio+1),0) as males, round((a.population*a.sex_ratio)/(a.sex_ratio+1),0) as females from
 (select project..data1.district, project..data1.state, project..data1.sex_ratio/1000 as sex_ratio , project..data2.population 
 from project..data1 inner join project..data2 on project..data1.district = project..data2.district) a) b
 group by b.state;

--total_literacy_rate

select d.state, sum(d.literate_people) as total_literate_pop , sum(d.illiterate_people) as total_illiterate_pop from
(select c.district, c.state, round((c.literacy_ratio*c.population),0) as literate_people, round(((1-c.literacy_ratio)*c.population),0) as illiterate_people from
(select project..data1.district, project..data1.state, project..data1.literacy/100 as literacy_ratio, project..data2.population 
from project..data1 inner join project..data2 on project..data1.district = project..data2.district) c) d
group by d.state;

--population in previous census

select sum(t.previous_census_population) as previous_census_population, sum(t.current_census_population) as current_census_population from
(select m.state, sum(m.previous_census_population) as previous_census_population, sum(m.current_census_population) as current_census_population from
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population , d.population as current_census_population from
(select project..data1.district, project..data1.state, project..data1.growth, project..data2.population 
from project..data1 inner join project..data2 on project..data1.district = project..data2.district) d) m
group by m.state) t;

--population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from

(select q.*, r.total_area from

(select '1' as keyy, n.* from
(select sum(t.previous_census_population) as previous_census_population, sum(t.current_census_population) as current_census_population from
(select m.state, sum(m.previous_census_population) as previous_census_population, sum(m.current_census_population) as current_census_population from
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population , d.population as current_census_population from
(select project..data1.district, project..data1.state, project..data1.growth, project..data2.population 
from project..data1 inner join project..data2 on project..data1.district = project..data2.district) d) m
group by m.state) t) n) q inner join (

select '1' as keyy, z.* from
(select sum(area_km2) as total_area from project..data2)z) r on q.keyy = r.keyy)g;

--window
--output top 3 districts from each state with highest literacy rate

select a.* from
(select state, district,literacy,rank() over(partition by state order by literacy desc) as rnk from project..data1) a
where a.rnk in (1,2,3) order by state;