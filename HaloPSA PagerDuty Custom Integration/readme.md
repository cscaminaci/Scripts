# HaloPSA PagerDuty Integration (TechPulse)

This repository contains two custom integrations for HaloPSA to enhance the interaction with PagerDuty. The integrations are designed to offer more flexibility and functionality than the built-in options, allowing for both sending alerts from HaloPSA to PagerDuty and triggering actions in HaloPSA from PagerDuty.

## Overview

### 1. Outgoing Integration: Send Alerts from HaloPSA to PagerDuty

This integration allows HaloPSA to send detailed alerts to PagerDuty. It can be triggered by events or actions within HaloPSA and provides customizable payloads to match your specific requirements.

- **Integration Name**: PagerDuty (TechPulse)
- **Method**: Send PagerDuty Alert (TechPulse)
- **Endpoint**: `https://events.pagerduty.com/v2/enqueue`
- **Payload**: Contains detailed ticket information including summary, source, severity, and custom details.

For more information, please refer to the [Outgoing Integration README](Outbound%20Integration/readme.md).

### 2. Incoming Integration: Trigger Actions in HaloPSA from PagerDuty

This integration allows HaloPSA to receive webhooks from PagerDuty and trigger specific actions based on the incoming data. It enables custom buttons in the PagerDuty mobile app to quickly perform actions in HaloPSA.

- **Integration Name**: PagerDuty Send to Benchmark (TechPulse)
- **Runbook Type**: Webhook Listener
- **Payload**: Processes incoming alerts from PagerDuty and performs defined actions in HaloPSA.

For more information, please refer to the [Incoming Integration README](Inbound%20Integration/readme.md).

## Repository Structure

```plaintext
.
├── incoming integration
│   └── README.md
├── outgoing integration
│   └── README.md
└── README.md
```

## Setup Instructions

1. **Outgoing Integration Setup**:
    - Follow the instructions in `outbound integration/README.md` to set up the integration for sending alerts from HaloPSA to PagerDuty.

2. **Incoming Integration Setup**:
    - Follow the instructions in `inbound integration/README.md` to set up the runbook for triggering actions in HaloPSA from PagerDuty webhooks.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

---
