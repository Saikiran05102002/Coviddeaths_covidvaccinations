
select *
from portfolio..covidDeaths$
where continent is not null
order by 3,4;

select 
* from portfolio..covidvaccinations$
order by 3,4;

select the data that we are going to use
select location,date,total_cases,new_cases,total_deaths,
population from portfolio..covidDeaths$
where continent is not null
order by 1,2;

--Looking at Total cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
 

--Looking at Total cases vs population
--- shows what percentage of population got covid
select location,date,population,total_cases,
 (total_cases/population)*100 as affectedPercentage
 from portfolio..covidDeaths$
 where continent is not null and location like '%states%'
order by 1,2;

-- Looking at countries with highest Infection rate compared to Population
 select location,population,max(total_cases) as HighestInfectionCount,
 max((total_cases/population))*100 as affectedPercentage
 from portfolio..covidDeaths$ 
 where continent is not null
 group by location,population
 where location like '%states%'
order by affectedPercentage desc;

---LET'S BREAK THINGS DOWN BY CONTINENT
select continent,population,max(cast(total_deaths as int)) as TotalDeathCount
 from portfolio..covidDeaths$
 where continent is not null
 group by continent-- where location like '%states%'
order by TotalDeathCount desc;

-- showing continents with highest Death Count Per population
select continent,population,max(cast(total_deaths as int)) as TotalDeathCount
 from portfolio..covidDeaths$
 where continent is not null
 group by continent-- where location like '%states%'
order by TotalDeathCount desc;

-- showing countries with highest Death Count Per population
select location,population,max(cast(total_deaths as int)) as TotalDeathCount
 from portfolio..covidDeaths$
 where continent is not null
 group by location-- where location like '%states%'
order by TotalDeathCount desc;

---GLOBAL NUMBERS
 select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100
 as DeathPercentage
 from portfolio..covidDeaths$ 
 where continent is not null
 ---whera location like '%states%'
---group by date
order by 1,2;
  
---Looking at Total Poplation vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as rollingpeoplevaccinated 
,(rollingpeoplevaccinated)*100
from portfolio..covidDeaths$ dea 
join portfolio..covidvaccinations$ vac 
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

---use CTE

with PopvsVac (continent,location,date,population,new_vaccinations ,rollingpeoplevaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated)*100
from portfolio..covidDeaths$ dea 
join portfolio..covidvaccinations$ vac 
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3)
select 
*,(rollingpeoplevaccinated/population)*100 as peoplevaccinated from PopvsVac;


--TEMP TABLE
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated)*100
from portfolio..covidDeaths$ dea 
join portfolio..covidvaccinations$ vac 
on dea.location=vac.location
and dea.date=vac.date
---where dea.continent is not null
---order by 2,3

select 
*,(rollingpeoplevaccinated/population)*100 as peoplevaccinated from #PercentPopulationVaccinated;


--- Creating View to store Data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date)
as rollingpeoplevaccinated 
,(rollingpeoplevaccinated)*100
from portfolio..covidDeaths$ dea 
join portfolio..covidvaccinations$ vac 
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *
from PercentPopulationVaccinated;

