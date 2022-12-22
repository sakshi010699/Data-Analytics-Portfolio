select * from ['CovidDeaths']
order by 3,4
select * from [Portfolio Project-Covid].dbo.['CovidVaccinations']

----
select location,date,total_cases,new_cases,total_deaths,population
from ['CovidDeaths']
order by 1 ,2 

---
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ['CovidDeaths']
where location like '%states' or location='india'
order by 1 ,2 

---
select location,date,total_cases,population,(total_cases/population)*100
from ['CovidDeaths']
where location like '%states' or location='india'
order by 1 ,2

---
select Location,population, MAX(total_cases) as Maxcase,MAX((total_cases/population))*100 as InfectionPercentafge
from ['CovidDeaths']
where continent is not null
group by location,population
order by InfectionPercentafge desc

--
select location,population,date, MAX(total_cases) as Maxcase,MAX((total_cases/population))*100 as InfectionPercentage
from ['CovidDeaths']
--where continent is not  null
group by location,population,date
order by InfectionPercentage desc

---
select location , MAX(cast(total_deaths as int)) as Maxdeath,MAX((total_deaths/total_cases))*100 as DeathPercent
from ['CovidDeaths']
where continent is not Null
group by location
order by 2 desc

---

select continent, MAX(cast(total_deaths as int)) as Maxdeath,MAX((total_deaths/total_cases))*100 as DeathPercent
from ['CovidDeaths']
where continent is not Null
group by continent
order by 2
--
select date, SUM(new_cases),SUM(CAST(new_deaths as int)), (sum(cast(new_deaths as int))/SUM(new_cases))*100
from ['CovidDeaths']
where continent is not Null
group by date
order by 1
--
select  SUM(new_cases) as NewCases ,SUM(CAST(new_deaths as int)) as ToatlDeaths, (sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from [Portfolio Project-Covid]..['CovidDeaths']
where continent is not Null
order by 1,2
--

Select continent, SUM(cast(new_deaths as int)) as TotalDeaths
from ['CovidDeaths']
where continent is not null
and
continent not in ('World', 'European Union','International')
group by continent
order by 2 desc

--
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.date) as rollingcount
from ['CovidVaccinations'] vac
join ['CovidDeaths'] dea
on vac.location=dea.location
and vac.date=dea.date
where vac.continent is not null
order by 1,2,3

--
With popvsvac (Continent,Location,Date,Population,newVaccinations,RollingVaccination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.date,dea.location) as rollingcount
from ['CovidVaccinations'] vac
join ['CovidDeaths'] dea
on vac.location=dea.location
and vac.date=dea.date
where vac.continent is not null
)
select location,date,RollingVaccination/Population as percentrollingvaccination
from popvsvac
--
Drop table if exists #percentvaccinatedpop
Create table #percentvaccinatedpop(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
newVaccinations numeric,
vaccinationrollingpercent numeric)

Insert into #percentvaccinatedpop
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.date,dea.location) as rollingcount
from ['CovidVaccinations'] vac
join ['CovidDeaths'] dea
on vac.location=dea.location
and vac.date=dea.date
where vac.continent is not null

select Location,Date,vaccinationrollingpercent/Population as percentrollingvaccination
from #percentvaccinatedpop

--

Create view percentvaccinatedpop as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by dea.date,dea.location) as rollingcount
from ['CovidVaccinations'] vac
join ['CovidDeaths'] dea
on vac.location=dea.location
and vac.date=dea.date
where vac.continent is not null