-----------------------------------------------------------------------
--  LeetCode 1225. Report Contiguous Dates
--
--  Hard
--
--  SQL Schema
--
--  Table: Failed
--  +--------------+---------+
--  | Column Name  | Type    |
--  +--------------+---------+
--  | fail_date    | date    |
--  +--------------+---------+
--  Primary key for this table is fail_date.
--  Failed table contains the days of failed tasks.
--
--  Table: Succeeded
--  +--------------+---------+
--  | Column Name  | Type    |
--  +--------------+---------+
--  | success_date | date    |
--  +--------------+---------+
--  Primary key for this table is success_date.
--  Succeeded table contains the days of succeeded tasks.
-- 
--  A system is running one task every day. Every task is independent of the 
--  previous tasks. The tasks can fail or succeed.
--  Write an SQL query to generate a report of period_state for each 
--  continuous interval of days in the period from 2019-01-01 to 2019-12-31.
--  period_state is 'failed' if tasks in this interval failed or 'succeeded' 
--  if tasks in this interval succeeded. Interval of days are retrieved as 
--  start_date and end_date.
--
--  Order result by start_date.
--  The query result format is in the following example:
--
--  Failed table:
--  +-------------------+
--  | fail_date         |
--  +-------------------+
--  | 2018-12-28        |
--  | 2018-12-29        |
--  | 2019-01-04        |
--  | 2019-01-05        |
--  +-------------------+
--
--  Succeeded table:
--  +-------------------+
--  | success_date      |
--  +-------------------+
--  | 2018-12-30        |
--  | 2018-12-31        |
--  | 2019-01-01        |
--  | 2019-01-02        |
--  | 2019-01-03        |
--  | 2019-01-06        |
--  +-------------------+
--
--  Result table:
--  +--------------+--------------+--------------+
--  | period_state | start_date   | end_date     |
--  +--------------+--------------+--------------+
--  | succeeded    | 2019-01-01   | 2019-01-03   |
--  | failed       | 2019-01-04   | 2019-01-05   |
--  | succeeded    | 2019-01-06   | 2019-01-06   |
--  +--------------+--------------+--------------+
--  
--  The report ignored the system state in 2018 as we care about the system 
--  in the period 2019-01-01 to 2019-12-31.
--  From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state 
--  was "succeeded".
--  From 2019-01-04 to 2019-01-05 all tasks failed and system state 
--  was "failed".
--  From 2019-01-06 to 2019-01-06 all tasks succeeded and system state 
--  was "succeeded".
----------------------------------------------------------------
/* Write your T-SQL query statement below */
WITH 
Task_CTE ([date], [state], row_id)  
AS  
(  
    SELECT
        [date],
        [state],
        ROW_NUMBER() OVER (ORDER BY [date]) AS row_id
    FROM
    (   
        SELECT
            fail_date AS [date],
            'failed' AS [state]
        FROM 
            Failed
        UNION ALL
        SELECT
            success_date AS [date],
            'succeeded' AS [state]
        FROM
            Succeeded
    ) AS A
    WHERE [date] >= '2019-01-01' AND [date] <= '2019-12-31'
),

Compare_CTE ([date], [state], prev_state, next_state)
AS
(
    SELECT
        A.[date],
        A.[state],
        B.[state] AS prev_state,
        C.[state] AS next_state
    FROM Task_CTE AS A
    LEFT OUTER JOIN Task_CTE AS B 
    ON A.row_id - 1= B.row_id
    LEFT OUTER JOIN Task_CTE AS C 
    ON A.row_id + 1= C.row_id
    WHERE ((A.[state] != B.[state]) OR (B.[state] IS NULL)) OR 
          ((A.[state] != C.[state]) OR (C.[state] IS NULL))
),
Period_CTE(row_id, [date], [state])
AS
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY [date]) AS row_id,
        [date],
        [state]
    FROM
    (   
        SELECT 
            [date], 
            [state]
        FROM Compare_CTE
        WHERE
            (([state] != [prev_state]) OR ([prev_state] IS NULL))
        UNION ALL
        SELECT 
            [date], 
            [state]
        FROM Compare_CTE
        WHERE
            (([state] != [next_state]) OR ([next_state] IS NULL))
    ) AS T
)
SELECT 
    A.[state] AS period_state,
    A.[date] AS start_date,
    B.[date] AS end_date
FROM 
    Period_CTE AS A
INNER JOIN 
    Period_CTE AS B
ON 
    A.row_id + 1 = B.row_id
WHERE 
    A.row_id %2 = 1
;
