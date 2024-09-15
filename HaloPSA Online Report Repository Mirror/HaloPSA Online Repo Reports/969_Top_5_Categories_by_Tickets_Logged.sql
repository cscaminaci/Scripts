select top 5 * from
(select CDCategoryName as [Category]
      , (select count(*) from faults where category2=CDCategoryName and dateoccured>=@startdate and dateoccured<@enddate) as [Tickets]
from categorydetail
)z
order by [Tickets] desc
