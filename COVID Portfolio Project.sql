--Select*
--FROM PortfolioProject..CovidDeaths
--Where continent is not null

--Select*
--FROM PortfolioProject..CovidVaccinations

--Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contracdt COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Order By 1,2


--Looking at the Total Cases vs Population 
--Shows what percentage of population got COVID
Select location, date, population, total_cases, (total_cases/population)*100 PopulationInfectionPercentage
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Order By 1,2


--Looking at countries with highest infection rate compares to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 PopulationInfectionPercentage
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Group By population, location
Order By PopulationInfectionPercentage DESC

--Showing the countries with the highest death count per population
Select location, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is not null
Group By location
Order By TotalDeathCount DESC


--Looking at death count by continents
--THIS IS THE CORRECT QUERY FOR THIS INFORMATION
Select location, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is null
Group By location
Order By TotalDeathCount DESC



-- WE ARE MOVING FORWARD WITH THIS QUERY FOR THE SAKE OF THE PROJECT
Select continent, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount DESC


--Global Numbers
Select SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is not null
Order By 1,2


--Looking at Total Population vs Vacciantions
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccincated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE

With PopsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccincated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/population)*100
FROM PopsVac


--TEMP Table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
FROM PercentPopulationVaccinated