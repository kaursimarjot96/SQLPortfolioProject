Select * from CovidDeaths

--Select * from CovidVaccinations

Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

Select location, 
       Count(total_cases)
from CovidDeaths
group by location
order by location

 Select location, 
       Count(total_cases) over (partition by location) as total_cases_count
from CovidDeaths
order by location

--Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, 
       Round((total_deaths/total_cases)* 100,2) DeathPercentage
from CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, 
       Round((total_deaths/total_cases)* 100,2) DeathPercentage
from CovidDeaths
Where location like '%india%'
order by 1,2

--Total Cases vs Population

Select location, date, total_cases, population, 
       Round((total_cases/population)* 100,2) TotalCasesPercentage
from CovidDeaths
order by 1,2

Select location, date, total_cases, population, 
       Round((total_cases/population)* 100,2) TotalCasesPercentage
from CovidDeaths
Where location = 'Canada'
order by 1,2

Select location, date, total_cases, population, 
       Round((total_cases/population)* 100,2) TotalCasesPercentage
from CovidDeaths
Where location = 'Canada' AND continent is not null
order by 1,2

-- Highest infection rate compared to population 

Select location, Max(total_cases) as HighestInfectionCount, population, 
       Max(total_cases/population)* 100 HighestInfectedPopulation
from CovidDeaths
group by location, population
order by HighestInfectedPopulation desc

--Highest Death rate compared to population 

Select location, Max(total_deaths) As HighestDeathCount
from CovidDeaths
group by location
order by HighestDeathCount Desc

Select continent, Max(Cast(total_deaths as int)) As HighestDeathCount
from CovidDeaths
Where continent is not null
group by continent
order by HighestDeathCount Desc

Select continent, Max(Cast(total_deaths as int)) As HighestDeathCount
from CovidDeaths
Where continent is null
group by continent
order by HighestDeathCount Desc

Select location, Max(total_deaths) As HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount Desc

-- Global numbers

Select date, Sum(new_cases) NewCasesSum
--, total_deaths, 
--       (total_deaths/total_cases)* 100 DeathPercentage
from CovidDeaths
Where continent is not null
group by date
order by 1,2

Select date, Sum(Cast(total_deaths as int)) TotalDeathSum
--, total_deaths, 
--       (total_deaths/total_cases)* 100 DeathPercentage
from CovidDeaths
Where continent is not null
group by date
order by 1,2

Select date, Sum(new_cases) NewCasesSum, 
             Sum(Cast(new_deaths as int)) NewDeathSum,
             (Sum(Cast(new_deaths as int))/Sum(new_cases)) * 100 DeathPercentage
from CovidDeaths
Where continent is not null
group by date
order by 1,2

Select Sum(new_cases) NewCasesSum, 
      Sum(Cast(new_deaths as int)) NewDeathSum,
      (Sum(Cast(new_deaths as int))/Sum(new_cases)) * 100 DeathPercentage
from CovidDeaths
Where continent is not null
order by 1,2

Select * from CovidVaccinations

Select * 
from CovidDeaths Dea
Join CovidVaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date

-- Total population vs Vaccination

Select Dea.continent, Dea.location, Dea.date,Dea.population, Vac.new_vaccinations  
from CovidDeaths Dea
Join CovidVaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
order by 2,3

-- Total number of Vaccinations location - wise
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       Sum(Cast(Vac.new_vaccinations as int)) over (Partition by dea.location) NewVaccinationsSum
from CovidDeaths Dea
Join CovidVaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
where dea.continent is not null
order by 2,3

-- Total number of Vaccinations location - wise and date - wise --gives cummulative frequency
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
order by 2,3

-- percaentage of Rolling Population Vaccinates ( population vs Vaccinations)

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPopulationVaccinated/population)* 100 PercentageRollingPopulationVaccinated
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
And dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPopulationVaccinated/population)* 100 AS PercentPopVac
from #PercentPopulationVaccinated

Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       Sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
And dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated