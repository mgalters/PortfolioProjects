-- Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows Liklihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at the total cases vs population

Select Location, date, total_cases, population, (total_cases/population*100) as CasePercentage
from PortfolioProject..CovidDeaths
-- Where Location = 'United States'
order by 1,2

--Looking at countries with higheste infection rate compared to population
Select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population*100)) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- Where Location = 'United States'
group by location, population
order by PercentPopulationInfected desc

--Looking at countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
-- Where Location = 'United States'
group by location
order by TotalDeathCount desc

-- continent
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
-- Where Location = 'United States'
group by location
order by TotalDeathCount desc

-- Showing continents with highest death count per population
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
Where continent is not null
--group by date
order by 1, 2 


-- Looking at Total Population vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations/2) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
left Join PortfolioProject1..CovidVaccinations1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3   
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
order by 2, 3


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations/2) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
left Join PortfolioProject1..CovidVaccinations1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


Delete View PercentPopulationVaccinated

-- creating view to store data for later visualizations
Use PortfolioProject1

Create View PercentPopulationVaccinated as 
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations/2) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
left Join PortfolioProject1..CovidVaccinations1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3


Select * from PercentPopulationVaccinated