-- creating database
create database HCA_Project;

-- 1) creating date column
alter table maindata
add flight_date date;
update maindata
set flight_date = str_to_date(
                  concat(`year`,'-',LPAD(`month (#)`,2,'0'),'-',LPAD(`day`,2,'0')),
                  '%Y-%m-%d'
);

-- creating view for date related fields
CREATE VIEW flights_date_fields AS
SELECT
  flight_date,

  /* A. Year */
  YEAR(flight_date) AS year,

  /* B. Month No */
  MONTH(flight_date) AS month_no,

  /* C. Month Full Name */
  MONTHNAME(flight_date) AS month_fullname,

  /* D. Quarter (Q1–Q4) */
  CONCAT('Q', QUARTER(flight_date)) AS quarter,

  /* E. Year-Month (YYYY-MMM) */
  DATE_FORMAT(flight_date, '%Y-%b') AS `year_month`,

  /* F. Weekday No (1=Sunday … 7=Saturday) */
  DAYOFWEEK(flight_date) AS weekday_no,

  /* G. Weekday Name */
  DAYNAME(flight_date) AS weekday_name,

  /* H. Financial Month (Apr=1 … Mar=12) */
  CASE
    WHEN MONTH(flight_date) >= 4 THEN MONTH(flight_date) - 3
    ELSE MONTH(flight_date) + 9
  END AS financial_month,

  /* I. Financial Quarter (India: Apr–Mar) */
  CASE
    WHEN MONTH(flight_date) BETWEEN 4 AND 6 THEN 'FQ1'
    WHEN MONTH(flight_date) BETWEEN 7 AND 9 THEN 'FQ2'
    WHEN MONTH(flight_date) BETWEEN 10 AND 12 THEN 'FQ3'
    ELSE 'FQ4'
  END AS financial_quarter

FROM maindata;

/* 2. YEARLY LOAD FACTOR
   Calculates overall load factor for each year*/
  SELECT
    YEAR(flight_date) AS year,
    ROUND(
        SUM(`# Transported Passengers`) / SUM(`# available seats`) * 100,
        2
    ) AS load_factor_percentage
FROM maindata
GROUP BY YEAR(flight_date)
ORDER BY year;

/* 3. CARRIER-WISE LOAD FACTOR
   Measures efficiency of each airline carrier*/
   SELECT
    `carrier name`,
    ROUND(
        SUM(`# transported passengers`) / SUM(`# available seats`) * 100,
        2
    ) AS load_factor_percentage_By_Carriername
FROM maindata
GROUP BY `Carrier Name`
ORDER BY load_factor_percentage_By_Carriername DESC;

/* 4. TOP 10 CARRIERS BY PASSENGER COUNT
   Identifies most preferred airlines by passengers*/
 SELECT
    `carrier name`,
    SUM(`# transported passengers`) AS total_passengers
FROM maindata
GROUP BY `carrier name`
ORDER BY total_passengers DESC
LIMIT 10;  

/* 5. TOP ROUTES BY NUMBER OF FLIGHTS
   Finds busiest routes based on flight frequency */
 SELECT
    `origin city`,
    `destination city`,
    COUNT(*) AS number_of_flights
FROM maindata
GROUP BY `origin city`,`destination city`
ORDER BY number_of_flights DESC;
-- OR
   SELECT
    `from - to city`,
    COUNT(*) AS number_of_flights
FROM maindata
GROUP BY `from - to city`
ORDER BY number_of_flights DESC;

/* 7. WEEKEND VS WEEKDAY LOAD FACTOR
   Compares passenger occupancy on weekends vs weekdays */
   SELECT
    CASE
        WHEN DAYOFWEEK(flight_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(
        SUM(`# transported passengers`) / SUM(`# available seats`) * 100,
        2
    ) AS load_factor_percentage
FROM maindata
GROUP BY day_type;

/* 7. FLIGHTS BY DISTANCE GROUP
   Analyzes number of flights across distance categories */
 SELECT
    `%distance group id` as distance_group,
    COUNT(*) AS total_flights
FROM maindata
GROUP BY `%distance group id`
ORDER BY `%distance group id`;
