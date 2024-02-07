Select*
From [Portfolio Project]..CovidDeaths
Order by 3,4

Select*
From [Portfolio Project]..CovidVaccinations
Order by 3,4

Select Location, date, total_cases,new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1,2



--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'India'
and continent is not null
Order by 1,2

--Looking at the total cases vs population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 
From [Portfolio Project]..CovidDeaths
--Where location like 'India'
Order by 1,2


--looking at countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount,		Max((total_cases/population))*100 as Percentpopulationinfected
From [Portfolio Project]..CovidDeaths
--Where location like 'India'
Group By location, Population
Order by Percentpopulationinfected desc



--showing countries with the highest death count 
Select Location, Max(cast(total_deaths as int)) as totaldeathCount
From [Portfolio Project]..CovidDeaths
--Where location like 'India'
WHERE continent is NOT NULL
Group By location
Order by totaldeathCount desc


--Let's break things by continent
--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as totaldeathCount
From [Portfolio Project]..CovidDeaths
--Where location like  'India'
WHERE continent is not NULL
Group By continent
Order by totaldeathCount desc



-- Global numbers
--new cases is working under SUM since its data type is float but not new deaths as its data type is varchar 
	Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From [Portfolio Project]..CovidDeaths
	--Where location like 'India'
	where continent is not null 
	--Group By date
	order by 1,2

--Looking at Total Population vs Vaccinations
	Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	 SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as MaximumPeopleVaccinated
	 FROM [Portfolio Project]..CovidDeaths d
	JOIN [Portfolio Project]..CovidVaccinations v
	ON d.location = v.location
    and d.date=v.date
Where d.continent is not null
order by 2,3





--Population vs Vaccination
With PopvsVac (Continent, location, date, population, New_Vaccinations, MaximumPeopleVaccinated)
as
(Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	 SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as MaximumPeopleVaccinated
	 FROM [Portfolio Project]..CovidDeaths d
	JOIN [Portfolio Project]..CovidVaccinations v
	ON d.location = v.location
    and d.date = v.date
Where d.continent is not null
)
Select *, (MaximumPeopleVaccinated/population)*100
From PopvsVac
order by 2,3



--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_Vaccinations numeric,
MaximumPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	 SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as MaximumPeopleVaccinated
	 FROM [Portfolio Project]..CovidDeaths d
	JOIN [Portfolio Project]..CovidVaccinations v
	ON d.location = v.location
    and d.date = v.date
--Where d.continent is not null

Select *, (MaximumPeopleVaccinated/population)*100
From #PercentPopulationVaccinated





--Total Tests vs New Cases
DROP TABLE IF EXISTS #TestsVsCases;

CREATE TABLE #TestsVsCases (
    Continent NVARCHAR(250),
    Location NVARCHAR(250),
    Date DATETIME,
    Population NUMERIC,
    New_Cases NUMERIC,
    Total_Tests NUMERIC,
    MaximumTotalTests NUMERIC
);

INSERT INTO #TestsVsCases
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    d.new_cases,
    v.total_tests,
    SUM(CONVERT(BIGINT, v.total_tests))  OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS MaximumTotalTests
FROM 
    [Portfolio Project]..CovidDeaths d
JOIN 
    [Portfolio Project]..CovidVaccinations v ON d.location = v.location
                                             AND d.date = v.date;

Select *
From #TestsVsCases


--ICU Patients vs Hospital Patients
DROP TABLE IF EXISTS #ICUvsHospital;

CREATE TABLE #ICUvsHospital (
    Continent NVARCHAR(250),
    Location NVARCHAR(250),
    Date DATETIME,
    Population NUMERIC,
    ICU_Patients NUMERIC,
    Hospital_Patients NUMERIC,
    MaximumICUPatients BIGINT,
    MaximumHospitalPatients BIGINT
);

INSERT INTO #ICUvsHospital
SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    d.icu_patients,
    d.hosp_patients,
    SUM(CONVERT(BIGINT, d.icu_patients)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS MaximumICUPatients,
    SUM(CONVERT(BIGINT, d.hosp_patients)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS MaximumHospitalPatients
FROM 
    [Portfolio Project]..CovidDeaths d
JOIN 
    [Portfolio Project]..CovidVaccinations v ON d.location = v.location
                                             AND d.date = v.date;
Select *
From #ICUvsHospital





--Creating views for visualizations
	Create View PercentPopulationVaccinated as
	Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
		 SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as MaximumPeopleVaccinated
		 FROM [Portfolio Project]..CovidDeaths d
		JOIN [Portfolio Project]..CovidVaccinations v
		ON d.location = v.location
		and d.date = v.date
	Where d.continent is not null
	 
	 Select * 
	 From PercentPopulationVaccinated


--Deaths due to covid and other factors as well.
SELECT d.date,
   d.location,
    d.total_deaths,
	d.total_cases,
	(d.total_cases/d.population)*100 as PercentPopulationAffected, 
    v.extreme_poverty,
    v.gdp_per_capita,
    v.cardiovasc_death_rate,
    v.diabetes_prevalence,
    v.female_smokers,
    v.male_smokers
FROM [Portfolio Project]..CovidDeaths d
		JOIN [Portfolio Project]..CovidVaccinations v
		ON d.location = v.location
		and d.date = v.date
	Where d.continent is not null

