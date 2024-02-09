--select *
--from PortfoloiProject..covidvaccinations
--order by 3,4


select * 
from Portfolioproject..coviddeaths
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
Where continent is not null
Order by 1,2


-- Looking at Total cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..coviddeaths
where location like '%states%',
Order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths
--where location like '%states%'
Order by 1,2

--Looking at Countries with Higest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths
Group by Location, population
Order by PercentPopulationInfected Desc

--Showing Coiuntries with HIgest Death count per Population

Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by Location
Order by TotalDeathCount Desc


-- Showing the continents with highest death count

Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount Desc


-- Global Numbers

Select sum(new_cases)as Total_cases, sum(new_deaths) as Total_deaths, 
(sum(new_deaths)/sum(new_cases)) as DeathPercentage
From PortfolioProject..coviddeaths
Where continent is not null
Order by 1,2

Create View GlobalNumbers as
Select sum(new_cases)as Total_cases, sum(new_deaths) as Total_deaths, 
(sum(new_deaths)/sum(new_cases)) as DeathPercentage
From PortfolioProject..coviddeaths
Where continent is not null
--Order by 1,2


-- Looking at Total Population vs Vaccination

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
 Join PortfolioProject..covidvaccinations vac
  on dea.location = vac.location
   and dea.date = vac.date
    Where dea.continent is not null
   Order by 2,3

Create View PopvsVacc as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
 Join PortfolioProject..covidvaccinations vac
  on dea.location = vac.location
   and dea.date = vac.date
    Where dea.continent is not null
   --Order by 2,3

--Use CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
 Join PortfolioProject..covidvaccinations vac
  on dea.location = vac.location
   and dea.date = vac.date
    Where dea.continent is not null
   )
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
 Join PortfolioProject..covidvaccinations vac
  on dea.location = vac.location
   and dea.date = vac.date
    --Where dea.continent is not null
   

   Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(float,new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
 Join PortfolioProject..covidvaccinations vac
  on dea.location = vac.location
   and dea.date = vac.date
    Where dea.continent is not null
	--Order by 2,3

Select *
From PercentPopulationVaccinated


