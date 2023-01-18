-- --shows likelihood of dying if you contracted covid in your country
  SELECT location, date, total_cases, total_deaths, 100.0 * total_deaths/total_cases AS deathPercentage
  FROM PortfolioProject..covidDeaths
  WHERE location LIKE '%states%'
  ORDER BY 1,2;

-- -- looking at percent of population infected
 SELECT location, date, total_cases, population, 100.0 * total_cases/population AS population_percentage
 FROM PortfolioProject..covidDeaths
 WHERE location LIKE '%states%'
 ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population
 SELECT location, population, MAX(total_cases) AS highestInfectionCount, 100.0 * Max((total_cases/population)) AS populationPercentageInfected
 FROM PortfolioProject..covidDeaths
 GROUP BY location,population
 ORDER BY highestInfectionCount DESC;

--Showing countries with the highest death count per population
 SELECT location, continent, MAX(total_deaths) AS totalDeathCount
 FROM PortfolioProject..covidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location, continent
 ORDER BY totalDeathCount DESC;

-- broken down by continent
 SELECT continent, MAX(total_deaths) AS totalDeathCount
 FROM PortfolioProject..covidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY totalDeathCount DESC;

--OR
 SELECT location, MAX(total_deaths) AS totalDeathCount
 FROM PortfolioProject..covidDeaths
 WHERE continent IS NULL
 GROUP BY location
 ORDER BY totalDeathCount DESC;

-- GLOBAL NUMBERS RUNNING
  SELECT date,SUM(new_cases)as totalCases, SUM(new_deaths)as totalDeaths, SUM(new_deaths)/SUM(new_cases) * 100 AS deathPercentage
  FROM PortfolioProject..covidDeaths
  WHERE continent IS NULL
  GROUP BY date
  ORDER BY 1,2;

--Looking at total population vs new vaccinations per day USING CTE
 WITH PopvsVac (continent,location, date, population, new_vaccinations, rollingPeopleVaccinated)
 as (
  SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
   SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
   FROM PortfolioProject..covidDeaths dea
   JOIN PortfolioProject..covidVaccinations vac
     ON dea.location = vac.LOCATION 
     and dea.date = vac.date
   where dea.continent is not null)
 SELECT *, (rollingPeopleVaccinated/population)*100 as percentPopVaccinated
 FROM PopvsVac
 WHERE location like '%canada%'
 ORDER BY 2,3

-- USING TEMP TABLE
 DROP Table if exists #percentPopulationVaccinated
 CREATE TABLE #percentPopulationVaccinated
 (
     continent nvarchar(50),
     location nvarchar(50),
     date date,
     population numeric,
     new_vaccinations numeric,
     rollingPeopleVaccinated numeric
 )
 Insert INTO #percentPopulationVaccinated
 SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
   FROM PortfolioProject..covidDeaths dea
   JOIN PortfolioProject..covidVaccinations vac
   ON dea.location = vac.LOCATION 
   and dea.date = vac.date
   where dea.continent is not null
 SELECT *, (rollingPeopleVaccinated/population)*100 as percentPopulationVaccinated
    FROM #percentPopulationVaccinated
    ORDER BY 2,3

-- Creating view to store data for later visualization
-- CREATE VIEW PercentPopulationVaccinated AS
--    SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
--    SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--    FROM PortfolioProject..covidDeaths dea
--    JOIN PortfolioProject..covidVaccinations vac
--      ON dea.location = vac.LOCATION 
--      and dea.date = vac.date
--    where dea.continent is not null;


   










