--The Data that we are looking at

SELECT *
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM Portfolio_Project_Covid..CovidVaccinations
ORDER BY 3,4

--------------------------------------------------------------------------------------------

--Select the Data we are working/using with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



----------------------------------------------------------------------------------------------


--Looking at Total_Cases vs Total_Deaths
--Shows likelihood of dying if infected w/ COVID19

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
AND continent IS NOT NULL
ORDER BY 1,2



------------------------------------------------------------------------------------------------


--Looking at Total_Cases vs Population
--Looking at percentage of people infected w/ COVID19


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
AND continent IS NOT NULL
ORDER BY 1,2

--Shows percentage of world population infected with COVID19


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------

--Countries w/ Highest Infection Rate compared to Population


SELECT location, population, MAX(total_cases) AS MaxInfectionCount,  Max((total_cases/population))*100 AS PopulationInfectedPercentage
FROM Portfolio_Project_Covid..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC


-----------------------------------------------------------------------------------------------------------------------------

--Showing Countries w/ Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing U.S.A Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing South Korea Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Highest Death Count per Population by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-----------------------------------------------------------------------------------------------------------------

--Global Numbers
--Showing Total_Cases, Total_Deaths, and DeathPercentage Globally

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


---------------------------------------------------------------------------------------------------------------------

--Total Vaccinations VS Total Population
--Shows Percentage Population that has received at least one vacination(GLOBALLY)

SELECT CD.continent, CD.location, CD.date, CD.population,
		VC.new_vaccinations, SUM(CONVERT(INT,VC.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS RollingPeopleVaccinated
FROM Portfolio_Project_Covid..CovidDeaths CD
JOIN Portfolio_Project_Covid..CovidVaccinations VC
	ON CD.location = VC.location
	AND CD.date = VC.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3


-----------------------------------------------------------------------------------------------------------------------

--USE CTE

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population,
		VC.new_vaccinations, SUM(CONVERT(INT,VC.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS RollingPeopleVaccinated
FROM Portfolio_Project_Covid..CovidDeaths CD
JOIN Portfolio_Project_Covid..CovidVaccinations VC
	ON CD.location = VC.location
	AND CD.date = VC.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac

-------------------------------------------------------------------------------------------------------------------------------------------------------


--Temp Table

DROP Table IF EXISTS #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(
continent nvarchar(200),
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT CD.continent, CD.location, CD.date, CD.population,
		VC.new_vaccinations, SUM(CONVERT(INT,VC.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS RollingPeopleVaccinated
FROM Portfolio_Project_Covid..CovidDeaths CD
JOIN Portfolio_Project_Covid..CovidVaccinations VC
	ON CD.location = VC.location
	AND CD.date = VC.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PopulationVaccinatedPercentage


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Creating views to visualize the data for Tableau


CREATE VIEW PopulationVaccinatedPercentage AS
SELECT CD.continent, CD.location, CD.date, CD.population,
		VC.new_vaccinations, SUM(CONVERT(INT,VC.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS RollingPeopleVaccinated
FROM Portfolio_Project_Covid..CovidDeaths CD
JOIN Portfolio_Project_Covid..CovidVaccinations VC
	ON CD.location = VC.location
	AND CD.date = VC.date
WHERE CD.continent IS NOT NULL


CREATE VIEW PopulationPercentageInfectedUS AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
AND continent IS NOT NULL


CREATE VIEW PopulationPercentageInfectedSouthKorea AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
AND continent IS NOT NULL

CREATE VIEW PercentPopulationInfectedUS AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
AND continent IS NOT NULL

CREATE VIEW PercentPopulationInfectedSouthKorea AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
AND continent IS NOT NULL


CREATE VIEW PopulationPercentageInfectedWorld AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM Portfolio_Project_Covid..CovidDeaths


CREATE VIEW MaxInfectedRateByLocation AS
SELECT location, population, MAX(total_cases) AS MaxInfectionCount,  Max((total_cases/population))*100 AS PopulationInfectedPercentage
FROM Portfolio_Project_Covid..CovidDeaths
GROUP BY location, population


CREATE VIEW HighestDeathCountByLocation AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

CREATE VIEW HighestDeathCountInUS AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'United States'
GROUP BY location


CREATE VIEW HighestDeathCountInSouthKorea AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE location = 'South Korea'
GROUP BY location


CREATE VIEW HighestDeathCountByContinent AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NULL
GROUP BY location


CREATE VIEW GlobalData AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths
WHERE continent IS NOT NULL


CREATE VIEW GlobalVaccinationInPopulation AS 
SELECT CD.continent, CD.location, CD.date, CD.population,
		VC.new_vaccinations, SUM(CONVERT(INT,VC.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS RollingPeopleVaccinated
FROM Portfolio_Project_Covid..CovidDeaths CD
JOIN Portfolio_Project_Covid..CovidVaccinations VC
	ON CD.location = VC.location
	AND CD.date = VC.date
WHERE CD.continent IS NOT NULL
