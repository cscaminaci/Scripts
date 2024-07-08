# PagerDuty to HaloPSA Integration Runbook (TechPulse)

This repository contains a custom integration runbook for HaloPSA, designed to listen for webhooks from PagerDuty and trigger actions within HaloPSA. This setup allows you to add custom buttons to the PagerDuty mobile app, enabling quick and seamless actions in HaloPSA when these buttons are clicked.

## Features

- Receive webhooks from PagerDuty and trigger specific actions in HaloPSA.
- Customize actions based on the data received from PagerDuty.
- Integrate directly with PagerDuty mobile app buttons for quick response.

### Step Details

#### Step 1: Send to Benchmark

- **Type**: Start Step
- **Actions**:
  - **Successful**: Triggers step 2 if action is successful.
  - **Unsuccessful**: Triggers step 3 if action is unsuccessful.
- **Message Template**:
  ```json
  {
    "ticket_id": <<AlertKey>>,
    "outcome": "Assign to Benchmark (On Call)",
    "outcome_id": 86,
    "who": "On-Call Engineer",
    "hiddenfromuser": true,
    "note_html": "Sent to Benchmark 365 via Pagerduty by On-Call engineer.",
    "emailtemplate_id": -112,
    "sendemail": true,
    "emailto": "example@yourhelpdesk.com",
    "emailtonew": "example@yourhelpdesk.com",
    "report_attach_pdf": true,
    "includeallattachments": true,
    "utcoffset": 0,
    "dont_do_rules": true,
    "action_showpreview": false,
    "from_mailbox_id": 0
  }
  ```

#### Step 2: Step 2

- **Type**: End Step
- **Actions**: None

#### Step 3: Step 3

- **Type**: End Step
- **Actions**: None

### Input Variables

- **AlertKey**: Mapped to `request^messages[0]^incident^alerts[0]^alert_key`

## Setup Instructions

1. **Update Configuration**:
    - Replace the example email addresses with your actual helpdesk email addresses.
    - Ensure the `AlertKey` mapping matches the structure of your PagerDuty alerts.

2. **Import Runbook into HaloPSA**:
    - Navigate to your HaloPSA instance.
    - Go to Integrations -> Custom Integrations -> Integration Runbooks and import the provided configuration.

3. **Configure PagerDuty**:
    - Add custom buttons to the PagerDuty mobile app.
    - Configure the buttons to send webhooks to the HaloPSA endpoint configured in the runbook.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

---
