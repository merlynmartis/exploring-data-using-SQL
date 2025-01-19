select * from Portfolio..CovidDeaths
order by 2,3

select Location, date, total_cases, new_cases, total_deaths,population
from Portfolio..CovidDeaths
order by 1,2


--looking at total cases and total deaths
--shows what % of population died due to covid
select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
--where Location = 'India'
order by 1,2

--looking at total cases vs population
--shows what % of population got covid
select  Location, date, total_cases, total_deaths, (total_cases/population)*100 as effectedPercentage
from Portfolio..CovidDeaths
--where Location= 'India'
order by 1,2

--looking at countries with higest infection rate compared to population
select  Location,population, Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as effectedPercentage
from Portfolio..CovidDeaths
--where Location= 'India'
group by Location,population
order by effectedPercentage desc


--showing countries with highest death count
select  Location, Max(cast(total_deaths as int)) as totalDeathCount
from Portfolio..CovidDeaths
where continent is not NULL
group by Location
order by totalDeathCount desc


--Lets break things down by continent

--showing the continents with highest death count
select  continent, Max(cast(total_deaths as int)) as totalDeathCount
from Portfolio..CovidDeaths
where continent is not NULL
group by continent
order by totalDeathCount desc



--Global Numbers
--shows which day there were highest new cases
select date, sum(new_cases) as totalNewCases-- ,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
--where Location = 'India' 
where continent is not NULL
group by date
order by 2 desc


--shows which day there were highest new deaths
select date, sum(cast(new_deaths as int)) as totalNewDeaths-- ,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
--where Location = 'India' 
where continent is not NULL
group by date
order by 2 desc


--shows which day there was highest new death percentage
select date, sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as newDeathPercentage
from Portfolio..CovidDeaths
--where Location = 'India' 
where continent is not NULL
group by date
order by 1 desc

--total
select sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as newDeathPercentage
from Portfolio..CovidDeaths
--where Location = 'India' 
where continent is not NULL
--group by date
order by 1 desc



--total population vs vaccinations
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
from portfolio..CovidDeaths cd
join portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 5 desc





--USE CTE
with popVSvac (continent, location, date, population,new_vaccinations, runningTotalVaccinated)
as
(
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as runningTotalVaccinated
from portfolio..CovidDeaths cd
join portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
select *,(runningTotalVaccinated/population)*100 as vaccinatedPercentage from popVSvac





--temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
runningTotalVaccinated numeric
)

insert into #percentPopulationVaccinated
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as runningTotalVaccinated
from portfolio..CovidDeaths cd
join portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null

select *,(runningTotalVaccinated/population)*100 as vaccinatedPercentage from #percentPopulationVaccinated


--creating view to store data for late visualizations
create view PercentPopulationVaccinated1 as
select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as runningTotalVaccinated
from portfolio..CovidDeaths cd
join portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null


select * from PercentPopulationVaccinated1