# DATA_APP_TECH_STACK

## 1. APPLICABILITY

**Target Profile:** Applications designed for data ingestion, analysis, web dashboards, search tools, and semi-realtime feeds. Target user base is under 1,000 users.

**Agent Instruction:** Apply this stack when the requested application requires asynchronous data processing, scheduled background jobs, vector search, LLM integrations, or a decoupled frontend-backend architecture.

**Examples of Applicable Apps:**
* Internal data analytics dashboards.
* Document processing and semantic search tools.
* Automated data feed aggregators with LLM-generated insights.
* Long-running report generators.

**Core System Components Required:**
* **Frontend:** Single Page Application (SPA) for dashboards.
* **Authentication:** Managed identity provider.
* **API Layer:** Asynchronous web server handling routing and validation.
* **Worker Layer:** Background process for heavy tasks (ingestion, LLM calls).
* **Broker:** In-memory store to pass messages between API and Worker.
* **Database:** Relational store with vector embedding support.
* **Storage:** Blob storage for raw files or user uploads.
* **Observability:** Error tracking for pipeline failures.

---

## 2. TECHSTACK

### Frontend
* **ReactJS** (https://react.dev/)
  * *Component:* Client Web App
  * *Purpose:* Builds the SPA. Handles state management and API data fetching.
* **ShadCN** (https://ui.shadcn.com/)
  * *Component:* UI Component Library
  * *Purpose:* Provides accessible, customizable UI components without heavy dependencies.

### Authentication
* **Clerk** (https://clerk.com/)
  * *Component:* Auth Provider
  * *Purpose:* Manages user sign-ups, logins, and session tokens. Secures frontend routes and passes JWTs to the backend.

### Backend API
* **FastAPI** (https://fastapi.tiangolo.com/)
  * *Component:* API Server
  * *Purpose:* Serves async REST endpoints and WebSockets.
* **Pydantic** (https://docs.pydantic.dev/)
  * *Component:* Data Validator
  * *Purpose:* Enforces strict data types for incoming API requests and outgoing responses.

### Background Processing
* **TaskIQ** (https://taskiq-python.github.io/)
  * *Component:* Async Task Worker & Scheduler
  * *Purpose:* Executes long-running tasks (API polling, data parsing) outside the web request cycle. Supports native async Python.
* **Redis** (https://redis.io/)
  * *Component:* Message Broker
  * *Purpose:* Queues tasks from FastAPI and delivers them to TaskIQ.

### Data Storage
* **Neon DB / pgvector** (https://neon.tech/) or **SQLite** (https://www.sqlite.org/)
  * *Component:* Relational & Vector Database
  * *Purpose:* Stores structured app data and vector embeddings for search.
* **AWS S3** (https://aws.amazon.com/s3/)
  * *Component:* Object Storage
  * *Purpose:* Stores unstructured files, images, or raw data dumps.

### Observability
* **Sentry** (https://sentry.io/)
  * *Component:* Error Tracking
  * *Purpose:* Captures backend crashes and frontend exceptions automatically.

---

## 3. DEFAULTS (Infrastructure)

This infrastructure exists outside the app codebase. Agents should assume these services are available for deployment and routing.

* **Hosting Environment:** Hetzner VM
* **Deployment Manager:** Coolify (Handles Docker container builds, networking, and SSL generation)
* **Version Control:** GitHub
* **DNS Management:** Namecheap
* **LLM Provider:** GCP Gemini (via API)

---

## 4. DESIGN CONSIDERATIONS TO TEMPLATIZE

To ensure consistent AI code generation, you should define standard templates for the following areas:

* **Repository Structure:** Specify a Monorepo (frontend and backend in one repo) or Polyrepo. A Monorepo is highly likely easier for AI to manage whole-stack changes.
* **Local Development Environment:** Create a standard `docker-compose.yml` that runs Redis and a local Postgres/SQLite instance so the agent knows how to test locally.
* **Environment Variable Management:** Define a strict `.env.example` format. Separate public keys (e.g., `VITE_CLERK_PUBLISHABLE_KEY`) from secret backend keys.
* **API Contract Pattern:** Standardize how the frontend calls the backend. Using Axios instances with interceptors to automatically attach Clerk tokens is a probable strong pattern.
* **LLM Prompt Management:** Standardize a module in the backend for storing, versioning, and formatting system prompts for the Gemini API.