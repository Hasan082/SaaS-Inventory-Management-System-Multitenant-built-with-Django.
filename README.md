# SaaS Inventory Management System (Multitenant) - Django

## Running with Docker

This project includes Docker and Docker Compose configuration for easy setup and development.

- **Python version:** 3.11 (as specified in the Dockerfile)
- **Database:** PostgreSQL (configured via Docker Compose)

### Services and Ports
- **python-app** (Django): exposed on port `8000`
- **postgres** (PostgreSQL): exposed on port `5432`

### Environment Variables
- The PostgreSQL service uses the following environment variables (set in `docker-compose.yml`):
  - `POSTGRES_DB=saas_inventory`
  - `POSTGRES_USER=saas_user`
  - `POSTGRES_PASSWORD=saas_password`
- No additional environment variables are required by default for the Django app. If you need to add any, you can use an `.env` file and uncomment the `env_file` line in the compose file.

### Build and Run
1. Ensure Docker and Docker Compose are installed.
2. From the project root, build and start the services:
   ```sh
   docker compose up --build
   ```
3. Access the Django development server at [http://localhost:8000](http://localhost:8000).

### Notes
- The Django app runs as a non-root user for security.
- The default command runs the Django development server. For production, override the command as needed.
- PostgreSQL data is persisted in the `postgres_data` Docker volume.
