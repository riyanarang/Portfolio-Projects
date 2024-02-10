## **Covid-19 Analysis**

This project highlights the impact of COVID-19 across different locations the world.

### Overview

Extracted fundamental data points like total cases, deaths, new cases, new deaths etc. and sorted them by factors like location date or population. 

### Death Percentage (India)

Closely determined the percentage of population which contracted Covid overtime and percentage of people died after getting covid in India.
This helps gauge the extent of the virus's spread in the population.

### Countries with highest infection rate

Identified countries across the world with maximum number of people infected due to Covid. A metric that helps in undertanding the widespread of the virus.

### A code snippet 
```
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
```

### Visualization
Visulalizing data points in Tableau for clear insights.
https://public.tableau.com/app/profile/riya6616/viz/CovidDashboard_17075672210190/Dashboard1?publish=yes
![Dashboard 1](https://github.com/riyanarang/Portfolio-Projects/assets/150442301/e701f523-6c30-46cb-8547-6f093228c328)

