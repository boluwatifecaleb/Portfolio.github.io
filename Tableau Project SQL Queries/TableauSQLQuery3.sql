--3
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS InfectionPercentage
FROM CovidDeaths AS CD
-- WHERE Location like '%states%' 
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectionPercentage DESC