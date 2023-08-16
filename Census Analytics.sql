create schema project;
use project;
select * from dataset1;

-- number of rows into our datasets

select count(*) from dataset1;
select count(*) from dataset2;

-- dataset for jharkhand and bihar

select * from dataset1 where state in ("Jharkhand" , "Bihar");

-- population of India

select * from dataset2;
select sum(Population) as Population from dataset2;

-- average growth

select state,round(avg(growth)*100,2) as avg_growth from dataset1 group by state order by avg_growth desc;

-- average sex ratio

select state,round(avg(Sex_Ratio),2) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;

-- average literacy rate

select state,round(avg(Literacy),0) as avg_literacy from dataset1 group by state order by avg_literacy desc;

-- top 3 states showing highest growth raise

select state,round(avg(growth)*100,2) as avg_growth from dataset1 group by state order by avg_growth desc limit 3;

-- bottom 3 states showing lowest sex ratio

select state,round(avg(Sex_Ratio),0) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio limit 3;

-- top and bottom 3 states in literacy state

  (select state,round(avg(literacy),0) as avg_literacy from dataset1 group by state order by avg_literacy desc limit 3)
  union
 (select state,round(avg(literacy),0) as avg_literacy from dataset1 group by state order by avg_literacy limit 3);
 
 -- states starting with letter a
 
 select distinct state from dataset1 where lower(state) like 'a%';
 
 -- start with letter A and end with letter m
 
 select distinct(state) from dataset1 where state like 'A%' and state like '%m';
 
 -- joining both table
 
 select dataset1.district, dataset1.state,dataset1.Sex_Ratio /1000 as sex_rat, dataset1.growth,dataset2.population from dataset1 inner join dataset2 on dataset1.district = dataset2.district;

-- no. of males and females
select d.state,sum(d.males) total_males, sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.sex_rat+1),0) males,round((c.population*c.sex_rat)/(c.sex_rat+1),0) females from
 (select dataset1.district, dataset1.state,dataset1.Sex_Ratio/1000 as sex_rat, dataset1.growth,dataset2.population from dataset1 inner join dataset2 on dataset1.district = dataset2.district) as c) as d
group by d.state;

-- total literacy rate

select c.state,sum(literate_people) total_literate_people,sum(illiterate_people) total_illiterate_people from
(select d.district,d.state,round(d.literacy_rate*d.population,0) literate_people,round((1-d.literacy_rate)* d.population,0) illiterate_people from
(select dataset1.district, dataset1.state,dataset1.Literacy/100 as literacy_rate, dataset1.growth,dataset2.population from dataset1 inner join dataset2 on dataset1.district = dataset2.district) as d ) as c
group by c.state;

-- population in previous census

select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from (
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0)as previous_census_population, d.population as current_census_population from
(select dataset1.district, dataset1.state,dataset1.growth as growth ,dataset2.population from dataset1 inner join dataset2 on dataset1.district = dataset2.district) d ) e
group by e.state)m;

-- population vs area

select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/g.current_census_population) as current_census_population_vs_area from
(select q.*,r.total_area from (
select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from (
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0)as previous_census_population, d.population as current_census_population from
(select dataset1.district, dataset1.state,dataset1.growth as growth ,dataset2.population from dataset1 inner join dataset2 on dataset1.district = dataset2.district) d ) e
group by e.state)m )n ) q inner join (

select '1' as keyy, z.* from (
select sum(area_km2) as total_area from dataset2) z) r on q.keyy = r.keyy)g 
