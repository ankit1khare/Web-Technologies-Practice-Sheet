SQL Assignment
Homework #3
CS 186, Fall 2006
Due: November 9, 11:59 PM

In this assignment, you’ll have to come up with SQL queries for the following database schema:
Artists (artistID: int, name: varchar(255))
SimilarArtists (artistID: int, simArtistID: int, weight: int)
Albums (albumID: int, artistID: int, name: varchar(255))
Tracks (trackID: int, artistID: int, name: varchar(255), length: int)
TrackLists (albumID: int, trackID: int, trackNum: int)

All primary keys are underlined. All foreign keys have the same name as the primary key that they
are referencing. When asking about the similarity of one Artist to another, you can safely assume
that the pair of Artists will only appear in one tuple in the SimilarArtists table. Please write SQL
statements for the following ten queries:

1. Find the names of all Tracks that are more than 10 minutes (600,000 ms) long.
Result: (name: varchar(255))

SELECT NAME
FROM   Tracks
WHERE  Length > 10; 

--2. Find the names of all Artists who have recorded a self-titled Album (the name of the
--Album is the same as the name of the Artist).
SELECT ar.NAME
FROM   Artists ar
       INNER JOIN Albums al
               ON ar.ArtistID = al.ArtistID
WHERE  ar.NAME = al.NAME; 


2. Find the names of all Artists who have recorded a self-titled Album (the name of the
Album is the same as the name of the Artist).
Result: (name: varchar(255))

SELECT ar.NAME
FROM   Artists ar
       INNER JOIN Albums al
               ON ar.ArtistID = al.ArtistID
WHERE  ar.NAME = al.NAME; 

                                           
3. Find the names of all Artists who have recorded an Album on which the first track is named
“Intro”.
Result: (name: varchar(255))


SELECT NAME
FROM   Artists
WHERE  ArtistID IN (SELECT al.ArtistId
                    FROM   Albums al
                           INNER JOIN Tracks tr
                                   ON al.ArtistID = tr.ArtistID
                    WHERE  tr.NAME = 'Intro'
                           AND TrackID IN (SELECT TrackID
                                           FROM   TrackLists
                                           WHERE  TrackNumber = 1)) 
                                           

4. Find the names of all Artists who are more similar to Mogwai than to Nirvana (meaning the
weight of their similarity to Mogwai is greater).
Result: (name: varchar(255))

DECLARE @Mogvai INT;
DECLARE @Nirvana INT;

SET @Mogvai = (SELECT TOP 1 ArtistID
               FROM   Artists
               WHERE  NAME = 'Mogvai');
SET @Nirvana = (SELECT TOP 1 ArtistID
                FROM   Artists
                WHERE  NAME = 'Nirvana');

SELECT NAME AS Artist_Name
FROM   Artists
WHERE  ArtistID IN (SELECT a.ArtistID
                    FROM   SimilarArtists a
                           LEFT JOIN SimilarArtists b
                                  ON a.ArtistID = b.ArtistID
                    WHERE  a.SimArtistID = @Mogvai
                           AND b.SimArtistID = @Nirvana
                           AND a.Weight > b.Weight); 
                           
                           
5. Find the names of all Albums that have more than 30 tracks.
Result: (name: varchar(255))

SELECT NAME
FROM   Albums
WHERE  AlbumID IN (SELECT AlbumID
                   FROM   TrackLists
                   GROUP  BY AlbumID
                   HAVING Count(AlbumID) > 3) 
                   
                   
6. Find the names of all Artists who do not have a similarity rating greater than 5 to any other
Artist.
Result: (name: varchar(255))

SELECT NAME
FROM   Artists
WHERE  ArtistID IN (SELECT ArtistID
                    FROM   SimilarArtists
                    WHERE  Weight > 5); 
                    
                    
7. For all Albums, list the Album’s name and the name of its 15th Track. If the Album does
not have a 15th Track, list the Track name as null.
Result: (album_name: varchar(255), track_name: varchar(255))

SELECT a.AlbumID,
       b.TrackID,
       a.NAME,
       b.TrackNumber
INTO   #temp
FROM   Albums a
       LEFT JOIN TrackLists b
              ON a.AlbumID = b.AlbumID
WHERE  TrackNumber = 5;

--select * from #temp
SELECT a.NAME,
       b.TrackNumber
FROM   Albums a
       LEFT JOIN #temp b
              ON a.AlbumID = b.AlbumID

DROP TABLE #temp 


8. List the name of each Artist, along with the name and average Track length of their Album
that has the highest average Track length.
Result: (artist_name: varchar(255), album_name: varchar(255), avg_track_length: float)

SELECT a.ArtistID,
       Avg(b.Length) AS Average,
       a.NAME
INTO   #tmp
FROM   Artists a
       LEFT JOIN Tracks b
              ON a.ArtistID = b.ArtistID
GROUP  BY a.ArtistID,
          a.NAME;

SELECT *
FROM   #tmp

SELECT NAME
FROM   #tmp
WHERE  Average = (SELECT Max(Average)
                  FROM   #tmp);

DROP TABLE #tmp; 


9. For all Artists that have released a Track with a name beginning with “The”, give their
name and the name of the Artist who is most similar to them that has released a Track with
a name beginning with “Why”. If there is a tie, choose the Artist with the lowest artistID.
If there are no qualifying Artists, list the Artist name as null.
Result: (artist_name_the: varchar(255), artist_name_why: varchar(255))

SELECT ArtistID,
       SimArtistID,
       Weight
INTO   #temp
FROM   SimilarArtists
WHERE  ArtistID IN (SELECT a.ArtistID
                    FROM   Artists a
                           JOIN Tracks b
                             ON a.ArtistID = b.ArtistID
                    WHERE  b.NAME LIKE 'The%')

SELECT NAME AS Artist_Name
FROM   Artists
WHERE  ArtistID = (SELECT Min (b.ArtistID)
                   FROM   Tracks a
                          JOIN #temp b
                            ON a.ArtistID = b.SimArtistID
                   WHERE  a.NAME LIKE 'Why%')

DROP TABLE #temp 


10. If an Artist is within one degree of Hot Water Music, that means that their similarity to Hot
Water Music is at least 5. If an Artist is within N degrees of Hot Water Music, then they
have a similarity of at least 5 to an Artist that is within N-1 degrees of Hot Water Music.
Find the percent of all Artists that are within 6 (or fewer) degrees of Hot Water Music.
(Your answer should also include Hot Water Music themselves! Also, note that the
percentage should be an integer between 0 and 100, inclusive.)
Result: (percentage: int)

After going through the above problems this one should come easily :)

