Select *
From projects..CovidDeaths
Where continent is not Null 
Order by 3,4



--Select *
--From projects..CovidVaccinations
--Order by 3,4

--selecting the Data i'll be using 

Select location, date, total_cases, new_cases, total_deaths, population
From projects..CovidDeaths
Order by 1,2


--Total cases vs Total Deaths

-- shows the likelihood of dying if contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From projects..CovidDeaths
Where location like '%states%'
Order by 1,2

--Total cases vs population
--percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)* 100 as PercentPopulationInfected
From projects..CovidDeaths
--Where location like '%states%'
Where continent is not Null 

Order by 1,2

--countries with Highest population Infected Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as PercentPopulationInfected
From projects..CovidDeaths
--Where location like '%states%'
Where continent is not Null 
Group By location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Deth Count per populaion

Select location, max(Cast(Total_deaths as int)) as TotalDeathsCount
From projects..CovidDeaths
--Where location like '%states%'
Where continent is not Null 
Group By location
Order by  TotalDeathsCount desc

-- Breaking it Down by Continent
-- continent with Highest Deaths Count per Populaion

Select continent, max(Cast(Total_deaths as int)) as TotalDeathsCount
From projects..CovidDeaths
--Where location like '%states%'
Where continent is not Null 
Group By continent
Order by  TotalDeathsCount desc

-- Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
From projects..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

-- Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.New_vaccinations)) Over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From projects..CovidDeaths dea
join projects..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

-- using CTE

with popvsVac (continent, location, Date, population, New_vaccination, RollingPeopleVaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From projects..CovidDeaths dea
join projects..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From popvsVac


--Temp Table

Create Table #percentPopulaionVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulaionVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From projects..CovidDeaths dea
join projects..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #percentPopulaionVaccinated

-- Creating View 

Create View percentPopulaionVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From projects..CovidDeaths dea
join projects..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From percentPopulaionVaccinated