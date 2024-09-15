select aareadesc as 'Area',
case 
when Aimageindex = 0 then 'Yellow'
when Aimageindex = 1 then 'Green'
when Aimageindex = 2 then 'Orange'
when Aimageindex = 3 then 'Blue'
when Aimageindex = 4 then 'Red'
when Aimageindex = 5 then 'Purple'
else 'Pink' end as 'Colour'
 from area


