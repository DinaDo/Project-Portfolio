/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order by 3,4



--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Total Cases vs Total Deaths
-- Show likelihood of dying if you get Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Vietnam'
Order by 2,3

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Poland'
Order by 2,3


-- Total Cases vs Population
-- Show what percentage of population got Covid

Select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like 'Vietnam'
Order by 2,3

Select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like 'Poland'
Order by 2,3


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Poland'
Where continent is NOT NULL
Group by location, population
Order by 4 desc


-- Countries with the Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Poland'
Where continent is NOT NULL
Group by location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continenst with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Group by continent
Order by TotalDeathCount desc

-- Or

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
--By date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Group by date
Order by 1,2

--Total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Order by 1,2



-- Total Population vs Vacinations
-- Shows Percentage if Population that has recieved at least one dose of Vaccine

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
and dea.location like 'United States'
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #Temp_PercentPopulationVaccinated
Create table #Temp_PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_Vaccinations int,
RollingPeopleVaccinated numeric
)

Insert into #Temp_PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From #Temp_PercentPopulationVaccinated
Where location like 'United States'



--Showing Percentage if Population has been Fully Vaccinated

Select vac.location, vac.date, vac.new_vaccinations, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population) as PercentPopulationFullyVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and dea.date = vac.date
Where vac.continent is NOT NULL
and vac.location like 'Vietnam'
Order by 1,2


--Creating View to store data for later visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order by 2,3

Select *
From PercentPopulationVaccinated

Create View DeathCountPerContinent as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location


Create View InfectionRatePerCountry as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Group by location, population


Create View DeathCountPerCountry as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Poland'
Where continent is NOT NULL
Group by location


