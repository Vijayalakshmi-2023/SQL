CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(100)
);

CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(200),
    genre VARCHAR(50),
    artist_id INT,
    duration INT, -- in seconds
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE listeners (
    listener_id INT PRIMARY KEY,
    listener_name VARCHAR(100)
);

CREATE TABLE plays (
    play_id INT PRIMARY KEY,
    song_id INT,
    listener_id INT,
    play_date DATE,
    play_duration INT, -- in seconds
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (listener_id) REFERENCES listeners(listener_id)
);
SELECT song_id, COUNT(*) AS total_plays
FROM plays
GROUP BY song_id;
SELECT s.genre, AVG(p.play_duration) AS avg_play_duration
FROM plays p
JOIN songs s ON p.song_id = s.song_id
GROUP BY s.genre;
SELECT s.artist_id, a.artist_name, COUNT(p.play_id) AS total_song_plays
FROM plays p
JOIN songs s ON p.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
GROUP BY s.artist_id, a.artist_name
HAVING COUNT(p.play_id) > 1000;
SELECT p.play_id, p.play_date, p.play_duration, s.title, s.genre
FROM plays p
INNER JOIN songs s ON p.song_id = s.song_id;
-- PostgreSQL / SQL Server
SELECT l.listener_id, l.listener_name, p.play_id, p.play_date
FROM listeners l
RIGHT JOIN plays p ON l.listener_id = p.listener_id;
SELECT DISTINCT 
    l1.listener_id AS listener1_id, l1.listener_name AS listener1_name,
    l2.listener_id AS listener2_id, l2.listener_name AS listener2_name,
    s1.genre
FROM plays p1
JOIN songs s1 ON p1.song_id = s1.song_id
JOIN listeners l1 ON p1.listener_id = l1.listener_id

JOIN plays p2 ON s1.genre = (SELECT genre FROM songs WHERE song_id = p2.song_id)
JOIN listeners l2 ON p2.listener_id = l2.listener_id

WHERE l1.listener_id <> l2.listener_id
ORDER BY s1.genre, l1.listener_id;
