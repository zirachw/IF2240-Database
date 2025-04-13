/*
Praktikum-2 [19/03/2025]

Razi Rachman Widyadhana - 13523004

Operasi SQL Lanjut
*/


-- Query 1

SELECT M.title, M.popularity
FROM movie M
LEFT JOIN movie_keywords MK USING (movie_id)
WHERE popularity < YEAR(release_date) * 0.00001
AND MK.keyword_id IS NULL;


-- Query 2

SELECT P.person_name, COUNT(DISTINCT M.movie_id) AS film_count
FROM movie M
JOIN movie_crew MC_Writer USING (movie_id)
JOIN person P USING (person_id)
JOIN department D_Writer USING (department_id)
JOIN movie_crew MCR_Director USING (movie_id)
JOIN person P_Director USING (person_id)
JOIN department D_Director USING (department_id)
JOIN movie_company MCO USING (movie_id)
JOIN production_company PC USING (company_id)
WHERE D_Writer.department_name = 'Writing'
AND D_Director.department_name = 'Directing'
AND P_Director.person_name = 'Anthony Russo'
AND PC.company_name = 'Marvel Studios'
AND M.revenue > 300000000
GROUP BY P.person_name
HAVING COUNT(DISTINCT M.movie_id) > 1
ORDER BY film_count DESC;


-- Query 3

SELECT language_name, language_role, AVG(vote_average) as average_vote, AVG(revenue/budget) as avg_profit
FROM movie M
NATURAL JOIN movie_languages ML
NATURAL JOIN language L
NATURAL JOIN language_role LR
WHERE (revenue / budget > 1.998) OR language_name IN 
      (SELECT language_name
       FROM movie M
       NATURAL JOIN movie_languages ML
       NATURAL JOIN language L
       GROUP BY language_name
       HAVING AVG(revenue/budget) > 20.45)
GROUP BY language_name, language_role
ORDER BY average_vote DESC;


-- Query 4

SELECT M.movie_id, C.country_name, M.vote_average, P.person_name
FROM movie M
JOIN movie_cast mc USING (movie_id)
JOIN person P USING (person_id)
JOIN production_country PC USING (movie_id)
JOIN country C USING (country_id)
WHERE M.vote_average BETWEEN 7.2 AND 7.5
AND C.country_name != 'United States of America'
AND M.movie_id IN (
    SELECT M.movie_id
    FROM movie M
    JOIN movie_cast MCA1 ON M.movie_id = MCA1.movie_id
    JOIN gender G1 ON MCA1.gender_id = G1.gender_id
    WHERE G1.gender = 'Female'
    GROUP BY M.movie_id
    HAVING COUNT(*) > (
        SELECT COUNT(*) 
        FROM movie_cast MCA2
        JOIN gender G2 ON MCA2.gender_id = G2.gender_id
        WHERE MCA2.movie_id = M.movie_id
        AND G2.gender = 'Male'
    )
)
AND C.country_id IN (
    SELECT PC.country_id
    FROM movie M
    JOIN production_country PC ON M.movie_id = PC.movie_id
    GROUP BY PC.country_id
    HAVING AVG(M.revenue) > AVG(M.budget)
)
ORDER BY M.vote_average DESC;


-- Query 5

SELECT DISTINCT P.person_name
FROM person P
JOIN movie_cast mc USING (person_id)
JOIN movie M USING (movie_id)
JOIN movie_genres MG USING (movie_id)
JOIN genre G USING (genre_id)
WHERE G.genre_name = 'Documentary'
AND NOT EXISTS (
    SELECT 1 
    FROM movie_cast MCA2
    JOIN movie M2 USING (movie_id)
    JOIN movie_genres MG2 USING (movie_id)
    JOIN genre G2 USING (genre_id)
    WHERE MCA2.person_id = P.person_id
    AND G2.genre_name != 'Documentary'
)
AND EXISTS (
    SELECT 1
    FROM movie M3
    JOIN movie_cast MCA3 USING (movie_id)
    WHERE MCA3.person_id = P.person_id
    AND EXISTS (
        SELECT COUNT(DISTINCT PC.country_id)
        FROM production_country PC
        WHERE PC.movie_id = M3.movie_id
        GROUP BY PC.movie_id
        HAVING COUNT(DISTINCT PC.country_id) = 1
    )
)
AND EXISTS (
    SELECT 1
    FROM movie M4
    JOIN movie_cast MC4 USING (movie_id)
    JOIN movie_languages ML USING (movie_id)
    WHERE MC4.person_id = P.person_id
    GROUP BY M4.movie_id
    HAVING COUNT(DISTINCT ML.language_id) > 1
);


-- Query 6

WITH slavery_films AS (
    SELECT M.movie_id, M.title, YEAR(M.release_date) AS release_year, 
           M.vote_average, COUNT(DISTINCT PC.country_id) AS country_count
    FROM movie M
    JOIN movie_keywords MK USING (movie_id)
    JOIN keyword K USING (keyword_id)
    JOIN production_country PC USING (movie_id)
    WHERE K.keyword_name LIKE '%slavery%'
    GROUP BY M.movie_id, M.title, M.release_date, M.vote_average
    HAVING COUNT(DISTINCT PC.country_id) >= 2
),
avg_rating AS (
    SELECT AVG(vote_average) AS avg_vote
    FROM slavery_films
)
SELECT SF.title, SF.release_year, SF.vote_average,
       GROUP_CONCAT(C.country_name SEPARATOR ', ') AS production_countries
FROM slavery_films SF
JOIN production_country PC USING (movie_id)
JOIN country C USING (country_id)
WHERE SF.vote_average > (SELECT avg_vote FROM avg_rating)
GROUP BY SF.movie_id, SF.title, SF.release_year, SF.vote_average
ORDER BY SF.vote_average DESC;


-- Query 7

CREATE TABLE award_category (
    award_category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255)
);

CREATE TABLE movie_awards (
    award_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    person_id INT,
    award_category_id INT NOT NULL,
    award_year YEAR NOT NULL,
    won BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    FOREIGN KEY (person_id) REFERENCES person(person_id),
    FOREIGN KEY (award_category_id) REFERENCES award_category(award_category_id)
);


-- Query 8

UPDATE movie M
JOIN movie_crew mc USING (movie_id)
JOIN person P USING (person_id)
JOIN department D USING (department_id)
JOIN movie_genres MG USING (movie_id)
JOIN genre G USING (genre_id)
JOIN movie_company MCO USING (movie_id)
JOIN production_company PC USING (company_id)
JOIN movie_languages ML USING (movie_id)
SET M.budget = M.budget * 0.8
WHERE P.person_name = 'Hans Zimmer'
AND D.department_name = 'Sound'
AND G.genre_name = 'Action'
AND M.runtime > 120
AND (
    SELECT COUNT(DISTINCT movie_id)
    FROM movie_company
    WHERE company_id = PC.company_id
) <= 5
AND (
    SELECT COUNT(DISTINCT M2.movie_id)
    FROM movie M2
    JOIN movie_languages ml2 USING (movie_id)
    WHERE ml2.language_id = ML.language_id
) < 50;


-- Query 9

DELETE FROM movie_crew
WHERE movie_id IN (
    SELECT M.movie_id
    FROM movie M
    JOIN movie_genres MG USING (movie_id)
    JOIN genre G USING (genre_id)
    JOIN movie_company MCO USING (movie_id)
    JOIN production_company PC USING (company_id)
    WHERE M.vote_average < 6.0
    AND PC.company_name NOT LIKE '%Indie%'
    AND G.genre_name IN ('Thriller', 'Crime')
)
AND (job = 'Director' OR department_id IN (
    SELECT department_id
    FROM department
    WHERE department_name = 'Writing'
));


-- Query 10

INSERT INTO movie (title, vote_average, budget, homepage, overview, popularity, 
                  release_date, revenue, runtime, movie_status, tagline, vote_count)
VALUES ('Praktikum 2', 10, 1000000, 'https://lab-basdat-jahat.com', 
       'Praktikum dikasih bom mantab', 150, '2025-04-12', 
       5000000, 120, 'Released', '#asistenjahat', 500);

-- Insert new actors (option B)
INSERT INTO person (person_name) VALUES ('rzi');
INSERT INTO person (person_name) VALUES ('zirach');

-- Insert into movie_cast (using subqueries directly)
INSERT INTO movie_cast (movie_id, person_id, character_name, gender_id, cast_order)
VALUES ((SELECT movie_id FROM movie WHERE title = 'Praktikum 2'), 
        (SELECT person_id FROM person WHERE person_name = 'rzi'), 
        'Database Expert', 1, 1);

INSERT INTO movie_cast (movie_id, person_id, character_name, gender_id, cast_order)
VALUES ((SELECT movie_id FROM movie WHERE title = 'Praktikum 2'), 
        (SELECT person_id FROM person WHERE person_name = 'zirach'), 
        'SQL Master', 1, 2);