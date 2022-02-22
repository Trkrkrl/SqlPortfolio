select *
from CovidDeaths
order by 3,4

select location,date,total_cases,new_cases,total_deaths,
population
from CovidDeaths


--location and date-konum ve tarihe gore sirala
select location,date,total_cases,new_cases,total_deaths,
population
from CovidDeaths
order by 1,2

--total cases vs total cases-toplam vaka ve top olum

select location,date,total_cases,total_deaths
from CovidDeaths
order by 1,2

--deathpercentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

-- death percentage on a spesific location

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%turkey%'
order by 1,2


--- TotalDeaths vs Population

select location,date,total_cases,total_deaths,population,(total_deaths/population)*100 as DeathPercentage
from CovidDeaths
where location like '%turkey%'
order by 1,2

--
--- TotalCases vs Population and infection rates

select location,date,total_cases,population,(total_cases/population)*100 as InfectionRate
from CovidDeaths
where location like '%turkey%'
order by 1,2

--Countries With Highest Infefciton Rate
select location,MAX(total_cases) as highestInfectionCount,Max((total_cases/population))*100 as percentPopulationInfected
from CovidDeaths
group by location,population
order by percentPopulationInfected desc

--Countries with highest Death  Rate
select location,MAX(total_deaths) as highestDeathCount,Max((total_deaths/population))*100 as TotalDeathPercentageofPopulation
from CovidDeaths
group by location,population
order by TotalDeathPercentageofPopulation desc

	--Countries with DEathCount
	select location,MAX(total_deaths) as TotalDeathCount
	from CovidDeaths
	group by location,population
	order by  TotalDeathCount desc
--- this data showed that some datas has no continent, but has location
--we'll use where continent is not null 

	select location,MAX(total_deaths) as TotalDeathCount
	from CovidDeaths
	where continent is not null
	group by location,population
	order by  TotalDeathCount desc

-- by continent
-- it might not be accurate
select continent,MAX(total_deaths) as TotalDeathCount
	from CovidDeaths
	where continent is not null
	group by continent
	order by  TotalDeathCount desc

	--Continent and special grup: continent data is more accurate here
	select location,MAX(total_deaths) as TotalDeathCount
	from CovidDeaths
	where continent is null
	group by location
	order by  TotalDeathCount desc


--Global Numbers-daily case and daily deaths-
--dunya capinda gunluk yeni vaka ve yeni ölum sayilari
select date,sum(new_cases) as dateTotalNewCaseGlobal,
sum(new_deaths) as dateTotalNewDeathGlobal 
from CovidDeaths
where continent is not null
group by date
order by 2,3 asc

--global total 
select sum(new_cases) as TotalCaseGlobal,
sum(new_deaths) as TotalDeathGlobal ,
(sum(new_deaths)/sum(new_cases))*100 as GlobalDeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

----vaccinations

select*from
CovidVaccination as vac join CovidDeaths dea
on dea.location=vac.location
and
dea.date=vac.date

--Total Population vs Vaccination
select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null
order by 2,3


--vaccination with Total vaccinations-by locations(requiresbigint)-
select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null
order by 2,3

--rolling vaccinations by spesific country
select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null and dea.location like '%turkey%'
order by 2,3

--USE CTE
With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
select
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 as vacpercentage from PopvsVac



---temp table- gecici tablo gibi birsey

DROP TABLE if exists #percentPopulationVaccinated

create table #percentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255) ,
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
select 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 as vacpercentage from #percentPopulationVaccinated



--creating view for alter purposes

Create View PercentPopulationVaccinated as

select 
dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated
from
CovidVaccination as vac join CovidDeaths dea
	on dea.location=vac.location
	and
	dea.date=vac.date
where dea.continent is not null
--order by 2,3
select*
from PercentPopulationVaccinated












