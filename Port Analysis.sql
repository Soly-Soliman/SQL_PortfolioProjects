select *  
from PortfolioProjects ..CovidDeaths 
 
; 

Select * from PortfolioProjects..CovidVaccinations 
order by 3,4
;

-- Select The data that we are going to use it 
Select 
Location , Date , CovidDeaths.total_cases ,CovidDeaths.location from CovidDeaths 

order by 1 , 2 
;
--loking  at total cases vs Total Death and with specific location 
Select location , date , total_cases ,Total_Deaths 
,(cast (CovidDeaths.total_deaths as float) / CovidDeaths.total_cases) * 100 as DeathPercentage
From PortfolioProjects..CovidDeaths Where date > '2022-11-02' and location like '%c' order by date ;

--
SELECT 
	Location , Population ,MAX(total_cases) as HighestInfecctionCount 
	, MAX((total_cases/population))*100 as PercenPopulationInfected 
from CovidDeaths 
group by (Location) , population
order by location ,  PercenPopulationInfected desc
; 
--showing counties with Highest Death Count per Populaion 

SELECT 
	Location , Max(Total_deaths) as TotalDeathCount 
from CovidDeaths 
group by (Location)
order by TotalDeathCount   desc
; 
-- let's Break things down by continent

select continent , Max(cast(total_deaths  as int ))as Total_deaths_count 
from PortfolioProjects..CovidDeaths
where continent IS NOT NULL 
GROUP BY continent 
order by Total_deaths_count ;

-- break things Down but by location and isted of continant 
select location,Max(cast(total_deaths  as int ))as Total_deaths_count 
from PortfolioProjects..CovidDeaths
where continent IS not null
GROUP BY location 
order by Total_deaths_count ; 

---showing the continant with the hightest death count per population  
select  continent ,  max (cast(total_deaths as int )) as total_deaths_Count 
from 
PortfolioProjects..CovidDeaths 
where continent is not null 
group by continent
order by total_deaths_count desc ; 

--GLOBAL Numbers
Select  date , sum(new_cases) as total_cases , sum (cast(new_deaths as int ))  as total_Deaths
	,  (sum(cast (new_deaths as int )) / (sum(new_cases)+1)) * 100 as Death_bercentage 

  --,total_cases , total_deaths ,(total_deaths/total_cases) * 100 as Death_percentage
from PortfolioProjects..CovidDeaths 
where   date > '2022-08-10' and continent is not null  
group by date 
order by 1, 2 ;


-- Looking at total Popualion VS vaccinations
-- WE GONNA USE  CTE TO HANDEL complex query 
with popvsVAC  
	(continent ,  location ,date , population , new_vaccinations ,RollingPeopleVaccinated ) 
as 
	(
	Select death.continent ,  death.location ,vac.date , death.population , vac.new_vaccinations 
	, sum (cast(vac.new_vaccinations as int )) over
	(Partition by death.location order by death.location , Vac.date ) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated / vac.population) *100 as RollingBY
	from PortfolioProjects..CovidDeaths as DEATH join PortfolioProjects..CovidVaccinations AS VAC
	on DEATH.location = vac.location and DEATH.date = vac.date 
	where death.continent is not null 
	--order by 1 
) select *  ,  (RollingPeopleVaccinated/population) * 100 as P_VS_VAC  from popvsVAC ;

--Temp table 

DROP Table if exists Percenat_POPULATION_VACCINATED
create table Percenat_POPULATION_VACCINATED 
(		
		continent nvarchar(255),
		location  nvarchar(255),
		date datetime ,
		population numeric,
		new_vaccinations numeric ,
		RollingPeopleVaccinated numeric ,
		)
insert into Percenat_POPULATION_VACCINATED

Select death.continent ,  death.location ,vac.date , death.population , vac.new_vaccinations 
	, sum (cast(vac.new_vaccinations as int )) over
	(Partition by death.location order by death.location , Vac.date ) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated / vac.population) *100 as RollingBY
	from PortfolioProjects..CovidDeaths as DEATH join PortfolioProjects..CovidVaccinations AS VAC
	on DEATH.location = vac.location and DEATH.date = vac.date 
	where death.continent is not null 
	--order by 1

	select *  ,  (RollingPeopleVaccinated/population) * 100 as P_VS_VAC  from Percenat_POPULATION_VACCINATED ;

	create view Percenat_POPULATION_VACCINATEDa as 
	Select death.continent ,  death.location ,vac.date , death.population , vac.new_vaccinations 
	, sum (cast(vac.new_vaccinations as int )) over
	(Partition by death.location order by death.location , Vac.date ) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated / vac.population) *100 as RollingBY
	from PortfolioProjects..CovidDeaths as DEATH join PortfolioProjects..CovidVaccinations AS VAC
	on DEATH.location = vac.location and DEATH.date = vac.date 
	where death.continent is not null 
	--order by 1