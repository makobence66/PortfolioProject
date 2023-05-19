select*
from CovidDeaths
where continent is not null
order by 3,4

--select*
--from CovidVaccinations
--order by 3,4

--Select Data
 
 select location, date, total_cases, new_cases, total_deaths, population
 from CovidDeaths
 where continent is not null
 order by 1,2

 --Total Cases vs Total Deaths in US

 select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
 from CovidDeaths
 where location like '%states%' and  continent is not null
 order by 1,2

 --Total Cases vs Population

 select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 from CovidDeaths
 --where location like '%states%' and continent is not null
 order by 1,2

 --Looking at Countries with the Highest Infection Rate compared to Population 

 select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 from CovidDeaths
 --where location like '%states%' and continent is not null
 group by location, population
 order by PercentPopulationInfected desc

 --Showing Countries with Highest Death Count per Population

 select location, population, Max(cast(total_deaths as int)) as TotalDeathCount
 from CovidDeaths
 --where location like '%states%'
 where continent is not null
 group by location, population
 order by TotalDeathCount desc

 --Let's break things down by continent

 select continent, Max(cast(total_deaths as int)) as TotalDeathCount
 from CovidDeaths
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --showing continent with the highest death count per population

 select continent, Max(cast(total_deaths as int)) as TotalDeathCount
 from CovidDeaths
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Global numbers

 select Sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/
 sum(new_cases)*100 as DeathPercentage
 from CovidDeaths
 --where location like '%states%'
 where continent is not null
 --group by date
 order by 1,2

 --Looking at Total Populations vs Total Vaccinations
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --Use CTE

 with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )

 select*, (RollingPeopleVaccinated/population)*100
 from PopvsVac



 --Temp Table

 drop table if exists #PercentagePopulationVaccinated
 create table #PercentagePopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select*, (RollingPeopleVaccinated/population)*100
 from #PercentagePopulationVaccinated

 --created views to store data for later visualizations

 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select*
 from PercentPopulationVaccinated