SELECT * 
FROM [dbo].[CovidDeaths]
ORDER BY 3,4;

 --SELECT * FROM CovidVaccinations$
 --ORDER BY 3,4;



 SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM CovidDeaths
	ORDER BY 1,2



ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT

-- Looking total cases vs population

 SELECT location, date, population, total_cases, (total_cases/population)*100 
	FROM CovidDeaths
	WHERE location like '%States%'
	ORDER BY 1,2


-- looking countries with higest infection compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
	FROM CovidDeaths
	--WHERE location like '%States%'
	GROUP BY location, population
	ORDER BY PercentPopulationInfected DESC


--Showing the Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
	FROM CovidDeaths
	--WHERE location like '%States%'
	WHERE continent is not null
	GROUP BY location
	ORDER BY TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths,
(SUM(cast(new_deaths as float))/(SUM(cast(new_cases as float)))*100) AS DeathPercentage
	FROM CovidDeaths
	WHERE continent is not null
	ORDER BY 1,2


--Looking at Total Population vs Vaccinations
--USE CTE
WITH PopvsVac (Coninent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
) 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null