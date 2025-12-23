-- Group01_query.sql
-- Queries for Assignment 1 (Chinook Database)
-- Group Number: 01

-- Below are the set of commands needed to be run to connect the database to PostgreSQL.
-- Quit
-- \q 
-- psql -U postgres
-- DROP DATABASE chinook;
-- psql -U postgres -d chinook -encoding=WIN1252 -f Chinook_PostgreSql.sql > "output.txt"
-- CREATE DATABASE chinook;
-- \c chinook
-- \i Chinook_PostgreSql.sql
-- \dt
-- SELECT * FROM Artist LIMIT 5;
-- psql -U postgres -d chinook -f "C:\Users\rmuku\Personal\IITH\Semester 3\CS3550 - DBMS 1\Assignments\Assignment 1\Group01_query.sql"
-- psql -U postgres -d chinook -f "C:\Users\rmuku\Personal\IITH\Semester 3\CS3550 - DBMS 1\Assignments\Assignment 1\Group01_query.sql" > "C:\Users\rmuku\Personal\IITH\Semester 3\CS3550 - DBMS 1\Assignments\Assignment 1\Group01_output.txt"

-- Q1: Find the manager(s) to whom the most number of employees report to. Print such managers’ id, name and the total number of employees that report to them.
-- SELECT reports_to, COUNT(employee_id) AS num_reports FROM Employee GROUP BY reports_to;

SELECT 'Q1: Find the manager(s) to whom the most number of employees report to. Print such managers’ id, name and the total number of employees that report to them.' AS "Question 1";
DROP VIEW IF EXISTS max_reporting;
DROP VIEW IF EXISTS reporting;
CREATE VIEW reporting AS (SELECT reports_to, COUNT(employee_id) AS num_reports FROM Employee GROUP BY reports_to);
CREATE VIEW max_reporting AS (SELECT r.reports_to, r.num_reports FROM reporting as r WHERE r.num_reports = (SELECT MAX(num_reports) FROM reporting));
SELECT R.reports_to as Manager_Id, E.first_name || ' ' || E.last_name as Manager_name, R.num_reports FROM max_reporting as R, employee as E WHERE R.reports_to = E.employee_id;

-- Q2: Find the customer(s) who have purchased the maximum number of tracks. Print their id, name and total number of tracks they have purchased.
-- SELECT C.Customer_Id, C.First_Name, C.Last_Name, T.Track_Id FROM Customer C, Invoice I, Invoice_Line IL, Track T WHERE C.Customer_Id = I.Customer_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND C.Customer_Id = 32;
-- DROP VIEW cust_track;
-- CREATE VIEW cust_track AS (SELECT C.Customer_Id, C.First_Name, C.Last_Name, COUNT(T.Track_Id) as num_tracks FROM Customer C, Invoice I, Invoice_Line IL, Track T WHERE C.Customer_Id = I.Customer_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id GROUP BY C.Customer_Id, C.First_Name, C.Last_Name);
-- SELECT C.Customer_Id, C.First_Name || ' ' || C.Last_Name as Customer_Name, num_tracks FROM cust_track as C WHERE num_tracks = (SELECT MAX(num_tracks) FROM cust_track);

SELECT 'Q2: Find the customer(s) who have purchased the maximum number of tracks. Print their id, name and total number of tracks they have purchased.' AS "Question 2";
SELECT Customer_Id, First_Name || ' ' || Last_Name AS Customer_Name, num_tracks FROM (SELECT C.Customer_Id as Customer_Id, C.First_Name as First_Name, C.Last_Name as Last_Name, COUNT(T.Track_Id) as num_tracks FROM Customer C, Invoice I, Invoice_Line IL, Track T WHERE C.Customer_Id = I.Customer_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id GROUP BY C.Customer_Id, C.First_Name, C.Last_Name) AS cust_track WHERE num_tracks = (SELECT MAX(num_tracks) FROM cust_track);

-- Q3: Find countries that have the highest average invoice total. Print country name and average invoice total.

SELECT 'Q3: Find countries that have the highest average invoice total. Print country name and average invoice total.' AS "Question 3";
DROP VIEW IF EXISTS Avg_Calc;
CREATE VIEW Avg_Calc AS (SELECT Billing_Country AS Country, AVG(Total) AS Average FROM Invoice GROUP BY Billing_Country);
SELECT Country, Average as Average_Invoice_Total FROM Avg_Calc WHERE Average = (SELECT MAX(Average) FROM Avg_Calc);

-- Q4: Find the total sales per genre. Print the genre and total sales in descending order of total sales values.

SELECT 'Q4: Find the total sales per genre. Print the genre and total sales in descending order of total sales values.' AS "Question 4";
SELECT G.Name as Genre, SUM(Total) as Total_Sales FROM Genre G, Track T, Invoice_Line IL, Invoice I WHERE G.Genre_Id = T.Genre_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id GROUP BY G.Name ORDER BY Total_Sales DESC;

-- Q5: Find the genre that has the max number of tracks. Print the genre and the number of tracks.

SELECT 'Q5: Find the genre that has the max number of tracks. Print the genre and the number of tracks.' AS "Question 5";
DROP VIEW IF EXISTS view_temp;
DROP VIEW IF EXISTS popular;
DROP VIEW IF EXISTS count_tracks;
CREATE VIEW count_tracks AS (SELECT G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM Genre G, Track T WHERE G.Genre_Id = T.Genre_Id GROUP BY G.Name);
CREATE VIEW popular AS (SELECT Genre as Genre, num_tracks as Max_num_of_tracks FROM count_tracks WHERE num_tracks = (SELECT MAX(num_tracks) FROM count_tracks));
SELECT * FROM popular;

-- Q6: Find the top-3 genres that are purchased most by customers from ‘USA’. Print the genres and count of tracks purchased for the top-3 genres.
SELECT 'Q6: Find the top-3 genres that are purchased most by customers from ‘USA’. Print the genres and count of tracks purchased for the top-3 genres.' AS "Question 6";
DROP VIEW IF EXISTS popular;
DROP VIEW IF EXISTS count_tracks;
CREATE VIEW count_tracks AS (SELECT G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM Genre G, Track T WHERE G.Genre_Id = T.Genre_Id GROUP BY G.Name);
CREATE VIEW popular AS (SELECT Genre as Genre, num_tracks as Max_num_of_tracks FROM count_tracks WHERE num_tracks = (SELECT MAX(num_tracks) FROM count_tracks));
SELECT G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM Genre G, Track T, Invoice_Line IL, Invoice I, Customer C WHERE G.Genre_Id = T.Genre_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND C.Customer_Id = I.Customer_Id AND C.Country = 'USA' GROUP BY G.Name ORDER BY num_tracks DESC LIMIT 3;

-- Q7: Find the count of customers who never bought tracks from the most popular genre.
-- SELECT C.Customer_Id, G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM popular P, Genre G, Track T, Invoice_Line IL, Invoice I, Customer C WHERE G.Genre_Id = T.Genre_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND C.Customer_Id = I.Customer_Id GROUP BY C.Customer_Id, G.Name ORDER BY C.Customer_Id DESC;
-- SELECT C.Customer_Id, G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM popular P, Genre G, Track T, Invoice_Line IL, Invoice I, Customer C WHERE G.Genre_Id = T.Genre_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND C.Customer_Id = I.Customer_Id AND G.Name <> P.Genre GROUP BY C.Customer_Id, G.Name ORDER BY C.Customer_Id DESC;

SELECT 'Q7: Find the count of customers who never bought tracks from the most popular genre.' AS "Question 7";
DROP VIEW IF EXISTS popular;
DROP VIEW IF EXISTS count_tracks;
CREATE VIEW count_tracks AS (SELECT G.Name as Genre, COUNT(T.Track_Id) as num_tracks FROM Genre G, Track T WHERE G.Genre_Id = T.Genre_Id GROUP BY G.Name);
CREATE VIEW popular AS (SELECT Genre as Genre, num_tracks as Max_num_of_tracks FROM count_tracks WHERE num_tracks = (SELECT MAX(num_tracks) FROM count_tracks));
CREATE VIEW view_temp AS (SELECT DISTINCT C.Customer_Id AS C_Id, G.Name AS Genre, COUNT(T.Track_Id) as num_tracks FROM popular P, Genre G, Track T, Invoice_Line IL, Invoice I, Customer C WHERE G.Genre_Id = T.Genre_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND C.Customer_Id = I.Customer_Id AND G.Name = P.Genre GROUP BY C.Customer_Id, G.Name);
SELECT COUNT(*) FROM (SELECT DISTINCT Customer_Id FROM Customer C) EXCEPT (SELECT DISTINCT C_Id FROM view_temp);

-- Q8: Find the count of tracks that are in more than 5 playlists.
-- SELECT Track_Id, COUNT(Playlist_Id) as count FROM Playlist_Track GROUP BY Track_Id ORDER BY count DESC;

SELECT 'Q8: Find the count of tracks that are in more than 5 playlists.' AS "Question 8";
SELECT COUNT(Playlist_Id) AS count_of_tracks FROM Playlist_Track GROUP BY Track_Id HAVING COUNT(Playlist_Id) > 5;

-- Q9: Find the number of tracks that appear in at least one playlist but were purchased fewer than 5 times in total.

SELECT 'Q9: Find the number of tracks that appear in at least one playlist but were purchased fewer than 5 times in total.' AS "Question 9";
--DROP VIEW IF EXISTS tracks_In_Play_List;
--CREATE VIEW tracks_In_Play_List AS (SELECT T.track_id AS track_id, COUNT(il.playlist_id) AS count_playlist FROM Track T, Playlist_Track pt GROUP BY T.track_id);
--SELECT COUNT(*) AS count_of_tracks FROM (SELECT tPL.track_id, COUNT(Invoice_Line_Id) AS countInvoiceLine FROM tracks_In_Play_List tPL, Invoice_Line Il WHERE tPL.track_id = Il.track_id GROUP BY tPL.track_id HAVING COUNT(Invoice_Line_Id) < 5);

SELECT COUNT(*) AS count_of_tracks FROM ((SELECT DISTINCT PT.Track_Id, COUNT(DISTINCT T.Track_Id) FROM Playlist_Track as PT, Track as T GROUP BY PT.Track_Id) EXCEPT (SELECT DISTINCT PT.Track_Id, COUNT(IL.Invoice_Line_Id) FROM Playlist_Track as PT, Invoice_Line IL WHERE PT.Track_Id = IL.Track_Id GROUP BY PT.Track_Id HAVING COUNT(IL.Invoice_Line_Id) >= 5));

--SELECT COUNT(*) AS count_of_tracks FROM (SELECT DISTINCT PT.Track_Id, COUNT(IL.Invoice_Line_Id) FROM Playlist_Track as PT, Invoice_Line IL WHERE PT.Track_Id = IL.Track_Id GROUP BY PT.Track_Id HAVING COUNT(IL.Invoice_Line_Id) < 5) UNION;

-- Q10: Find the count of customers who bought every genre at least once.

SELECT 'Q10: Find the count of customers who bought every genre at least once.' AS "Question 10";
DROP VIEW IF EXISTS genres;
CREATE VIEW genres AS (SELECT DISTINCT C.Customer_Id, COUNT(DISTINCT G.Genre_Id) as count_genre FROM Customer C, Invoice I, Invoice_Line IL, Track T, Genre G WHERE C.Customer_Id = I.Customer_Id AND I.Invoice_Id = IL.Invoice_Id AND IL.Track_Id = T.Track_Id AND T.Genre_Id = G.Genre_Id GROUP BY C.Customer_Id);
SELECT COUNT(genres.Customer_Id) FROM genres, genre WHERE genres.count_genre = (SELECT DISTINCT COUNT(*) FROM Genre as Genre_Count);
