# AI Usage Disclosure

## Purpose

AI assistance was used during development of PolicyFlow, a fault-tolerant insurance policy issuance and reconciliation engine.

## Areas Where AI Assistance Was Used

AI assistance helped with:

- Understanding the assignment requirements and planning the API endpoints.
- Drafting and reviewing Laravel controller, model, and premium calculation code.
- Understanding request validation, duplicate request prevention, and policy status transitions.
- Developing automated feature tests for policy creation, premium calculation, invalid input, duplicate requests, and repeated insurer callbacks.
- Troubleshooting Laravel configuration and API testing issues.
- Preparing project documentation and test commands.

## Developer Verification

The generated and suggested code was incorporated into the project and tested locally. The automated test suite passed during development.

AI-generated suggestions were reviewed and adapted as needed. Further verification is required for scenarios not covered by the current tests, including uncertain insurer outcomes, retry behavior, and reconciliation.

## Limitations

PolicyFlow uses a mock insurer and does not connect to a real insurance provider. The project is a demonstration of policy issuance workflow and reliability handling, not a production-ready insurance platform.