
--Select *
--From CovidVaccinations
--Order by 3, 4

Select * 
From CovidDeaths
Where continent is not null
Order by 3, 4



-- death percentage among the world

--Shows what percentage of population got covid in Iran each day

Select Location, date, total_cases, new_cases, total_deaths, population, (total_cases*1.0/population)*100 as InfectionRate
From CovidDeaths
Where location = 'Iran'
order by 2

--cases per population for each country
with InfectionRatePerCountry (Location, Population, TotalCases)
as
(
Select location, population, Max(total_cases) as totalcases
From CovidDeaths
Where continent is not null
Group by location, population
)
Select *, (TotalCases*1.0/Population)*100 as Ratio
From InfectionRatePerCountry
order by Ratio desc

-- death per population for each country
with DeathRatePerCountry (Location, Population, TotalDeaths)
as
(
Select location, population, Max(total_deaths) as totaldeaths
From CovidDeaths
Where continent is not null
Group by location, population
)
Select *, (TotalDeaths*1.0/Population)*100 as Ratio
From DeathRatePerCountry
order by Ratio desc


-- look at countries with the highest Infection rate compare to their population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases*1.0/population))*100 as InfectionRate
From CovidDeaths
Where continent is not null
Group by location, population
order by InfectionRate DESC

Select location, population, Max(total_deaths) as HighestDeathCount, Max((total_deaths*1.0/population))*100 as DeathRate
From CovidDeaths
Where continent is not null
Group by location, population
order by DeathRate DESC

--Death Rate By Population by continent

Select continent, Max(total_deaths) as HighestDeathCount, Max((total_deaths*1.0/population))*100 as DeathRateByPopulation
From CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathCount DESC 

-- Shows the death percentage in Iran each day
Select date, total_cases, new_cases, total_deaths, (total_deaths*1.0/total_cases)*100 AS DeathPerCases
From CovidDeaths
Where location = 'Iran'
order by 1

-- Shows the death percentage in the world each day
Select date, Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths*1.0)/Sum(new_cases))*100 as DeathPerCases
From CovidDeaths
Where continent is not null
Group by date
order by 1

--death per cases in Iran
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths*1.0)/Sum(new_cases))*100 as DeathPerCases
From CovidDeaths
Where continent is not null and location = 'Iran'

--death per cases worldwide
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths*1.0)/Sum(new_cases))*100 as DeathPerCases
From CovidDeaths
Where continent is not null


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
	--(TotalVaccination*1.0/dba.population) cuz we just created totalvaccinations we cant use it like this, cte or tempt tables are needed
From CovidVaccinations vac
Join CovidDeaths dea
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--CTE
with popVSvac (Continent, Location, Date, Population, New_Vaccination, TotalVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
From CovidVaccinations vac
Join CovidDeaths dea
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (TotalVaccination*1.0/Population)*100 as Ratio
From popVSvac


--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
From CovidVaccinations vac
Join CovidDeaths dea
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3

Select Location, Max(TotalVaccination*1.0/Population)*100 as VaccinationPerPopulation
From #PercentPopulationVaccinated
group by Location
order by 2 desc

-- Create views for further visualization
drop view PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
From CovidVaccinations vac
Join CovidDeaths dea
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select * From PercentPopulationVaccinated

-- views for visualization

Create view InfectionRatePerDayIran as
Select Location, date, total_cases, new_cases, total_deaths, population, (total_cases*1.0/population)*100 as InfectionRate
From CovidDeaths
Where location = 'Iran'

Select * From InfectionRatePerDayIran


Create view InfectionRatePerPopulation as
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases*1.0/population))*100 as InfectionRate
From CovidDeaths
Where continent is not null
Group by location, population

Select * From InfectionRatePerPopulation

Create view DeathRatePerPopulation as
Select location, population, Max(total_deaths) as HighestDeathCount, Max((total_deaths*1.0/population))*100 as DeathRate
From CovidDeaths
Where continent is not null
Group by location, population

Select * From DeathRatePerPopulation

Create view DeathRatebyContinent as
Select continent, Max(total_deaths) as HighestDeathCount, Max((total_deaths*1.0/population))*100 as DeathRateByPopulation
From CovidDeaths
Where continent is not null
Group by continent

Select * From DeathRatebyContinent

Create view DeathRatePerCaseIran as
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths*1.0)/Sum(new_cases))*100 as DeathPerCases
From CovidDeaths
Where continent is not null and location = 'Iran'

Select * From DeathRatePerCaseIran

Create view DeathRateWorldwide as
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths*1.0)/Sum(new_cases))*100 as DeathPerCases
From CovidDeaths
Where continent is not null

Select * From DeathRatePerCaseIran

drop view VaccinationPerPopulation
Create view VaccinationPerPopulation as
with VaccinationPerPopulation (Location, Population, TotalVaccination)
as
(
Select dea.location, dea.population,
	Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
From CovidVaccinations vac
Join CovidDeaths dea
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select Location, Population, Max(TotalVaccination*1.0/Population)*100 as VaccinationPerPopulation
From VaccinationPerPopulation
group by Location, Population

Select * from VaccinationPerPopulation
order by 3 desc
