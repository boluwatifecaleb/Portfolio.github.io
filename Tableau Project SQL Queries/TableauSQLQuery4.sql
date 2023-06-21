--4
SELECT location, Population, date, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS InfectionPercentage
FROM CovidDeaths AS CD
-- WHERE Location like '%states%' 
GROUP BY Location, population, date
ORDER BY InfectionPercentage DESC