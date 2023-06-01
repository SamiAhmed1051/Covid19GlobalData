SELECT * 
FROM Covid19Global.dbo.CovidDeaths 
--WHERE continent IS NOT Null
ORDER BY 3,4

SELECT *
FROM Covid19Global.dbo.CovidVaccinations   
ORDER BY 3,4

-- Select columns to work on 

SELECT location, date, total_cases, new_cases,total_deaths, population 
FROM Covid19Global.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases VS total deaths
-- Shows percentage of likelihood of dying if you contracted Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases) * 100 AS DeathPercentage
FROM Covid19Global.dbo.CovidDeaths
WHERE location like '%STATES%'
ORDER BY 1,2

-- Looking at Total Cases VS Populaion
-- Shows  what percentage of popluation got covid
SELECT location, date, population, total_cases, (total_cases / population ) * 100 AS CasePercentage
FROM Covid19Global.dbo.CovidDeaths
WHERE location like '%STATES%'
ORDER BY 1,2


-- Looking at Countries with highest infection rate compared to population (Needs Corrections)
SELECT continent,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS
PercentPopulationInfected
FROM Covid19Global.dbo.CovidDeaths
WHERE location IS NOT NULL
GROUP BY continent, population 
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest Death count per population
SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM Covid19Global.dbo.CovidDeaths
WHERE continent IS NOT Null -- To take out the continent data and others
GROUP BY location
ORDER BY HighestDeathCount DESC


-- Breaking it down by continent

SELECT continent , MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM Covid19Global.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY HighestDeathCount DESC


-- Global Numbers 

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) as Total_Deaths, SUM(CAST
	(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date  -- Turnning off this line gives the Total sum
ORDER BY 1,2


-- Looking at Total population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE - to do the total Population Vs Vaccination

With PopVSVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / Population ) * 100
FROM PopVSVac


--Puting it on a temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
--
SELECT *, (RollingPeopleVaccinated / Population ) * 100
FROM #PercentPopulationVaccinated


-- View to store data for later visualization
CREATE VIEW vwPercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM vwPercentPopulationVaccinated 
