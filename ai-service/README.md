# Optional AI service

Python/FastAPI service for assisted grievance classification.

Initial endpoint proposal:
- POST `/v1/classify`

Input should contain only the minimum necessary grievance text and approved context.

Output should include:
- suggested category ID
- suggested department ID, if supported
- confidence score
- short explanation
- model/version identifier

The service provides suggestions only. Backend policy and authorized human review control final decisions.

If AI is unavailable, the grievance workflow must continue without AI.
Do not use this service to automatically reject or close grievances.
