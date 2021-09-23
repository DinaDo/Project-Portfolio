/*
Queries used for Tableau Project
*/

--1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Order by 1,2

Create View TotalCovidCases as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
--Order by 1,2


--2.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Create View DeathCountPerContinent as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc


--3.

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Group by location, population
Order by PercentPopulationInfected desc

Create View InfectionRatePerCountry as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Group by location, population
--Order by PercentPopulationInfected desc


--4.

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Group by Location, Population, date
Order by PercentPopulationInfected desc

Create View CountryInfectionRateByDate as
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Vietnam'
Where continent is NOT NULL
Group by Location, Population, date
--Order by PercentPopulationInfected desc


--5.

Create View PercentPopulationFullyVaccinated as
Select vac.location,vac.continent, vac.date, vac.new_vaccinations, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population)*100 as PercentPopulationFullyVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and dea.date = vac.date
Where vac.continent is NOT NULL
--and vac.location like 'United States'
--Order by 1,2