-- Goodreads Books exploratory project

-- WHAT WILL WE BE SEARCHING FOR?:
-- 1.Average rating by author
-- 2.Average distribution of ratings
-- 3.Number of ratings by book
-- 4.10 most Popular books of all
-- 5.Tendency of rating by series

SELECT *
FROM [dbo].[goodreads_cleaned_processed];

SELECT MAX([average_rating]) max_avg_rting,
AVG([average_rating]) avg_tot_rating,
MIN([average_rating]) min_avg_rting,
AVG([num_ratings]) avg_num_ratings,
SUM([num_ratings]) tot_num_ratings
FROM [dbo].[goodreads_cleaned_processed];




-- 1.Average rating by author
SELECT DISTINCT [authorName]
FROM [dbo].[goodreads_cleaned_processed];

SELECT [authorName], AVG([average_rating]) AS avg_rating
FROM [dbo].[goodreads_cleaned_processed]
WHERE [authorName] IS NOT NULL
AND  [average_rating] IS NOT NULL 
AND  [average_rating] > 0
GROUP BY [authorName]
;

-- 2.Average distribution of ratings X	num of ratings
SELECT [average_rating],[num_ratings] 
FROM [dbo].[goodreads_cleaned_processed]
WHERE [average_rating] IS NOT NULL 
AND  [average_rating] > 0
AND  [num_ratings] IS NOT NULL
AND [num_ratings] > 0
ORDER BY [num_ratings] DESC;

SELECT MAX([average_rating]) AS max_avg_rting,
MIN([average_rating]) AS min_avg_rting
FROM [dbo].[goodreads_cleaned_processed];

-- 3.Number of ratings by book (Most Populars)
SELECT [bookTitle], [num_ratings],[average_rating]
FROM [dbo].[goodreads_cleaned_processed]
WHERE [bookTitle] IS NOT NULL
ORDER BY [num_ratings] DESC; 

-- 4.10 Most Popular books of all
SELECT [bookTitle], [num_ratings],[average_rating]
FROM [dbo].[goodreads_cleaned_processed]
WHERE [bookTitle] IS NOT NULL
AND	[average_rating] IS NOT NULL
AND [num_ratings] IS NOT NULL 
AND  [average_rating] >= 4.5
ORDER BY [num_ratings] DESC;

SELECT MAX([num_ratings])
FROM [dbo].[goodreads_cleaned_processed]

SELECT [bookTitle], [num_ratings],[average_rating]
FROM [dbo].[goodreads_cleaned_processed]
WHERE [bookTitle] IS NOT NULL
AND	[average_rating] IS NOT NULL
AND [num_ratings] IS NOT NULL 
AND  [average_rating] >= 4.5
AND [num_ratings] >= 1000000
ORDER BY [num_ratings] DESC;

-- 5.Tendency of rating by series of books 

SELECT *
FROM [dbo].[goodreads_cleaned_processed]
WHERE [bookTitle] LIKE '%series%' 
AND [bookTitle] LIKE '%-%'
OR [bookTitle] LIKE '%box% set%'
ORDER BY [average_rating] DESC;

SELECT *
FROM [dbo].[goodreads_cleaned_processed]
WHERE [num_ratings] IS NOT NULL
ORDER BY [average_rating] DESC
;
