-- 1. Створення схеми та вибір її за замовчуванням

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

-- 2. Перегляд імпортованих даних
SELECT * FROM infectious_cases;

-- 3. Створення таблиці для унікальних Entity та Code
CREATE TABLE entities (
id INT AUTO_INCREMENT PRIMARY KEY,
entity TEXT,
code TEXT
);

-- 4. Заповнення таблиці entities унікальними значеннями Entity та Code
INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- 5. Перевірка таблиці entities
SELECT * FROM entities;

-- 6. Створення нової таблиці без дублювання Entity та Code, замінюючи їх на унікальний ідентифікатор entity_id
CREATE TABLE infectious_cases_no_entity_code AS
SELECT
  e.id AS entity_id,
  ic.Year,
  ic.Number_yaws,
  ic.polio_cases,
  ic.cases_guinea_worm,
  ic.Number_rabies,
  ic.Number_malaria,
  ic.Number_hiv,
  ic.Number_tuberculosis,
  ic.Number_smallpox,
  ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
  ON ic.Entity = e.entity AND ic.Code = e.code;

-- 7. Перевірка нової таблиці
SELECT * FROM infectious_cases_no_entity_code