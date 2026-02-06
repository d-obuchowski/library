# Library Management System

Ruby on Rails API application for managing library books, readers, and borrowings.

## Requirements

* Ruby version: 3.3+
* PostgreSQL 16
* Docker & Docker Compose (for containerized development)

## Setup

### Local Development (without Docker)

```bash
bundle install
rails db:create db:migrate
rails server
```

### Docker Development

```bash
docker-compose up
```

The application will be available at http://localhost:3000

## Database Seeding

The application includes seed data to help you get started quickly. Seeds are automatically loaded when using Docker Compose.

### What's Included in Seeds

The seed data creates:
- 2 sample books with authors and titles
- 1 sample reader
- 2 borrowing records (both books borrowed by the same reader 27-30 days ago)

#### Docker Containers

The application uses three Docker containers, all running in **development environment** (`RAILS_ENV=development`):

- **db** - PostgreSQL 16 database server
  - Port: `5432`
  - Database: `library_development`
  - Includes health checks to ensure database is ready before starting other services
  
- **web** - Rails application server
  - Port: `3000`
  - Environment: `development`
  - Runs the Rails API server with Puma
  - Automatically prepares the database and runs seeds on startup
  - Hot-reloading enabled through volume mounting
  
- **jobs** - Background job processor
  - Environment: `development`
  - Runs Solid Queue worker for processing background jobs
  - Handles scheduled tasks like borrowing reminder emails
  - No exposed ports (internal service only)


### Email Preview (Development Only)

In development mode, emails are not sent but can be previewed in the browser using Letter Opener.

To view sent emails, visit:
```
http://localhost:3000/letter_opener
```

This is useful for testing email notifications such as borrowing reminders without actually sending emails.

## Running Tests

### Local Tests (without Docker)

```bash
bundle exec rspec
```

### Docker Tests

**Important:** When running tests in Docker, you must use the test environment. Use the provided helper script:

```bash
./bin/docker-test
```

Or run directly with RAILS_ENV:

```bash
docker-compose exec web env RAILS_ENV=test bundle exec rspec
```

**Note:** Tests fail when run without the proper RAILS_ENV because the web container runs in development mode by default. The test environment is required to properly configure the test database and disable certain security features like CSRF protection.

## API Documentation

### Base URL

```
http://localhost:3000
```

### API Version

All endpoints are prefixed with `/v1/`

### Books Endpoints

#### 1. List All Books

Get a list of all books in the library.

**Request:**
```http
GET /v1/books
```

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "serial_number": "SN123456",
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "status": "available"
  },
  {
    "id": 2,
    "serial_number": "SN789012",
    "title": "1984",
    "author": "George Orwell",
    "status": "borrowed"
  }
]
```

**Status Values:**
- `available` - Book is available for borrowing
- `borrowed` - Book is currently borrowed

---

#### 2. Get Book Details

Get detailed information about a specific book, including borrowing history.

**Request:**
```http
GET /v1/books/:id
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "serial_number": "SN123456",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "status": "borrowed",
  "borrowings": [
    {
      "borrowed_at": "2026-02-01T10:00:00.000Z",
      "returned_at": null,
      "reader": {
        "full_name": "John Doe",
        "card_number": "CN123456",
        "email": "john.doe@example.com"
      }
    }
  ]
}
```

---

#### 3. Create a New Book

Add a new book to the library system.

**Request:**
```http
POST /v1/books
Content-Type: application/json

{
  "book": {
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald"
  }
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "serial_number": "SN123456",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "status": "available"
}
```

**Validation Errors:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "title": ["can't be blank"],
    "author": ["can't be blank"]
  }
}
```

**Note:** `serial_number` is automatically generated and doesn't need to be provided.

---

#### 4. Borrow a Book

Mark a book as borrowed by a reader. If the reader doesn't exist, they will be created automatically.

**Request:**
```http
PATCH /v1/books/:id/borrow
Content-Type: application/json

{
  "reader": {
    "full_name": "John Doe",
    "email": "john.doe@example.com"
  }
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "serial_number": "SN123456",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "status": "borrowed",
  "borrowings": [
    {
      "borrowed_at": "2026-02-06T10:00:00.000Z",
      "returned_at": null,
      "reader": {
        "full_name": "John Doe",
        "card_number": "CN123456",
        "email": "john.doe@example.com"
      }
    }
  ]
}
```

**Validation Errors:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "full_name": ["can't be blank"],
    "email": ["is invalid"]
  }
}
```

**Business Logic Errors:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "base": ["Book is already borrowed"]
  }
}
```

---

#### 5. Return a Book

Mark a borrowed book as returned (available).

**Request:**
```http
PATCH /v1/books/:id/return
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "serial_number": "SN123456",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "status": "available",
  "borrowings": [
    {
      "borrowed_at": "2026-02-01T10:00:00.000Z",
      "returned_at": "2026-02-06T15:30:00.000Z",
      "reader": {
        "full_name": "John Doe",
        "card_number": "CN123456",
        "email": "john.doe@example.com"
      }
    }
  ]
}
```

**Business Logic Errors:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "base": ["some update error"]
  }
}
```

---

#### 6. Delete a Book

Remove a book from the library system.

**Request:**
```http
DELETE /v1/books/:id
```

**Response:** `204 No Content`

(Empty response body)

---

### Error Responses

#### 404 Not Found

Returned when a book with the specified ID doesn't exist.

```json
{
  "status": 404,
  "error": "Not Found"
}
```

#### 422 Unprocessable Entity

Returned when validation fails or business logic prevents the action.

```json
{
  "errors": {
    "field_name": ["error message"]
  }
}
```

---

### Common Request Headers

```
Content-Type: application/json
Accept: application/json
```

---

### Example cURL Commands

**List all books:**
```bash
curl http://localhost:3000/v1/books
```

**Get book details:**
```bash
curl http://localhost:3000/v1/books/1
```

**Create a book:**
```bash
curl -X POST http://localhost:3000/v1/books \
  -H "Content-Type: application/json" \
  -d '{"book":{"title":"The Great Gatsby","author":"F. Scott Fitzgerald"}}'
```

**Borrow a book:**
```bash
curl -X PATCH http://localhost:3000/v1/books/1/borrow \
  -H "Content-Type: application/json" \
  -d '{"reader":{"full_name":"John Doe","email":"john.doe@example.com"}}'
```

**Return a book:**
```bash
curl -X PATCH http://localhost:3000/v1/books/1/return
```

**Delete a book:**
```bash
curl -X DELETE http://localhost:3000/v1/books/1
```
