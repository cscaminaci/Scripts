Select
 (Select Count(*) from Users where uanswer1 <> '' ) as [With]
 ,(Select Count(*) from Users where uanswer1 is null or uanswer1 = '' ) as [Without]
