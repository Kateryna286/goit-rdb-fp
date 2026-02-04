-- П.1.1 Створення схеми та вибір її за замовчуванням

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

-- П.1.2 Перегляд імпортованих даних
SELECT * FROM infectious_cases;

-- П.1.3 Створення таблиці для унікальних Entity та Code
CREATE TABLE entities (
id INT AUTO_INCREMENT PRIMARY KEY,
entity TEXT,
code TEXT
);

-- П.1.4 Заповнення таблиці entities унікальними значеннями Entity та Code
INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- П.1.5 Перевірка таблиці entities
SELECT * FROM entities;

-- П.1.6 Створення нової таблиці без дублювання Entity та Code, замінюючи їх на унікальний ідентифікатор entity_id
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

-- П.1.7 Перевірка нової таблиці
SELECT * FROM infectious_cases_no_entity_code;

-- П.2.1 Підрахунок кількості записів у таблиці infectious_cases_no_entity_code
SELECT COUNT(*) FROM infectious_cases_no_entity_code;

-- П.2.2 Створення таблиці diseases для унікальних назв хвороб
CREATE TABLE diseases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) NOT NULL UNIQUE
);

-- П.2.3 Заповнення таблиці diseases

INSERT INTO diseases (name) VALUES
	('yaws'),
	('polio'),
	('guinea_worm'),
	('rabies'),
	('malaria'),
	('hiv'),
	('tuberculosis'),
	('smallpox'),
	('cholera');

-- П.2.4 Перевірка таблиці diseases

SELECT * FROM diseases;

-- П.2.5 Створення таблиці infectious_cases_normalized з нормалізованою структурою
CREATE TABLE infectious_cases_normalized (
  id INT AUTO_INCREMENT PRIMARY KEY,
  entity_id INT NOT NULL,
  year INT NOT NULL,
  disease_id INT NOT NULL,
  cases TEXT,
  FOREIGN KEY (entity_id) REFERENCES entities(id),
  FOREIGN KEY (disease_id) REFERENCES diseases(id)
);

-- П.2.6 Заповнення таблиці infectious_cases_normalized
INSERT INTO infectious_cases_normalized (entity_id, year, disease_id, cases)

SELECT entity_id, Year, d.id, Number_yaws
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'yaws'

UNION ALL
SELECT entity_id, Year, d.id, polio_cases
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'polio'

UNION ALL
SELECT entity_id, Year, d.id, cases_guinea_worm
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'guinea_worm'

UNION ALL
SELECT entity_id, Year, d.id, Number_rabies
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'rabies'

UNION ALL
SELECT entity_id, Year, d.id, Number_malaria
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'malaria'

UNION ALL
SELECT entity_id, Year, d.id, Number_hiv
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'hiv'

UNION ALL
SELECT entity_id, Year, d.id, Number_tuberculosis
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'tuberculosis'

UNION ALL
SELECT entity_id, Year, d.id, Number_smallpox
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'smallpox'

UNION ALL
SELECT entity_id, Year, d.id, Number_cholera_cases
FROM infectious_cases_no_entity_code ic
JOIN diseases d ON d.name = 'cholera';

-- П.2.7 Перевірка таблиці infectious_cases_normalized
SELECT * FROM infectious_cases_normalized;

-- П.3 Аналіз даних по rabies
SELECT
  e.id AS entity_id,
  e.entity,
  e.code,
  AVG(CONVERT(icn.cases, DECIMAL(10,2))) AS avg_rabies,
  MIN(CONVERT(icn.cases, DECIMAL(10,2))) AS min_rabies,
  MAX(CONVERT(icn.cases, DECIMAL(10,2))) AS max_rabies,
  SUM(CONVERT(icn.cases, DECIMAL(10,2))) AS sum_rabies
FROM infectious_cases_normalized icn
JOIN diseases d ON icn.disease_id = d.id
JOIN entities e ON icn.entity_id = e.id
WHERE d.name = 'rabies'
  AND icn.cases <> ''
GROUP BY e.id, e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- П.4 Побудова колонок з датою та різницею в роках
SELECT
  year,
  MAKEDATE(year, 1) AS year_start_date,
  CURDATE() AS today_date,
  TIMESTAMPDIFF(
    YEAR,
    MAKEDATE(year, 1),
    CURDATE()
  ) AS years_difference
FROM infectious_cases_normalized;