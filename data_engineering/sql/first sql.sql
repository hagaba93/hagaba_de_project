# seeing schemas in the catalog
SHOW SCHEMAS IN weather_project;

# INspecting structure of particular Bronze table
DESCRIBE TABLE weather_project.bronze.noaa_weather_raw;

#To preview the records:
SELECT *
FROM weather_project.bronze.noaa_weather_raw
LIMIT 10;

