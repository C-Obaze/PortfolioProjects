select * 
from coviddeaths
where continent <> '';

-- Looking at total_cases vs total_deaths
-- shows the likelihood of dying if you contract covid in your country
select location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from coviddeaths
-- where location = 'Nigeria' 
where continent <> ''
order by 1,2;

-- Looking at total_cases versus population
-- shows what percentage of population got covid
select location, continent, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from coviddeaths
-- where location = 'Nigeria' 
where continent <> ''
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location, continent, population, max(total_cases) HighestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected
from coviddeaths
-- where location = 'Nigeria'
where continent <> ''
group by continent, location, population
order by PercentPopulationInfected desc;

-- showing continent with the highest death count per population
select continent, max(cast(total_deaths as unsigned)) TotalDeathCount
from coviddeaths
-- where location = 'Nigeria'
where continent <> ''
group by continent
order by TotalDeathCount desc;

-- global numbers
select sum(new_cases) total_cases, sum(new_deaths) total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
-- where location = 'Nigeria' 
where continent <> ''
-- group by date
order by 1,2;

-- looking at total_population vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as unsigned)) over(partition by cd.location order by cd.location, cd.date) RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.continent <> ''
order by 2,3;

-- use cte
with PopsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as unsigned)) over(partition by cd.location order by cd.location, cd.date) RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.continent <> ''
-- order by 2,3;
)

select *, (rollingpeoplevaccinated/population)*100
from popsvac;

-- creating view to store data for later visualization
create view percentpopulationvaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as unsigned)) over(partition by cd.location order by cd.location, cd.date) RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.continent <> '';
-- order by 2,3;

