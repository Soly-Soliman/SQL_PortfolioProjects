-- Selecting all records from CovidDeaths and CovidVaccinations, ordered by date and location.
SELECT * FROM CovidDeaths
ORDER BY Date, Location;

SELECT * FROM CovidVaccinations
ORDER BY Date, Location;


-- Selecting specific columns from CovidDeaths, ordered by location and date.
SELECT Location, Date, Total_Cases, Total_Deaths
FROM CovidDeaths
ORDER BY Location, Date;

-- Calculating death percentage based on total cases and deaths, filtered by date and location.
SELECT Location, Date, Total_Cases, Total_Deaths,
       (CAST(Total_Deaths AS FLOAT) / Total_Cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Date > '2022-11-02'
AND Location LIKE '%c'
ORDER BY Date;


-- Analyzing infection and death rates by location, both absolute and relative to population size.
SELECT Location, Date, Total_Cases, Total_Deaths,
       (CAST(Total_Deaths AS FLOAT) / Total_Cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Date > '2022-11-02'
AND Location LIKE '%c'
ORDER BY Date;

-- Computing continent-wise death counts.
SELECT Continent, MAX(Total_Deaths) AS TotalDeathsCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathsCount DESC;

-- Further breaking down death counts by location.
SELECT Location, MAX(Total_Deaths) AS TotalDeathCount
FROM CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC;
-- Determining the continent with the highest death count per population.
SELECT Continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathsCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathsCount DESC;
-- Analyzing global numbers, including cases, deaths, and death percentage over time.
SELECT Date, SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS INT)) AS TotalDeaths,
       (SUM(CAST(New_Deaths AS INT)) / (SUM(New_Cases) + 1)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Date > '2022-08-10'
AND Continent IS NOT NULL
GROUP BY Date
ORDER BY Date;
-- Analyzing the relationship between total population and vaccinations using a CTE.
WITH popvsVAC AS (
    SELECT Death.Continent, Death.Location, Vac.Date, Death.Population, Vac.New_Vaccinations,
           SUM(CAST(Vac.New_Vaccinations AS INT)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Vac.Date) AS RollingPeopleVaccinated
    FROM CovidDeaths AS Death
    JOIN CovidVaccinations AS Vac ON Death.Location = Vac.Location AND Death.Date = Vac.Date
    WHERE Death.Continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS P_VS_VAC
FROM popvsVAC;
-- Creating temporary tables and views for further analysis.
CREATE TABLE IF NOT EXISTS Percenat_POPULATION_VACCINATED (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

CREATE VIEW IF NOT EXISTS Percenat_POPULATION_VACCINATEDa AS
SELECT Death.Continent, Death.Location, Vac.Date, Death.Population, Vac.New_Vaccinations,
       SUM(CAST(Vac.New_Vaccinations AS INT)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Vac.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Death
JOIN CovidVaccinations AS Vac ON Death.Location = Vac.Location AND Death.Date = Vac.Date
WHERE Death.Continent IS NOT NULL;
