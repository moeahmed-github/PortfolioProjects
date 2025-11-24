Select *
From [Portfolio Project 1]..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project 1]..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project 1]..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking  at Total Cases  vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project 1]..CovidDeaths$
Where location like '%Malaysia%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- The Percentage of Population Got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project 1]..CovidDeaths$
--Where location like '%Malaysia%'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Populations

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project 1]..CovidDeaths$
--Where location like '%Malaysia%'
Group by location, population
order by PercentPopulationInfected desc


-- The Countries with Highest Death Count per Populations

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..CovidDeaths$
--Where location like '%Malaysia%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT
-- The Continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..CovidDeaths$
--Where location like '%Malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From [Portfolio Project 1]..CovidDeaths$
-- Where location like '%Malaysia%'
Where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)  
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--Creating View To Store Data For Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



-- Fixing view visibility issue in Object Explorer


IF OBJECT_ID('dbo.PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW dbo.PercentPopulationVaccinated;
GO

CREATE VIEW dbo.PercentPopulationVaccinated AS
-- your SELECT query here
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project 1]..CovidDeaths$ dea
JOIN [Portfolio Project 1]..CovidVaccinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO



-- Verify that the view returns data as expected
SELECT * FROM dbo.PercentPopulationVaccinated;


-- Check if the view exists in the system catalog and confirm its metadata
SELECT * FROM sys.views WHERE name = 'PercentPopulationVaccinated';

