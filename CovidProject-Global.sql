
-- Check if the data was imported correctly

SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
 WHERE continent IS NOT NULL 
ORDER BY 3,4

-- Data we are going to use for now

SELECT location, date, total_cases,new_cases,total_deaths,population 
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Total Cases Vs Total Deaths


SELECT location, date, total_cases,total_deaths,
Round((total_deaths/total_cases)*100,3) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
--WHERE location like '%Canada%'
ORDER BY 1,2


--Percentage of Infected Poulation (Total Cases Vs Population)


SELECT location, date, total_cases,population,
Round((total_cases/population)*100,3) AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL 
-- WHERE location like '%Canada%'
ORDER BY 1,2

-- Countries with  Highest Infection Rate compared to population 

SELECT location, MAX(total_cases) as HighestInfectionCount, ROUND(MAX(total_cases/population)*100,3) as PercentagePopulationInfected
FROM CovidDeaths
-- WHERE location like '%Canada%'
WHERE continent IS NOT NULL 
GROUP BY population,location 
ORDER BY PercentagePopulationInfected DESC 

-- COUNTRIES WITH HIGHEST DEATH COUNTS 
-- use CAST to convert column data into INT, also  CONVERT(INT,columnname) works the same

SELECT location,MAX(cast(total_deaths as int))as TotalDeaths 
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND location like '%Canda%'
GROUP BY location
ORDER BY TotalDeaths  desc

-- Total Death count per continent 


SELECT continent,MAX(cast(total_deaths as int))as TotalDeaths 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths  desc



-- Global Numbers as of today(Jan 02nd 2022)

SELECT date, SUM(new_cases ) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
order by 1,2


-- Total Population vs Vaccinations , here we will Join coviddeaths and covidvaccinations tables

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, 
CovidVaccinations.new_vaccinations
, SUM(CONVERT(BIGINT,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date ) as RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location= CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
  ORDER BY 2,3

 --    -- use of Common Table expression(CTE) to show Percentage of vaccinations over population
 -- POPULATION VS VACCINATIONS

 WITH popVsvac (continent,location,date,population,New_vaccinations,RollingPeopleVaccinated) 
 as
  (
  SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, 
CovidVaccinations.new_vaccinations
, SUM(CONVERT(BIGINT,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date ) as RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location= CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
 WHERE CovidDeaths.continent IS NOT NULL
-- AND CovidDeaths.location like '%canada%'
  -- ORDER BY 2,3
  )

  SELECT *
,round((RollingPeopleVaccinated/population)*100,3) as populationVax
  FROM popVsvac




  -- Temp Table
  DROP TABLE IF EXISTS #PercentPopulationVaccinated

  CREATE TABLE #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
 Date datetime,
 population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 
  INSERT INTO #PercentPopulationVaccinated
    SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, 
CONVERT(int,CovidVaccinations.new_vaccinations)
, SUM(CONVERT(BIGINT,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date ) as RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location= CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
--WHERE CovidDeaths.continent IS NOT NULL
-- AND CovidDeaths.location like '%canada%'
 -- ORDER BY 2,3
  
   SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
  FROM #PercentPopulationVaccinated


 

  --creating views

  -- View for PercentPopulationVaccinated

  Create View PercentPopulationVaccinated as
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CONVERT(int,CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.Location Order by CovidDeaths.location, CovidDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location =CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null 

--cREATING THE VIEW FOR TotalDeaths

CREATE VIEW TotalDeaths as
SELECT continent,MAX(cast(total_deaths as int))as TotalDeaths 
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
-- ORDER BY TotalDeaths  desc