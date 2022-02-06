/*
COVID19 Data Exploration

Skills used: Joins, CTEs, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Viewing both tables
SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4


--Select data that will be used
SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM `CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Exploring Total Cases vs Total Deaths
--shows liklihood of passing away if you contract COVID in respective country
SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM DeathsCovid
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

--Exploring Total cases vs Population
SELECT location, `date`, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM DeathsCovid
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Exploring Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM DeathsCovid
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS DOUBLE)) AS TotalDeathCount
FROM DeathsCovid
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breakdown By continent

SELECT continent, MAX(CAST(total_deaths AS DOUBLE)) AS TotalDeathCount
FROM DeathsCovid
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS DOUBLE)) AS total_deaths, SUM(CAST(new_deaths AS DOUBLE))/SUM(New_Cases)*100 AS DeathPercentage
FROM DeathsCovid
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccination 

SELECT `DeathsCovid`.`date`, DeathsCovid.continent, DeathsCovid.location, DeathsCovid.population, CovidVaccinations.new_vaccinations
FROM `DeathsCovid`
RIGHT JOIN `CovidVaccinations`
	ON DeathsCovid.location = CovidVaccinations.location
	AND `DeathsCovid`.`date` = `CovidVaccinations`.`date`
WHERE DeathsCovid.continent IS NOT NULL
ORDER BY 3,1;

-- Total People Vaccinated By Country
SELECT `DeathsCovid`.`date`, DeathsCovid.continent, DeathsCovid.location, DeathsCovid.population, CovidVaccinations.new_vaccinations, SUM(CovidVaccinations.new_vaccinations) OVER (PARTITION BY DeathsCovid.location ORDER BY DeathsCovid.location, `DeathsCovid`.`date`) AS RollingPeopleVaccinated
FROM `DeathsCovid`
RIGHT JOIN `CovidVaccinations`
	ON DeathsCovid.location = CovidVaccinations.location
	AND `DeathsCovid`.`date` = `CovidVaccinations`.`date`
WHERE DeathsCovid.continent IS NOT NULL
ORDER BY 3,1;


-- Using CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac (Continent, Location, DATE, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT `DeathsCovid`.`date`, DeathsCovid.continent, DeathsCovid.location, DeathsCovid.population, CovidVaccinations.new_vaccinations, SUM(CovidVaccinations.new_vaccinations) OVER (PARTITION BY DeathsCovid.location ORDER BY DeathsCovid.location, `DeathsCovid`.`date`) AS RollingPeopleVaccinated
FROM `DeathsCovid`
RIGHT JOIN `CovidVaccinations`
	ON DeathsCovid.location = CovidVaccinations.location
	AND `DeathsCovid`.`date` = `CovidVaccinations`.`date`
WHERE DeathsCovid.continent IS NOT NULL
ORDER BY 3,1
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Create View

CREATE VIEW PercentPopulationVaccinated AS
WITH PopvsVac (Continent, Location, DATE, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT `DeathsCovid`.`date`, DeathsCovid.continent, DeathsCovid.location, DeathsCovid.population, CovidVaccinations.new_vaccinations, SUM(CovidVaccinations.new_vaccinations) OVER (PARTITION BY DeathsCovid.location ORDER BY DeathsCovid.location, `DeathsCovid`.`date`) AS RollingPeopleVaccinated
FROM `DeathsCovid`
RIGHT JOIN `CovidVaccinations`
	ON DeathsCovid.location = CovidVaccinations.location
	AND `DeathsCovid`.`date` = `CovidVaccinations`.`date`
WHERE DeathsCovid.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac;

--Create view for visualization later

SELECT *
FROM PercentPopulatioinVaccinated;

