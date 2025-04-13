/*
Praktikum-1 [19/03/2025]

Razi Rachman Widyadhana - 13523004
Muhammad Zahran Ramadan - 13523104

Operasi Dasar SQL
*/


-- Query 1

SELECT M.title, MC.character_name, MCR.job, P.person_name
FROM movie M, movie_cast MC, movie_crew MCR, person P
WHERE M.movie_id = MC.movie_id 
AND M.movie_id = MCR.movie_id 
AND MC.person_id = MCR.person_id 
AND MC.person_id = P.person_id


-- Query 2

SELECT M.title, M.vote_average
FROM movie M, movie_cast MC, person P
WHERE M.movie_id = MC.movie_id
AND MC.person_id = P.person_id
AND M.vote_average > 7
AND P.person_name = "Channing Tatum";


-- Query 3

(SELECT DISTINCT M.title
FROM movie M, movie_genres MG, genre G
WHERE M.movie_id = MG.movie_id
AND G.genre_id = MG.genre_id
AND G.genre_name = "Comedy")

INTERSECT

(SELECT DISTINCT M.title
FROM movie M, movie_genres MG, genre G
WHERE M.movie_id = MG.movie_id
AND G.genre_id = MG.genre_id
AND G.genre_name = "Romance"); 


-- Query 4

(SELECT M.movie_id, M.title
FROM movie M, production_country PC, country C
WHERE M.movie_id = PC.movie_id
AND PC.country_id = C.country_id
AND C.country_name = "United States of America"
AND M.vote_average > 8
AND M.vote_count > 1000)

UNION

(SELECT M.movie_id, M.title
FROM movie M, production_country PC, country C
WHERE M.movie_id = PC.movie_id
AND PC.country_id = C.country_id
AND C.country_name = "France"
AND M.vote_average < 5
AND M.vote_count > 100);


-- Query 5

(SELECT M.movie_id, M.title
FROM movie M, production_country PC, country C 
WHERE M.movie_id = PC.movie_id
AND PC.country_id = C.country_id
AND C.country_name != "Canada")

INTERSECT

(SELECT M.movie_id, M.title
FROM movie M
WHERE M.vote_average > 8);


-- Query 6

(SELECT M.title, M.runtime, M.budget
FROM movie M, movie_keywords MK, keyword K
WHERE M.runtime > 90
AND M.movie_id = MK.movie_id
AND MK.keyword_id = K.keyword_id
AND keyword_name LIKE "%food%"
AND M.budget > 1000000)

UNION

(SELECT M.title, M.runtime, M.budget
FROM movie M, movie_cast MC, person P
WHERE M.runtime > 90
AND M.movie_id = MC.movie_id
AND MC.person_id = P.person_id
AND (P.person_name = "Lebron James"
OR P.person_name = "Kanye West")); 


-- Query 7

(SELECT P.person_id, P.person_name
FROM movie M, movie_crew MC, person P
WHERE (M.tagline LIKE "%family%" OR M.tagline LIKE "%love%")
AND M.movie_id = MC.movie_id
AND MC.job = "Producer"
AND MC.person_id = P.person_id)

EXCEPT

(SELECT P.person_id, P.person_name
FROM movie M, movie_crew MC, person P, movie_genres MG, genre G
WHERE M.movie_id = MG.movie_id
AND MG.genre_id = G.genre_id
AND (G.genre_name = "Horror" OR M.tagline LIKE "%fear%")
AND M.movie_id = MC.movie_id
AND MC.job = "Producer"
AND MC.person_id = P.person_id);


-- Query 8

SELECT M.movie_id, M.title, M.release_date, M.vote_average,
L.language_name, L1.language_role, L2.language_role 
FROM movie M, movie_languages ML1, movie_languages ML2,
language L, language_role L1, language_role L2
WHERE MOD(M.movie_id, 2)
AND M.release_date < "2000-01-01"
AND M.vote_average > 7
AND M.movie_id = ML1.movie_id
AND M.movie_id = ML2.movie_id
AND ML1.language_id = L.language_id
AND ML2.language_id = L.language_id
AND L.language_code != "en"
AND ML1.language_role_id = L1.role_id
AND ML2.language_role_id = L2.role_id
AND L1.language_role = "Original"
AND L2.language_role = "Spoken"
AND L1.language_role != L2.language_role; 