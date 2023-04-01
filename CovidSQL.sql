--SELECT *
--FROM [CovidVaccinations]

SELECT *
FROM [CovidDeaths]
WHERE continent is not NULL
ORDER BY 3,4

SELECT [Location], [date], [total_cases], [new_cases], [total_deaths], [population]
FROM [CovidDeaths]
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your Country

SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location LIKE '%states%'
AND WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE Location LIKE '%states%'
AND WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection rate

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCountry, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE Location LIKE '%states%'
AND WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Let's Break Things down by continent



-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
Sum(cast(new_deaths as float))/Sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

-- Joining two tables
SELECT *
FROM [PorfolioProject].[dbo].[CovidDeaths] dea
JOIN [PorfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.Location = vac.Location
    AND dea.date = vac.date


-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM [PorfolioProject].[dbo].[CovidDeaths] dea
JOIN [PorfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.Location = vac.Location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--USE CTE: Common Table Expression


WITH PopVsVac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
FROM [PorfolioProject].[dbo].[CovidDeaths] dea
JOIN [PorfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.Location = vac.Location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Temp Table: Temporary Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
FROM [PorfolioProject].[dbo].[CovidDeaths] dea
JOIN [PorfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.Location = vac.Location
    AND dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE DATA LATER FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
FROM [PorfolioProject].[dbo].[CovidDeaths] dea
JOIN [PorfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.Location = vac.Location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



