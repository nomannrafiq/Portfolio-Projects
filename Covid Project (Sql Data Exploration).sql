Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contact covid in your country

Select Location, date, total_cases, total_deaths , (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%pakistan%'
order by 1,2

-- Looking at the total cases vs population
-- shows what percentage of population got covid

Select Location, date,  population, MAX(total_cases ) , max((total_cases / population ))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%pakistan%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases ) as HighestInfectionCount , MAX((total_cases / Population )) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- where location like '%pakistan%'
group by Location, Population
order by PercentPopulationInfected


-- Showing countries withhighest death count per population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%pakistan%'
where continent is not null
group by Location 
order by TotalDeathCount desc



--- LET'S BREAK THINGS BY CONTINENT

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%pakistan%'
where continent is null
group by location 
order by TotalDeathCount desc



-- Showing continents with highest death counts

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%pakistan%'
where continent is not null
group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS


Select sum(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, sum(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%pakistan%'
where  continent is not null
--group by date
order by 1,2 



-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

]Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * 
from PercentPopulationVaccinated