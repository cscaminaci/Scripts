# PagerDuty Integration for HaloPSA (TechPulse)

This repository contains a custom integration for HaloPSA, designed to send events to PagerDuty. This integration offers more flexibility than the built-in PagerDuty integration and can be triggered from both events and actions in HaloPSA.

## Features

- Customizable payload to match specific needs.
- Can be triggered by events or actions in HaloPSA.
- Includes detailed ticket information in the alerts sent to PagerDuty.

## Integration Details

### Integration Configuration

```json
{
  "id": null,
  "guid": null,
  "name": "PagerDuty (TechPulse)",
  "module_id": 0,
  "authorizationtype": 0,
  "granttype": 0,
  "client_id": "",
  "username": "",
  "headerprefix": "",
  "algorithm": 0,
  "bearername": "Bearer",
  "bearerlocation": 0,
  "resourcebaseurl": "",
  "certificate_name": "",
  "library_licence_name": "",
  "major_version_number": 0,
  "minor_version_number": 0,
  "patch_version_number": 0,
  "version_number": "4.20.69",
  "methods": [
    {
      "id": null,
      "guid": null,
      "integration_id": null,
      "integration_name": null,
      "integration_baseurl": "",
      "name": "Send PagerDuty Alert (TechPulse)",
      "full_name": null,
      "resource": "https://events.pagerduty.com",
      "path": "/v2/enqueue",
      "method": 1,
      "authorizationtype": -1,
      "requesttype": 1,
      "responsetype": 0,
      "requestbody": "{\r\n  \"payload\": {\r\n    \"summary\": \"<<ticket^id!>>:<<ticket^user_name!>> | <<ticket^client_name!>> | <<ticket^summary!>>\",\r\n    \"source\": \"HaloPSA\",\r\n    \"severity\": \"critical\",\r\n    \"custom_details\": {\r\n      \"Ticket Details\": \"<<ticket^details!>>\",\r\n      \"Date Logged\": \"<<ticket^dateoccurred!>>\",\r\n      \"Client\": \"<<ticket^client_name!>>\",\r\n      \"Site\": \"<<ticket^site_name!>>\",\r\n      \"Ticket ID\": \"<<ticket^id!>>\",\r\n      \"User Name:\": \"<<ticket^user_name!>>\"\r\n    }\r\n  },\r\n  \"routing_key\": \"YOUR_PAGERDUTY_ROUTING_KEY\",\r\n  \"dedup_key\": \"<<ticket^id!>>\",\r\n  \"images\": [],\r\n  \"links\": [\r\n    {\r\n      \"href\": \"https://YOUR.HALOPSA.URL/tickets?id=<<ticket^id!>>\",\r\n      \"text\": \"Link to Ticket #<<ticket^id!>>\"\r\n    }\r\n  ],\r\n  \"event_action\": \"trigger\"\r\n}",
      "uri_params": [],
      "headers": [],
      "body_mappings": [],
      "output_variables": []
    }
  ],
  "access_control": null
}
```

### Method Details

#### Send PagerDuty Alert (TechPulse)

- **Resource URL**: `https://events.pagerduty.com`
- **Path**: `/v2/enqueue`
- **Method**: POST
- **Request Type**: JSON
- **Response Type**: JSON

**Request Body Example**:

```json
{
  "payload": {
    "summary": "<<ticket^id!>>:<<ticket^user_name!>> | <<ticket^client_name!>> | <<ticket^summary!>>",
    "source": "HaloPSA",
    "severity": "critical",
    "custom_details": {
      "Ticket Details": "<<ticket^details!>>",
      "Date Logged": "<<ticket^dateoccurred!>>",
      "Client": "<<ticket^client_name!>>",
      "Site": "<<ticket^site_name!>>",
      "Ticket ID": "<<ticket^id!>>",
      "User Name:": "<<ticket^user_name!>>"
    }
  },
  "routing_key": "YOUR_PAGERDUTY_ROUTING_KEY",
  "dedup_key": "<<ticket^id!>>",
  "images": [],
  "links": [
    {
      "href": "https://YOUR.HALOPSA.URL/tickets?id=<<ticket^id!>>",
      "text": "Link to Ticket #<<ticket^id!>>"
    }
  ],
  "event_action": "trigger"
}
```

### Setup Instructions

1. **Update Configuration**:
    - Replace `YOUR_PAGERDUTY_ROUTING_KEY` with your actual PagerDuty routing key.
    - Replace `https://YOUR.HALOPSA.URL` with your actual HaloPSA URL.

2. **Import Integration into HaloPSA**:
    - Navigate to your HaloPSA instance.
    - Go to Integrations -> Custom Integrations -> New -> and import the provided configuration.

3. **Trigger Integration**:
    - Use the new method "Send PagerDuty Alert (TechPulse)" within your HaloPSA workflows or actions.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

---