SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4;

--select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of dieing by Covid
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Saudi Arabia'
AND continent IS NOT NULL
ORDER BY date DESC;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases , (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
--AND continent IS NOT NULL
ORDER BY date DESC;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighstInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
--AND continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;


--Showing Countries with Highest Death Count oer Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Lets Break Things by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases) *100 AS DeathPercentage--(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
--AND continent IS NOT NULL
WHERE continent IS NOT NULL AND new_cases <> 0 AND new_deaths <> 0
GROUP BY date
ORDER BY 1,2;


SELECT SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases) *100 AS DeathPercentage--(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Saudi Arabia'
--AND continent IS NOT NULL
WHERE continent IS NOT NULL AND new_cases <> 0 AND new_deaths <> 0
--GROUP BY date
ORDER BY 1,2;



-- CovidVaccination Table

SELECT *
FROM PortfolioProject..CovidVaccinations;


-- Looking at Total Population vs Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS vac_for_each_location
--, (vac_for_each_location/population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- USE CTE

WITH popVSvacc (continent, location, date, population, new_vaccinations, vac_for_each_location)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS vac_for_each_location
--, (vac_for_each_location/population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (vac_for_each_location/population)*100
FROM popvsvacc


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vac_for_each_location numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS vac_for_each_location
--, (vac_for_each_location/population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (vac_for_each_location/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS vac_for_each_location
--, (vac_for_each_location/population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated