select
Aareadesc as [Client],
IHPeriodStartDate as [Start Date],
IHPeriodEndDate as [End Date],
IHDueDateInt as [Due],
IHDueDateType as [Due Date Type],
IHReference as [Reference],
IHNotes_1 as [Note],
IHInternalNote as [Internal Note]


from invoiceheader

join area on IHaarea=aarea
