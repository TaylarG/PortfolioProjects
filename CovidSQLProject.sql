SELECT *
From [Portfolio project]..CovidDeaths$
where continent is not null
order by 3,4


--SELECT *
--From [Portfolio project]..CovidVaccinations$
--order by 3,4

Select continent, date, total_cases, new_cases, Total_deaths, population
From [Portfolio project]..CovidDeaths$
where continent is not null
order by 1,2


--Looking at the Total Cases VS Total Deaths
--Shows the likelihood of dying if you contract Covid in the US.

Select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$ 
where location like '%states%'
and continent is not null
order by 1,2



--Looking at Total Cases VS Population
--Shows what percentage of the population got Covid.

Select continent, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From [Portfolio project]..CovidDeaths$ 
--where location like '%states%'
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate Compared to Population

Select continent, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From [Portfolio project]..CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by continent, population
order by PercentOfPopulationInfected desc

--Showing Countries with the Highest Death Count per Population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



--Broken Down by Continent

--Continents with Highest Death Counts

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$ 
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Data Visualization for Continent Death Counts

create view TotalDeathCount as
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths$ 
--where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount desc

select *
from TotalDeathCount




--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--where continent like '%states%'
where continent is not null
group by date
order by 1,2


--Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed,
--(RollingPeopleVaxxed/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopVSVaxx (continent, location, date, population, New_vaccinations, RollingPeopleVaxxed)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--(RollingPeopleVaxxed/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaxxed/population)*100
from PopVSVaxx




--Temp Table

drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaxxed numeric
)
insert into #PercentPopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--(RollingPeopleVaxxed/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaxxed/population)*100
from #PercentPopVaccinated



--Views for Data Visualizations

Create view PercentPopVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--(RollingPeopleVaxxed/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopVaccinated