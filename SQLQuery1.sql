SELECT *
FROM CovidProject..['Covid-Death']
where continent is not null
order by 3 ,4

--SELECT *
--FROM CovidProject..['Covid-Vaccination']
--order by 3 ,4


-- select data that we are going to be using

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM CovidProject..['Covid-Death']
order by 1, 2

-- looking at Total cases VS total deaths
--shows the likelihood of dying if you contract covid in your country 

SELECT location , date , total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..['Covid-Death']
where location = 'egypt'
order by 1, 2

-- looking at Total cases VS the population
-- shows what percentage of population got covid 

SELECT location , date ,population ,total_cases   , (total_cases/population)*100 as infectionPercentage
FROM CovidProject..['Covid-Death']
where location = 'egypt'
order by 1, 2

--looking at countries that have highest infection rate to the population

SELECT location  ,population ,MAX(total_cases) as HighestInfectionRate , MAX((total_cases/population)*100) as HighestInfectionRatePercentage
FROM CovidProject..['Covid-Death']
--where location = 'egypt'
group by location  ,population
order by HighestInfectionRatePercentage desc

--showing the highest countries in death count per population

SELECT location  ,MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidProject..['Covid-Death']
--where location = 'egypt'
where continent is not null
group by location  
order by TotalDeathCount desc

-------------------------------------------------------------LET'S BREAK THINGS DOWN BY CONTINENT-------------------------------------------------------------------



--showing contintents with the highest death count per population

SELECT continent  ,MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidProject..['Covid-Death']
--where location = 'egypt'
where continent is not null
group by continent  
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT   SUM (new_cases) as total_newcases , SUM(cast (new_deaths as int )) as total_newdeaths , SUM(cast (new_deaths as int )) / sum (new_cases)*100 as NewDeathPercentage
FROM CovidProject..['Covid-Death']
--where location = 'egypt'
where continent is not null 
--group by date
order by 1, 2
-----------------------------------------------------------import vacination data set-----------------------------------------------------------------------------------------------------

--looking at total population bs vaccinations

select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(convert ( int, vac.new_vaccinations  )) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from CovidProject..['Covid-Death'] dea
join CovidProject..['Covid-Vaccination'] vac
   on dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- use CTE
 
with PopvsVac (continent , location ,date , population ,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(convert ( int, vac.new_vaccinations  )) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from CovidProject..['Covid-Death'] dea
join CovidProject..['Covid-Vaccination'] vac
   on dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (rollingpeoplevaccinated/population)*100 as rollingpercentage
from PopvsVac


-- TEMP TABLE
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location  nvarchar(255) ,
date datetime ,
population numeric ,
new_vaccinations numeric ,
rollingpeoplevaccinated numeric 
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(convert ( int, vac.new_vaccinations )) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from CovidProject..['Covid-Death'] dea
join CovidProject..['Covid-Vaccination'] vac
   on dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * , (rollingpeoplevaccinated/population)*100 as rollingpercentage
from #percentpopulationvaccinated

-- creating view to store data for later  visualization

create view PopvsVac as

select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(convert ( int, vac.new_vaccinations  )) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from CovidProject..['Covid-Death'] dea
join CovidProject..['Covid-Vaccination'] vac
   on dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3






