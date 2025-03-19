-- Data source: https://ourworldindata.org/covid-deaths
-- Looking at the likelihood of dying if infected
SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as death_rate
FROM covid_deaths
ORDER BY 1,2;

-- Filtering on location = The UK 
SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as death_rate
FROM covid_deaths
WHERE location like "%kingdom%"
ORDER BY 1,2;

-- This part will focus on Sweden, Canada, the UK, the US, and China
-- Looking at infection rate 
SELECT location, date, population, total_cases,
(total_cases/population)*100 as infection_rate
FROM covid_deaths
WHERE location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
-- This data set seems to be obsolete seeing as official numbers of infection are significantly higher
-- E.g. US 32 346 971 people infected, Sweden 2 754 129 people infected
SELECT location, population,
MAX(total_cases) as highest_infection_count,
MAX((total_cases/population))*100 as percentage_population_infected
FROM covid_deaths
WHERE location IN ("China","Canada","United States","United Kingdom","Sweden")
GROUP BY location, population
ORDER BY 4 desc;

-- Showing countries with the highest death count/population
SELECT location, 
MAX(total_deaths) as total_death
FROM covid_deaths
WHERE location IN ("China","Canada","United States","United Kingdom","Sweden")
GROUP BY location
ORDER BY total_death DESC;

-- Vaccination rate
-- Again, official numbers seem to be significantlhy higher (> 80% for all countries)
SELECT vac.location,
	dea.population,
	SUM(vac.new_vaccinations) AS total_vaccines,
    (SUM(vac.new_vaccinations)/dea.population)*100 as vaccine_rate
FROM covid_vaccines vac
JOIN covid_deaths dea
	ON vac.location = dea.location 
    AND vac.date = dea.date
WHERE vac.location IN ("China","Canada","United States","United Kingdom","Sweden")
GROUP BY vac.location, dea.population
ORDER BY vaccine_rate ASC;


-- Comparing total number of vaccinated people with the total number of cases
SELECT dea.location, dea.population,
SUM(vac.new_vaccinations)as total_Vaccinated,
SUM(dea.new_cases) AS total_cases
FROM covid_deaths dea
JOIN covid_vaccines vac
	ON dea.location = vac.location
    AND dea.date = vac.date
GROUP BY dea.location, dea.population
HAVING location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY total_cases DESC;


-- Comparing vaccination rate and infection rate
SELECT dea.location, dea.population,
SUM(dea.new_cases) AS total_Cases,
SUM(vac.new_vaccinations)as total_Vaccinated,
((SUM(vac.new_vaccinations)/population)*100) AS vaccination_rate,
((SUM(dea.new_cases)/population)*100) AS infection_rate
FROM covid_deaths dea
JOIN covid_vaccines vac
	ON dea.location = vac.location
    AND dea.date =vac.date
GROUP BY dea.location, dea.population
HAVING location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY vaccination_rate DESC;


-- Percentage of population vaccinated, total number of deaths, and percentage of population who died:
-- Official numbers confirm that about 122 000 people died of COVID in China, this data set shows only 4828

SELECT dea.location, dea.population,
SUM(dea.new_cases) AS total_Cases,
SUM(vac.new_vaccinations)as total_Vaccinated,
((SUM(vac.new_vaccinations)/population)*100) AS percentage_vaccinated,
SUM(dea.new_deaths) AS total_death,
((SUM(dea.new_deaths)/population)*100) AS percentage_dead
FROM covid_deaths dea
JOIN covid_vaccines vac
	ON dea.location = vac.location
    AND dea.date =vac.date
GROUP BY dea.location, dea.population
HAVING location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY 7 DESC;


-- Looking at the age distribution of vaccinations
SELECT location, 
       ROUND(SUM(new_vaccinations), 2) AS total_vaccinations,
       ROUND(SUM(aged_65_older), 2) AS older_than_65,
       ROUND(SUM(aged_70_older), 2) AS older_than_70,
       ROUND(median_age, 2) AS median_age
FROM covid_vaccines
GROUP BY location, median_age
HAVING location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY median_age DESC;


-- Comparing median age of vaccination with median age of death
-- Both calculations are giving the same median age
SELECT dea.location,
dea.median_age as median_age_death,
vac.median_age as median_age_vacc
FROM covid_deaths dea
JOIN covid_vaccines vac
	ON dea.location = vac.location
    AND dea.date = vac.date 
GROUP BY dea.location, dea.median_age, vac.median_age
HAVING dea.location IN ("China","Canada","United States","United Kingdom","Sweden")
ORDER BY dea.median_age DESC;


-- Looking at age groups for covid deaths
SELECT 
	CASE
    WHEN median_age BETWEEN 15 AND 20 THEN "15-20"
    WHEN median_age BETWEEN 21 AND 25 THEN "21-25"
    WHEN median_age BETWEEN 26 AND 30 THEN "26-30"
	WHEN median_age BETWEEN 31 AND 35 THEN "31-35"
	WHEN median_age BETWEEN 36 AND 40 THEN "36-40"
	WHEN median_age BETWEEN 41 AND 50 THEN "41-50"
END AS Age_range,
SUM(new_deaths) as Total_deaths
FROM covid_deaths
GROUP BY age_range
HAVING age_range IS NOT NULL
ORDER BY age_range ASC;

-- Looking at rolling total over age groups for covid deaths
WITH rolling_totals AS
(
SELECT 
	CASE
    WHEN median_age BETWEEN 15 AND 20 THEN "15-20"
    WHEN median_age BETWEEN 21 AND 25 THEN "21-25"
    WHEN median_age BETWEEN 26 AND 30 THEN "26-30"
	WHEN median_age BETWEEN 31 AND 35 THEN "31-35"
	WHEN median_age BETWEEN 36 AND 40 THEN "36-40"
	WHEN median_age BETWEEN 41 AND 50 THEN "41-50"
END AS Age_range,
SUM(new_deaths) as Total_deaths
FROM covid_deaths
GROUP BY age_range
HAVING age_range IS NOT NULL 
)
SELECT Age_range, Total_deaths, SUM(Total_deaths) OVER(ORDER BY Age_range, Total_deaths) AS Rolling_total
FROM rolling_totals;

















