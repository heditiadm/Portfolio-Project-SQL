select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from PortofolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what precentage of population got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as PrecentagePopulationInfected
from PortofolioProject..CovidDeaths
order by 1,2


-- Looking at COuntries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentagePopulationInfected
from PortofolioProject..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date

select *,(RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated