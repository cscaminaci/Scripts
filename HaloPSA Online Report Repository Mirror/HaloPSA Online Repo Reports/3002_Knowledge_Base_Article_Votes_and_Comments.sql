SELECT
        abstract as 'Title'
      , id
      , (SELECT uusername FROM users WHERE uid = kbvuid) as 'User'
      , CASE WHEN kbvvote < 0 THEN 'Negative'
             WHEN kbvvote > 0 THEN 'Positive'
        END AS 'Vote'
      , kbvdate as 'Date Voted'
      , kbvnegativecomment as 'Comment'
FROM kbvotes
JOIN kbentry on kbvkbid = id
