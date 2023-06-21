--2
SELECT Location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE LOCATION IS LIKE '%states%'
WHERE continent is NULL
AND LOCATION NOT IN ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc