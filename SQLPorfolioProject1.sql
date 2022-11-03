

--Return all columns and row
SELECT *
FROM PorfolioProject.. CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PorfolioProject.. CovidVaccinations
ORDER BY 3,4

SELECT location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
FROM PorfolioProject..CovidDeaths
ORDER BY 1,2



-- Looking at total_cases vs Total_deaths
-- In United States and Vietnam
SELECT location, 
		date, 
		total_cases,
		total_deaths, 
		(total_deaths/total_cases)*100 AS DealthPercentage
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
WHERE location like '%state%'
--WHERE continent is not null
ORDER BY 1,2



-- Look at total_cases vs population
--Shows what percentage of population got Covid
SELECT location,
		date,
		total_cases,
		population, 
		(total_cases/population)*100 AS Percentage_of_population_Infected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
--WHERE location like '%state%'
ORDER BY 1,2



--Looking at Countries with Highest infection Rate compare to population
SELECT location,
		population,
		MAX(total_cases) AS Highest_Infection_Count,
		MAX((total_cases/population))*100 AS Percentage_of_population_Infected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
--WHERE location like '%state%'
GROUP BY location, 
			population
ORDER BY Percentage_of_population_Infected DESC



-- Showing Countries with highest Death Count per population
SELECT location,
		MAX(CAST (total_deaths AS INT)) AS Total_Death_Count
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC


--BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
SELECT continent,
		MAX(CAST (total_deaths AS INT)) AS Total_Death_Count
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC



--GLOBAL NUMBER

SELECT
	SUM(new_cases) AS Total_cases,
	SUM(CAST (new_deaths AS INT)) AS Total_deaths,
	SUM (CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DealthPercentage
FROM PorfolioProject..CovidDeaths
--WHERE location like '%viet%'
--WHERE location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2




-- Looking at Total Population vs Vaccinations

SELECT dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM (CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
jOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM (CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
jOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar (225),
Date datetime,
Population numeric,
New_vaccinations bigint,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM (CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
jOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 