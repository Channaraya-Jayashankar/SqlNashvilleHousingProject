/*
**Covid-19 Data Exploration**

This SQL script showcases various data exploration techniques used to analyze the Covid-19 dataset. The following skills are demonstrated:
- SQL Joins
- Common Table Expressions (CTEs)
- Temporary Tables
- Window Functions
- Aggregate Functions
- Data Type Conversions

The goal is to extract meaningful insights such as infection rates, death percentages, vaccination rates, and more.
*/

-- **Step 1: Basic Data Inspection**
-- Fetch all records from the CovidDeaths table where the continent is not null.
-- This step helps in getting a quick overview of the data.
SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- **Step 2: Initial Data Selection**
-- Select essential fields such as location, date, total cases, new cases, total deaths, and population.
-- This helps to set the stage for more focused analysis.
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- **Step 3: Total Cases vs Total Deaths**
-- Calculate the death percentage to understand the likelihood of dying if one contracts Covid-19 in a particular country.
SELECT Location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- **Step 4: Total Cases vs Population**
-- Determine what percentage of the population has been infected with Covid-19.
SELECT Location, date, Population, total_cases,  
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2;

-- **Step 5: Countries with the Highest Infection Rate**
-- Identify countries with the highest infection rates compared to their population.
SELECT Location, Population, 
       MAX(total_cases) AS HighestInfectionCount,  
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- **Step 6: Countries with the Highest Death Count per Population**
-- Find the countries with the highest death count relative to their population.
SELECT Location, 
       MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- **Step 7: Breakdown by Continent**
-- Analyze which continents have the highest death counts per population.
SELECT continent, 
       MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- **Step 8: Global Numbers**
-- Aggregate data to get global totals of cases and deaths, and calculate the global death percentage.
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       (SUM(CAST(new_deaths AS INT)) / SUM(New_Cases)) * 100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- **Step 9: Total Population vs Vaccinations**
-- Show the percentage of the population that has received at least one Covid-19 vaccine.
-- This query uses a window function to calculate rolling totals of vaccinations.
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.Location ORDER BY CAST(dea.location AS varchar(255)), dea.Date) AS RollingPeopleVaccinated
FROM 
    PortfolioProjects..CovidDeaths dea
JOIN 
    PortfolioProjects..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;



-- **Step 10: Using CTE to Calculate Rolling Vaccinations**
-- This Common Table Expression (CTE) performs a similar calculation as the previous query but makes it easier to manipulate and extend.
WITH PopvsVac AS (
    SELECT dea.continent, 
           dea.location, 
           dea.date, 
           dea.population, 
           vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) 
           OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM PortfolioProjects..CovidDeaths dea
    JOIN PortfolioProjects..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, 
       (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- **Step 11: Using Temporary Tables to Calculate Rolling Vaccinations**
-- Temporary tables can be used for calculations when the data needs to be reused multiple times.
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) 
       OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;


-- Fetch data from the temp table with calculated vaccination percentages.
SELECT *, 
       (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;

-- **Step 12: Exploring Time-Series Data**
-- Calculate a 7-day rolling average of new cases to smooth out daily fluctuations and analyze trends.
SELECT location, date,
       AVG(new_cases) 
       OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS WeeklyAvgCases
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL;

-- **Step 13: Cluster Analysis**
-- Analyze vaccination rates, infection rates, and death rates across different locations to identify patterns or clusters.
WITH VaccinationStats AS (
    SELECT dea.location, 
           dea.population,
           MAX(dea.total_cases / dea.population) * 100 AS InfectionRate,
           MAX(dea.total_deaths / dea.population) * 100 AS DeathRate,
           SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) AS TotalVaccinations
    FROM PortfolioProjects..CovidDeaths dea
    JOIN PortfolioProjects..CovidVaccinations vac 
        ON dea.location = vac.location
    GROUP BY dea.location, dea.population
)
SELECT location,
       InfectionRate,
       DeathRate,
       (TotalVaccinations / population) * 100 AS VaccinationRate
FROM VaccinationStats;

-- **Step 14: Anomaly Detection**
-- Detect anomalies in new Covid-19 cases by calculating Z-Scores.
-- A high Z-Score indicates an unusual spike in cases.
SELECT location, date, new_cases,
       (new_cases - AVG(new_cases) OVER (PARTITION BY location)) / STDEV(new_cases) OVER (PARTITION BY location) AS ZScore
FROM PortfolioProjects..CovidDeaths;
