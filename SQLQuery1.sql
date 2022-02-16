SELECT * 
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM PortfolioProject.dbo.CovidVaccination
WHERE continent is not null
ORDER BY 3,4

SELECT Location,date , total_cases, new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeath
ORDER BY 1,2


--Looking at Total cases Vs Total Deaths
--death percentage rate
SELECT Location,date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
WHERE location like '%states%' and  continent is not null
ORDER BY 1,2

--looking at Total Cases vs Population
--percentage of population got covid

SELECT Location,date , total_cases, population,(total_cases/population)*100 AS Case_Percentage
FROM PortfolioProject.dbo.CovidDeath
WHERE location like '%states%' and  continent is not null
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population 
SELECT Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeath
GROUP BY location,population

HAVING location like '%india%'
ORDER BY PercentPopulationInfected DESC


--Showing Countries with highest Death count per population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 AS PercentPopulationDeath
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not null
GROUP BY location

ORDER BY TotalDeathCount DESC


-- Lets Break things down by continent
--
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 AS PercentPopulationDeath
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount DESC

-- Global Number

SELECT   SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
WHERE  continent is not null
--GROUP BY date
ORDER BY 1,2

--creating view for global view
Create View GlobalNumber as
SELECT   SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
WHERE  continent is not null
--GROUP BY date
--ORDER BY 1,2


-- looking at total population 

SELECT * 
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccination as vac
 ON dea.location = vac.location
 and dea.date =vac.date


 --looking total population vs Vaccinations

 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations AS bigint))  OVER (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccination as vac
 ON dea.location = vac.location
 and dea.date =vac.date
Where dea.continent is NOT NULL
Order by 2,3

-- USE CTE

with PopvsVac (contitnent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT (bigint, vac.new_vaccinations))  OVER (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccination as vac
 ON dea.location = vac.location
 and dea.date =vac.date
Where dea.continent is NOT NULL
--Order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100 as vaccinationPercentage
FROM PopvsVac

-- TEMP TABLE
DROP table if exists #PercentagePopulaitonVaccinated
create Table #PercentagePopulaitonVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentagePopulaitonVaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT (bigint, vac.new_vaccinations))  OVER (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccination as vac
 ON dea.location = vac.location
 and dea.date =vac.date
Where dea.continent is NOT NULL
--Order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as vaccinationPercentage
FROM #PercentagePopulaitonVaccinated


-- creating view to store data for later visualizations

Create View PercentagePopulaitonVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT (bigint, vac.new_vaccinations))  OVER (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccination as vac
 ON dea.location = vac.location
 and dea.date =vac.date
Where dea.continent is NOT NULL
--Order by 2,3

select *
from PercentagePopulaitonVaccinated 