SELECT
    faultid AS [Fault ID],
    fadatetime AS [Approval Sent],
    CASE
        WHEN FAResult = 1 THEN 'Approved'
        WHEN FAResult = 2 THEN 'Rejected'
        ELSE 'N/A'
    END AS [Approval State],
    FAemailaddr AS [Approver Email Address],
    FANote AS [Note]
FROM
    faults
JOIN
    FaultApproval ON faultid = faultapproval.FAid

