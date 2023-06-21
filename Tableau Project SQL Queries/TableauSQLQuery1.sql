--1
SELECT SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths AS CD
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2