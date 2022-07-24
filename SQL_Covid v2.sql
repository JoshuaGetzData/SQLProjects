
Select *
From [Portfolio Project]..Covid_deaths$
Order by 3,4

--Select *
--From [Portfolio Project]..Covid_Vaxx
--Order by 3,4

--Select Data we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..Covid_deaths$
Order by 1,2


-- Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..Covid_deaths$
Where location like'%states%'
Order by 1,2

-- Look at total cases vs population
-- Shows what % of population got covid

Select Location, date, total_cases, Population, (total_cases/population) as CaseRate
From [Portfolio Project]..Covid_deaths$
Order by 1,2

-- Countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CaseRatebyPopulation
From [Portfolio Project]..Covid_deaths$
Group by Location, Population
Order by CaseRatebyPopulation desc

-- Show Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..Covid_deaths$
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- view by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..Covid_deaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..Covid_deaths$
Where continent is not null
--Group by date
Order by 1,2

-- find average weekly icu admissions vs total cases per million

Select Location, AVG(cast(weekly_icu_admissions as int)), AVG(total_cases_per_million), AVG(cast(weekly_icu_admissions as int))/AVG(total_cases_per_million)
*100 as AVG_ICU_per_case
From [Portfolio Project]..Covid_deaths$
-- Where continent is not null
Group by Location
Order by AVG_ICU_per_case desc

-- Average ICU visit per case by country

Select Location, AVG(cast(icu_patients as int)), AVG(total_cases), AVG(cast(icu_patients as int))/AVG(total_cases)
*100 as AVG_ICU_per_case
From [Portfolio Project]..Covid_deaths$
-- Where continent is not null
Group by Location
Order by AVG_ICU_per_case desc

-- Join tables to view population vs new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(BIGINT,vax.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..Covid_deaths$ dea
Join [Portfolio Project]..Covid_Vaxx vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
SUM(Convert(BIGINT,vax.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..Covid_deaths$ dea
Join [Portfolio Project]..Covid_Vaxx vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as vaxperpop
From PopvsVac

-- Creating view for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(BIGINT,vax.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..Covid_deaths$ dea
Join [Portfolio Project]..Covid_Vaxx vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated