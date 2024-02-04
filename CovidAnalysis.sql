/*SELECT location, date, total_cases, population, (total_cases / population) as DeathPercentage 
from CovidDeaths cd 
where location = 'India'
order by 2*/

/*Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
where continent is not NULL 
group by continent 
order by TotalDeathCount DESC */

--Select * from CovidDeaths cd 

/*SELECT date,SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM CovidDeaths cd 
WHERE continent is not NULL 
GROUP BY date 
ORDER BY 1,2*/

/*Select *
from CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date*/


/*Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations  
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not NULL 
order by 2,3*/

/*Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) over 
(PARTITION by cd.location order by cd.location, cd.date)  
from CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location and cd.date = cv.date
where cd.location = 'Albania'
order by 2,3*/


/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths cd 
Where continent is not null 
order by location, CAST(date AS DATE)




-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths cd 
Where continent is not null 
order by location, CAST(date AS DATE)


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location , date, total_cases, total_deaths, (total_deaths*1.0/total_cases*1.0)*100 as DeathPercentage
From CovidDeaths cd 
Where location like '%states%' and continent is not null 
order by location, CAST(date AS DATE)


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location , date, population, total_cases, (total_cases *1.0/population *1.0)*100 as DeathPercentage
From CovidDeaths cd 
Where location like '%states%' and continent is not null 
order by location, CAST(date AS DATE)



-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases*1.0) as HighestInfectionCount, 
MAX((total_cases *1.0/population *1.0))*100 as PercentPopulationInfected
From CovidDeaths cd 
--Where location like '%states%' and continent is not null 
group by location, population 
order by PercentPopulationInfected DESC 


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
where continent is not NULL 
group by location 
order by TotalDeathCount DESC 


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths cd 
where continent is not NULL 
group by continent 
order by TotalDeathCount DESC 


-- GLOBAL NUMBERS

Select SUM(cd.new_cases) as total_cases, SUM(cast(cd.new_deaths as int)) as total_deaths, 
SUM(cast(cd.new_deaths  as int))/SUM(cd.new_cases)*100 as DeathPercentage
From CovidDeaths cd 
WHERE continent is not NULL 
ORDER BY location, CAST(date AS DATE)


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
order by cd.location, CAST(cd.date AS DATE)

Select location, date
from CovidDeaths cd 
order by DATE(date)

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location order by cd.location, DATE(cd.date)) as RollingPeopleVaccinated
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
order by cd.location, DATE(cd.date)


/*Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3?*/


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over (Partition by cd.location order by cd.location, DATE(cd.date)) as RollingPeopleVaccinate
FROM CovidDeaths cd 
Join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not NULL  
--order by cd.location, DATE(cd.date)
)
Select *
From PopvsVac

/*With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac*/



-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over (Partition by cd.location order by cd.location, DATE(cd.date)) as RollingPeopleVaccinate
FROM CovidDeaths cd 
Join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not NULL  
--order by cd.location, DATE(cd.date)

Select *,(RollingPeopleVaccinated*1.0/Population*1.0)*100
From PercentPopulationVaccinated


/*DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location order by cd.location, DATE(cd.date)) as RollingPeopleVaccinated
FROM CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
--where dea.continent is not null 
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


*/

-- Creating View to store data for later visualizations
Drop view if exists PopulationVaccinated
Create View PopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over (Partition by cd.location order by cd.location, DATE(cd.date)) as RollingPeopleVaccinate
FROM CovidDeaths cd 
Join CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not NULL  
--order by cd.location, DATE(cd.date)




