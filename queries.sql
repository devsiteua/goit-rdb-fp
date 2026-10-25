-- Task 1

CREATE SCHEMA pandemic;

USE pandemic;

SELECT COUNT(*) FROM infectious_cases;

SELECT *
FROM infectious_cases
LIMIT 10;


-- Task 2

CREATE TABLE entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code VARCHAR(50)
);

INSERT INTO entities (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

SELECT *
FROM entities
LIMIT 10;

CREATE TABLE infectious_cases_normalized (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    Year INT,
    Number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);


INSERT INTO infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.entity_id,
    i.Year,
    i.Number_yaws,
    i.polio_cases,
    i.cases_guinea_worm,
    i.Number_rabies,
    i.Number_malaria,
    i.Number_hiv,
    i.Number_tuberculosis,
    i.Number_smallpox,
    i.Number_cholera_cases
FROM infectious_cases AS i
INNER JOIN entities AS e
    ON i.Entity = e.Entity
    AND COALESCE(i.Code, '') = COALESCE(e.Code, '');

SELECT COUNT(*) AS normalized_rows
FROM infectious_cases_normalized;

SELECT
    i.case_id,
    e.Entity,
    e.Code,
    i.Year,
    i.Number_rabies
FROM infectious_cases_normalized AS i
INNER JOIN entities AS e
    ON i.entity_id = e.entity_id
ORDER BY i.case_id
LIMIT 10;

SELECT
    e.Entity,
    e.Code,
    i.Year,
    i.Number_rabies
FROM infectious_cases_normalized AS i
INNER JOIN entities AS e
    ON i.entity_id = e.entity_id
WHERE i.Number_rabies IS NOT NULL
    AND i.Number_rabies <> ''
ORDER BY i.case_id
LIMIT 10;


-- Task 3

SELECT
    e.Entity,
    e.Code,
    AVG(CAST(i.Number_rabies AS DECIMAL(20, 12))) AS average_rabies,
    MIN(CAST(i.Number_rabies AS DECIMAL(20, 12))) AS min_rabies,
    MAX(CAST(i.Number_rabies AS DECIMAL(20, 12))) AS max_rabies,
    SUM(CAST(i.Number_rabies AS DECIMAL(20, 12))) AS total_rabies
FROM infectious_cases_normalized AS i
INNER JOIN entities AS e
    ON i.entity_id = e.entity_id
WHERE i.Number_rabies IS NOT NULL
    AND i.Number_rabies <> ''
GROUP BY e.entity_id, e.Entity, e.Code
ORDER BY average_rabies DESC
LIMIT 10;


-- Task 4

SELECT
    Year,
    MAKEDATE(Year, 1) AS year_start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS years_difference
FROM infectious_cases_normalized
LIMIT 10;


-- Task 5

DELIMITER //

CREATE FUNCTION CalculateYearDifference(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(input_year, 1),
        CURDATE()
    );
END //

DELIMITER ;

SELECT
    Year,
    CalculateYearDifference(Year) AS years_difference
FROM infectious_cases_normalized
ORDER BY case_id
LIMIT 10;
