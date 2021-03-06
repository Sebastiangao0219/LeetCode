-----------------------------------------------------------------------
-- 	LeetCode 574. Winning Candidate
--
--  Medium
--
--  SQL Schema
--
--  Table: Candidate
--
--  +-----+---------+
--  | id  | Name    |
--  +-----+---------+
--  | 1   | A       |
--  | 2   | B       |
--  | 3   | C       |
--  | 4   | D       |
--  | 5   | E       |
--  +-----+---------+  
--
--  Table: Vote
--
--  +-----+--------------+
--  | id  | CandidateId  |
--  +-----+--------------+
--  | 1   |     2        |
--  | 2   |     4        |
--  | 3   |     3        |
--  | 4   |     2        |
--  | 5   |     5        |
--  +-----+--------------+
--  id is the auto-increment primary key,
--  CandidateId is the id appeared in Candidate table.
--  Write a sql to find the name of the winning candidate, the above example 
--  will return the winner B.
--
--  +------+
--  | Name |
--  +------+
--  | B    |
--  +------+
--
--  Notes:
-- 
--  You may assume there is no tie, in other words there will be only one 
--  winning candidate.
--------------------------------------------------------------------
SELECT
    Name
FROM
(	
	SELECT
		A.CandidateId,
		B.Name,
		ROW_NUMBER() OVER (ORDER BY A.VoteCount DESC) AS Rank
	FROM
	(
        SELECT 
            CandidateId,
            COUNT(*) AS VoteCount
        FROM
            Vote AS A        
        GROUP BY A.CandidateId
	) AS A
    INNER JOIN
        Candidate B
    ON 
        A.CandidateId = B.id
) AS T
WHERE Rank = 1
;
