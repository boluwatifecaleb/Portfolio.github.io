
Select *
From NewPortfolioProject..CovidDeaths
WHERE continent is not null

order by 3,4

--Select *
--From NewPortfolioProject..CovidVaccinations
--order by 3,4 

-- SELECT THE DATA TO WORK WITH
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM NewPortfolioProject..CovidDeaths AS CD
ORDER BY 1,2


-- TOTAL CASES VS TOTAL DEATHS IN PERCENTAGE IN USA
SELECT location, date, Population, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths AS CD
WHERE Location like '%states%' And continent is not null
-- ORDER BY 1,2

--  INFECTION RATE COMPARED TO POUPULATION
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 AS InfectionPercentage
FROM CovidDeaths AS CD
--WHERE Location like '%states%' 
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectionPercentage DESC


-- COUNTRIES WITH THE HIGHTEST DEATH RATE COMPARED TO POUPULATION
-- the cast makes us convert any datatype to any other datatype
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths AS CD
-- WHERE Location like '%states%'  
WHERE continent is not null -- SO THAT WE DO NOT SEE CONTINENTS AS LOCATION 
GROUP BY Location 
ORDER BY TotalDeathCount DESC

-- CONTINENTS WITH THE HIGHTEST DEATH RATE COMPARED TO POUPULATION
-- THIS IS THE CORRECT WAY TO GET IT CONTINENT BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths AS CD
-- WHERE Location like '%states%'' 
WHERE continent is null
GROUP BY Location -- ROLLS THEM UP INTO CONTINENTS
ORDER BY TotalDeathCount DESC

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATHS COUNT PER POPULATION
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths AS CD
-- WHERE Location like '%states%' 
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- WE WANT TO GET THE TOTAL GLOBAL NUMBERS OF COVID CASES
SELECT date, SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths AS CD
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- TOTAL NUMBER OF COVID CASES, DEATHS AND DEATH PERCENTAGE ACROSS THE WORLD
SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths AS CD
WHERE continent is not null
ORDER BY 1,2


-- JOINING THE COVID VACCINATIONS TABLE AND THE COVID DEATHS TABLE
SELECT *
FROM CovidDeaths cd
JOIN CovidVaccinations cv
    ON cd.location = cv.location
	AND cd.date = cv.date

-- TOTAL NUMBER OF POPULATION COMPARED TO VACCINATED PEOPLE
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) AS TotalNumberOfVaccinatedPeoplePerCountry
FROM CovidDeaths cd
JOIN CovidVaccinations cv
    ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not NULL
-- ORDER BY 2,3
)

-- we had to create a CTE here because we cannot use a new column we created
-- to get a calculation we need using the TotalNumberOfVaccinatedPeoplePerCountry column
-- we created by ourseleves we need to use a CTE
-- USING A CTE
WITH CTE_PopvsVac (continent, location, date, population, new_vaccinations, 
TotalNumberOfVaccinatedPeoplePerCountry)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) AS TotalNumberOfVaccinatedPeoplePerCountry
FROM CovidDeaths cd
JOIN CovidVaccinations cv
    ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not NULL
-- ORDER BY 2,3
)
SELECT *, (TotalNumberOfVaccinatedPeoplePerCountry/population)*100 as PercentOfVaccinatedPeoplePerCountry
FROM CTE_PopvsVac
  

--TEMP TABLE
-- we had to create a temp table here because we cannot use a new column we created
--that is (TotalNumberOfVaccinatedPeoplePerCountry) to get a calculation we need
-- we do not use the orderby in a temptable
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalNumberOfVaccinatedPeoplePerCountry numeric
)
insert into #PercentagePopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) AS TotalNumberOfVaccinatedPeoplePerCountry
FROM CovidDeaths cd
JOIN CovidVaccinations cv
    ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not NULL
-- ORDER BY 2,3
SELECT *, (TotalNumberOfVaccinatedPeoplePerCountry/population)*100
FROM #PercentagePopulationVaccinated


-- CREATING A VIEW
CREATE VIEW PercentageVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) AS TotalNumberOfVaccinatedPeoplePerCountry
FROM CovidDeaths cd
JOIN CovidVaccinations cv
    ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not NULL 
-- ORDER BY 2,3


SELECT *
FROM PercentagePopulationVaccinated





-- QUERIES WE WOULD BE USING IN OUR TABLEAU
--1
SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths AS CD
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

--2
SELECT Location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE LOCATION IS LIKE '%states%'
WHERE continent is NULL
AND LOCATION NOT IN ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--3
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS InfectionPercentage
FROM CovidDeaths AS CD
-- WHERE Location like '%states%' 
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectionPercentage DESC

--4
SELECT location, Population, date, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS InfectionPercentage
FROM CovidDeaths AS CD
-- WHERE Location like '%states%' 
GROUP BY Location, population, date
ORDER BY InfectionPercentage DESC
