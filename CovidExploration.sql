-- Reviewing the table
select * from CovidDeaths;

select * from CovidVaccinations;

--retriving the perticular columns 
select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1, 2;

--checking the total cases and death ratio
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths 
order by 1,2;

--checking the ratio for india
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths 
where location like 'India'
order by 1,2;

--covid case as per  population
select location, date, population, total_cases, ROUND((total_cases/population),2) as PopulationPercentageGotCovid
from CovidDeaths where location like 'India' order by 2;

--countries with highest infection rate
select location,continent, population, max(total_cases) as MaximumCases, max(round((total_cases/population)*100,2)) PopulationPercentageGotCovid
from CovidDeaths 
group by location,continent, population
order by 5 desc;

--countries with highest Death rate
select location, population, max(cast(total_deaths as int)) as MaximumDeaths, max(round((total_deaths/population)*100,2)) as 'PopulationDeath%'
from CovidDeaths 
where continent is not null
group by location, population
order by 3 desc;

--continent wise deathPercentage
select continent, sum(population) as Population, max(cast(total_deaths as int)) as MaximumDeaths, max(round((total_deaths/population)*100,2)) as 'PopulationDeath%'
from CovidDeaths 
where continent is not null
group by continent
order by 3 desc;

-- total daily cases in the world
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as DeathCases,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null and new_cases is not null
group by date 
order by 1,2;

--Total Cases in the world and total Deaths with death percentage
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as DeathCases,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null and new_cases is not null
order by 1,2;

--joining both the tables
select * 
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date;

--Total population vs total vaccination per day
select cv.location, cv.date, cd.population, cv.new_vaccinations
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null
 order by 2,3;


--Total population vs total vaccination per day 
select cv.location, cv.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cv.location order by cv.location, cv.date) as TotalVaccinations
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null
 order by 1,2;

--Total population vs total vaccination per day for india
select cv.location, cv.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cv.location order by cv.location, cv.date) as TotalVaccinations
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cv.location ='India' 
 order by 1,2;


-- USE CTE
with PopVsVac (location,date,population,new_vaccinations,TotalVaccination) as (
select cv.location, cv.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cv.location order by cv.location, cv.date) as TotalVaccinations
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null)

select *, round((TotalVaccination/population)*100,2) as VaccinatedPercentage 
from PopVsVac 
where location in ('India', 'United States') and TotalVaccination is not null
order by 1,2


--creating view for later use
create view PerPopulationVaccIndia as
select cv.location, cv.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cv.location order by cv.location, cv.date) as TotalVaccinations
from CovidDeaths cd
 join CovidVaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cv.location ='India' 

 select * from PerPopulationVaccIndia;
 