# PolicyFlow — Fault-Tolerant Insurance Issuance Engine

PolicyFlow is a Laravel REST API that manages travel insurance policy requests, calculates premiums, simulates insurer submission, and processes insurer callbacks. It includes duplicate request protection and prevents repeated callbacks from changing an already issued policy.

## Tech Stack

- PHP 8.2+
- Laravel 12
- MySQL 8+ for normal local development
- SQLite in-memory database for automated tests
- PHPUnit / Laravel feature tests

## Features

- Create and validate policy requests.
- Calculate premiums based on plan, age, destination, trip duration, and sum insured.
- Prevent duplicate logical requests using `agent_id` and `client_request_id`.
- Simulate submission to a mock insurer.
- Process issued and failed insurer callbacks.
- Ignore callbacks that arrive after a policy has already been issued.
- Retry submission for eligible failed requests.
- List requests with pagination and optional status or agent filters.
- Return appropriate validation and not-found errors.

## Requirements

- PHP 8.2 or newer
- Composer
- MySQL 8+ for the configured local database, or another supported database configured for Laravel

## Setup

1. Clone the repository and enter the project directory.
2. Install PHP dependencies:

   ```bash
   composer install
   ```

3. Create your environment file:

   ```bash
   cp .env.example .env
   ```

   On Windows, you can copy `.env.example` to `.env` using File Explorer or PowerShell.

4. Generate the application key:

   ```bash
   php artisan key:generate
   ```

5. Configure the database credentials in `.env` and create the database.
6. Run migrations:

   ```bash
   php artisan migrate
   ```

7. Start the Laravel development server:

   ```bash
   php artisan serve
   ```

The API will normally be available at `http://127.0.0.1:8000`.

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/policy-requests` | Create a policy request and calculate its premium |
| GET | `/api/policy-requests` | List requests with pagination and optional filters |
| GET | `/api/policy-requests/{id}` | Retrieve one request |
| POST | `/api/policy-requests/{id}/submit` | Submit a request to the mock insurer |
| POST | `/api/mock-insurer/callback` | Process an insurer callback |

### Create a Policy Request

Example JSON body:

```json
{
  "client_request_id": "REQ001",
  "agent_id": "AGENT001",
  "customer_name": "Test Customer",
  "date_of_birth": "1995-01-01",
  "destination": "INTERNATIONAL",
  "trip_start": "2026-11-01",
  "trip_end": "2026-11-05",
  "plan_code": "PLUS",
  "sum_insured": 300000
}
```

A successful new request returns HTTP `201` and a request record with status `VALIDATED` and its calculated premium. A repeated request with the same agent and client request ID returns the existing record instead of creating another one.

### Submit to the Mock Insurer

```http
POST /api/policy-requests/1/submit
```

A successful submission moves the request through `SUBMITTED` to `PENDING_CONFIRMATION` and assigns a mock provider reference.

### Simulate an Issued Callback

```http
POST /api/mock-insurer/callback
Content-Type: application/json
```

```json
{
  "provider_reference": "MOCK-1",
  "status": "ISSUED",
  "policy_number": "POL-2026-0001"
}
```

For a failed callback, send `status` as `FAILED` with the matching `provider_reference`.

### List and Filter Requests

```http
GET /api/policy-requests?status=ISSUED&per_page=5
```

You can filter by `status` or `agent_id`. The `per_page` parameter controls pagination.

## Premium Calculation

The premium is calculated as:

`Base rate × trip days × age multiplier × destination multiplier × sum insured multiplier`

Trip days include both the start and end dates.

### Base Rates

| Plan | Rate per day |
|---|---:|
| BASIC | ₹12 |
| PLUS | ₹20 |
| PREMIUM | ₹30 |

### Age Multipliers

| Age at trip start | Multiplier |
|---|---:|
| 0–17 | 1.10 |
| 18–60 | 1.00 |
| 61–70 | 1.50 |
| 71+ | 2.00 |

### Destination Multipliers

| Destination | Multiplier |
|---|---:|
| DOMESTIC | 1.00 |
| INTERNATIONAL | 1.80 |

### Sum Insured Multipliers

| Sum insured | Multiplier |
|---|---:|
| ₹100,000 | 1.00 |
| ₹300,000 | 1.25 |
| ₹500,000 | 1.50 |

Example: PLUS plan, five days, international destination, age 18–60, and ₹300,000 sum insured:

`20 × 5 × 1.00 × 1.80 × 1.25 = ₹225.00`

## Statuses

- `RECEIVED`
- `VALIDATED`
- `SUBMITTED`
- `PENDING_CONFIRMATION`
- `ISSUED`
- `FAILED`
- `NEEDS_RECONCILIATION`

## Reliability and Error Handling

- A unique database constraint prevents duplicate requests for the same agent and client request ID.
- Repeated intake returns the existing request.
- Submission