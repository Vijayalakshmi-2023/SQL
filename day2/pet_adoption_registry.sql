CREATE TABLE pets (
    pet_id INT PRIMARY KEY,
    name VARCHAR(100),
    species VARCHAR(50),
    breed VARCHAR(100),
    age INT,
    adopted BOOLEAN,           -- TRUE if adopted, FALSE if not
    owner_name VARCHAR(100)
);
SELECT name, breed, species
FROM pets
WHERE adopted = FALSE;
SELECT *
FROM pets
WHERE age BETWEEN 1 AND 5;
SELECT *
FROM pets
WHERE breed LIKE '%shepherd%';
SELECT *
FROM pets
WHERE owner_name IS NULL;
SELECT DISTINCT species
FROM pets;
SELECT *
FROM pets
ORDER BY age ASC, name ASC;
