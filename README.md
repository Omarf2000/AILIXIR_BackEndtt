# 🧬 AILIXIR BackEnd — AI-Driven Drug Discovery Platform

![Status](https://img.shields.io/badge/Status-Production--Ready-brightgreen?style=flat-square)
![Version](https://img.shields.io/badge/Version-2.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)

**Last Updated:** May 2026 | **Maintainers:** Omar Fadlalla & Team

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Installation & Setup](#installation--setup)
- [Running Services](#running-services)
- [API Documentation](#api-documentation)
- [Environment Variables](#environment-variables)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Production Guide](#production-guide)
- [Contributing](#contributing)

---

## 🎯 Overview

**AILIXIR** is a production-grade, modular backend platform for AI-driven drug discovery and molecular analysis. It combines:

- **Laravel API** (PHP 8.3) - Central orchestration, authentication, and job management
- **3 AI Microservices** (Python FastAPI) - Distributed AI workloads
- **MariaDB** - Persistent storage for application state and results
- **Docker/Compose** - Complete containerization for reproducible deployments

The system implements a complete drug discovery pipeline:
1. Identify disease targets from medical databases
2. Retrieve protein sequences
3. Screen drugs against targets using AI
4. Predict ADMET properties  
5. Search chemical similarity using vector search
6. Aggregate and rank results

**Target Users:** Researchers, pharmaceutical companies, biotech startups integrating AI-driven screening into their workflows.

---

## ✨ Key Features

| Feature | Component | Capability |
|---------|-----------|-----------|
| **ADMET Prediction** | ADMET Service (Port 8002) | 5-property MPNN models for drug properties |
| **Virtual Screening** | Drug Repurposing (Port 8001) | DeepPurpose AI for binding affinity prediction |
| **Chemical Search** | Chemical RAG (Port 5000) | FAISS-IVF search for 1M+ compounds + LLM explanations |
| **Orchestration** | Laravel API (Port 8080) | REST endpoints, job queuing, authentication, result aggregation |
| **Database** | MariaDB (Port 3306) | Job tracking, results storage, user management |
| **Job Queue** | Laravel Queue Worker | Background processing for long-running pipelines |

---

## 🚀 Quick Start

### Option 1: Docker (Recommended - 5 minutes)

**Prerequisites:** Docker & Docker Compose v2, 16GB+ RAM

```bash
# Clone repository
git clone <repo-url> ailixir-backend
cd ailixir-backend

# Build and start all services
docker compose build --parallel
docker compose up -d

# Verify all services are healthy
docker compose ps

# View API documentation
open http://localhost:8080/api/documentation  # or visit in browser
```

**Check service health:**
```bash
curl http://localhost:8080/api/ai-services/health
```

### Option 2: Local Development (Per-service setup)

See detailed setup instructions in [Installation & Setup](#installation--setup) section.

---

## 📐 Architecture

### System-Level Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENTS & EXTERNAL SYSTEMS                   │
│              (Web UI, Mobile Apps, Third-party APIs)                │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ HTTP(S)
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │         LARAVEL ORCHESTRATION API (8080)           │
        │  ┌───────────────────────────────────────────────┐ │
        │  │  Authentication • Validation • Routing        │ │
        │  │  Job Dispatch • Result Aggregation • Logging  │ │
        │  └───────────────────────────────────────────────┘ │
        └────────────────────┬───────────────────────────────┘
                   ┌─────────┼─────────┬─────────────────┐
                   ▼         ▼         ▼                 ▼
            ┌──────────┐ ┌─────────┐ ┌──────────────┐ ┌──────────────┐
            │ QUEUE    │ │ MYSQL   │ │ ADMET        │ │ DRUG REPOSIT │
            │ WORKER   │ │ (3306)  │ │ (8002)       │ │ IONING (8001)│
            │ (async)  │ │         │ │ FastAPI      │ │ FastAPI      │
            └──────────┘ └─────────┘ └──────────────┘ └──────────────┘
                                          ▼
                                    ┌──────────────┐
                                    │ CHEMICAL RAG │
                                    │ (5000)       │
                                    │ FastAPI      │
                                    └──────────────┘
        
        All services run in Docker network 'ailixir' with persistent volumes
```

### Component Responsibilities

| Component | Type | Responsibility |
|-----------|------|-----------------|
| **Laravel API** | PHP 8.3 | Request routing, auth, job orchestration, result aggregation |
| **Queue Worker** | PHP 8.3 | Background job execution, long-running pipelines |
| **MySQL/MariaDB** | Database | Application state, user accounts, job metadata, results |
| **ADMET Service** | FastAPI | MPNN models for property prediction (Absorption, Distribution, Metabolism, Excretion, Toxicity) |
| **Drug Repurposing** | FastAPI | DeepPurpose AI model for drug-target binding affinity prediction |
| **Chemical RAG** | FastAPI | FAISS-IVF semantic search + LLM explanations for chemical compounds |

---

## 📦 Installation & Setup

### Prerequisites

| Requirement | Docker | Local |
|-------------|--------|-------|
| **OS** | Windows/Mac/Linux | Windows/Mac/Linux |
| **Memory** | 16GB+ recommended | 8GB+ (per service varies) |
| **Disk** | 20GB+ for images & data | 30GB+ (models can be large) |
| **Docker** | v24+, Compose v2+ | N/A |
| **PHP** | N/A | 8.2+ with extensions (curl, mbstring, bcmath, json) |
| **Python** | N/A | 3.10+ |
| **Database** | Included | MariaDB 11+ or compatible |

### Docker Setup (Recommended)

#### 1. Initialize Project

```bash
cd ailixir-backend

# Copy and customize environment file
cp docker/laravel.env .env
# Edit .env if needed for local customization

# Build all services in parallel
docker compose build --parallel

# Start all services
docker compose up -d

# Wait 30-60 seconds for services to initialize
docker compose ps
```

#### 2. Verify Services

```bash
# Check container health
docker compose ps

# View logs for any service
docker compose logs -f laravel
docker compose logs -f admet
docker compose logs -f drug-repurposing
docker compose logs -f chemical-rag
docker compose logs -f mysql

# Test API connectivity
curl http://localhost:8080/api/ai-services/health
```

#### 3. Initialize Database (if needed)

```bash
# Run Laravel migrations
docker compose exec laravel php artisan migrate

# Seed sample data (if applicable)
docker compose exec laravel php artisan db:seed
```

### Local Development Setup

#### Laravel (Orchestration API)

```bash
# 1. Install PHP 8.2+ and Composer
# On Windows: Use XAMPP, WAMP, or check https://getcomposer.org/

# 2. Clone and prepare project
cd ailixir-backend
cp docker/laravel.env .env

# 3. Install PHP dependencies
composer install

# 4. Generate application key
php artisan key:generate

# 5. Create/migrate database
# Ensure MySQL/MariaDB is running locally
php artisan migrate

# 6. Start Laravel development server
php artisan serve --host=0.0.0.0 --port=8000
# Access: http://localhost:8000
```

#### ADMET Service (Port 8002)

```bash
# 1. Navigate to service directory
cd ai_apps/ADMIT/admet_inference

# 2. Create Python virtual environment
python -m venv venv

# 3. Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Verify model files exist
ls -la models/*/best_model.ckpt

# 6. Start FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
# Access: http://localhost:8000/docs (API documentation)
```

#### Drug Repurposing Service (Port 8001)

```bash
# 1. Navigate to service directory
cd ai_apps/Drug\ Reporposing

# 2. Create Python virtual environment
python -m venv venv

# 3. Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Start FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
# Access: http://localhost:8000/docs

# For quick setup on Windows:
start.bat

# For quick setup on Mac/Linux:
chmod +x start.sh && ./start.sh
```

#### Chemical RAG Service (Port 5000)

```bash
# 1. Navigate to service directory
cd ai_apps/chemical-rag-system/chemical-rag-system

# 2. Create Python virtual environment
python -m venv venv

# 3. Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Start FastAPI server
# The service auto-detects and initializes FAISS index on first run
uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
# Access: http://localhost:5000/docs

# First run will build the FAISS index (~3-5 minutes for 1M compounds)
```

---

## ▶️ Running Services

### Docker Commands

```bash
# Start all services
docker compose up -d

# View running services
docker compose ps

# View logs for specific service
docker compose logs -f <service-name>
# Services: laravel, queue, mysql, admet, drug-repurposing, chemical-rag

# Stop all services
docker compose down

# Stop and remove volumes (data loss)
docker compose down -v

# Rebuild specific service
docker compose build admet --no-cache
docker compose up -d admet

# Execute command in running container
docker compose exec laravel php artisan tinker
docker compose exec mysql mysql -u ailixir -p ailixir
```

### Service Health Checks

```bash
# Laravel API health
curl http://localhost:8080/api/health

# All AI services health
curl http://localhost:8080/api/ai-services/health

# Individual services
curl http://localhost:8002/health  # ADMET
curl http://localhost:8001/health  # Drug Repurposing
curl http://localhost:5000/health  # Chemical RAG

# Database connectivity (from Laravel container)
docker compose exec laravel php artisan db:ping
```

### Local Development Commands

```bash
# Laravel development server
php artisan serve --host=0.0.0.0

# Run migrations
php artisan migrate

# Queue worker (in separate terminal)
php artisan queue:work

# Python FastAPI with auto-reload
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Jupyter notebook (for ADMET training)
jupyter notebook train_ADMET_model.ipynb
```

---

## 🔌 API Documentation

### Laravel Integration Endpoints

When `AI_INTEGRATION_ROUTES_ENABLED=true`, Laravel provides unified access to AI services:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/health` | API health status |
| `GET` | `/api/ai-services/health` | All AI services status |
| `POST` | `/api/ai-services/test/admet` | Test ADMET prediction |
| `POST` | `/api/ai-services/test/chemical-search` | Test chemical search |
| `GET` | `/api/ai-services/test/drug-repurposing` | Drug Repurposing status |

### API Examples

#### Health Check
```bash
curl http://localhost:8080/api/ai-services/health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-05-29T10:30:00Z",
  "services": {
    "admet": "healthy",
    "drug_repurposing": "healthy",
    "chemical_rag": "healthy",
    "database": "connected"
  }
}
```

#### ADMET Prediction
```bash
curl -X POST http://localhost:8080/api/ai-services/test/admet \
  -H "Content-Type: application/json" \
  -d '{
    "smiles": "c1ccccc1",
    "batch_size": 32
  }'
```

#### Chemical Search
```bash
curl -X POST http://localhost:8080/api/ai-services/test/chemical-search \
  -H "Content-Type: application/json" \
  -d '{
    "query_smiles": "CC(=O)Oc1ccccc1C(=O)O",
    "mode": "retrieval-only",
    "top_k": 10
  }'
```

### Detailed Service Documentation

Each service provides interactive OpenAPI documentation:

- **ADMET API:** http://localhost:8002/docs
- **Drug Repurposing API:** http://localhost:8001/docs
- **Chemical RAG API:** http://localhost:5000/docs
- **Laravel API:** http://localhost:8080/api/documentation

---

## 🔐 Environment Variables

### Laravel Configuration (`docker/laravel.env`)

```ini
# Application
APP_NAME=AILIXIR
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:<your-key-here>
APP_URL=http://localhost:8080

# Logging
LOG_CHANNEL=stderr
LOG_LEVEL=info

# Database (MySQL)
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=ailixir
DB_USERNAME=ailixir
DB_PASSWORD=secret

# Session & Cache
SESSION_DRIVER=database
SESSION_LIFETIME=120
CACHE_STORE=database

# Queue
QUEUE_CONNECTION=database

# AI Service URLs (Docker: service names, Local: localhost:port)
CHEMICAL_AI_URL=http://chemical-rag:5000
ADMET_AI_URL=http://admet:8000
DRUG_REPURPOSING_URL=http://drug-repurposing:8000

# Feature Flags
AI_INTEGRATION_ROUTES_ENABLED=true

# Email (optional)
MAIL_MAILER=log
```

### Local Development `.env` Customization

For local development, override service URLs:

```ini
CHEMICAL_AI_URL=http://localhost:5000
ADMET_AI_URL=http://localhost:8002
DRUG_REPURPOSING_URL=http://localhost:8001
```

### per-Service Environment Notes

- **ADMET:** Auto-detects GPU (CUDA) availability
- **Drug Repurposing:** Logs to stdout with `DEBUG=True` for troubleshooting
- **Chemical RAG:** Auto-detects FAISS index, builds on first run
- **Python Services:** Set `PYTHONUNBUFFERED=1` for real-time logs

---

## 📂 Project Structure

```
ailixir-backend/
├── README.md                          # This file
├── ARCHITECTURE.md                    # Detailed system design & diagrams
├── DOCKER.md                          # Docker-specific documentation
├── DOCKER_FIXES.md                    # Known issues & resolutions
├── docker-compose.yml                 # Service orchestration config
├── Dockerfile                         # Laravel multi-stage image
│
├── app/                               # Laravel application code
│   ├── Http/                          # Controllers, middleware
│   ├── Models/                        # Eloquent models
│   ├── Repositories/                  # Data access layer
│   ├── Services/                      # Business logic
│   ├── Jobs/                          # Queueable jobs
│   └── Traits/                        # Reusable traits
│
├── routes/                            # API routes
│   ├── api.php                        # REST endpoints
│   ├── web.php                        # Web routes
│   └── console.php                    # CLI commands
│
├── config/                            # Laravel configuration
│   ├── app.php
│   ├── auth.php
│   ├── database.php
│   └── services.php
│
├── database/                          # Migrations & seeders
│   ├── migrations/
│   └── seeders/
│
├── docker/                            # Container configurations
│   ├── laravel.env                    # Environment vars for Docker
│   ├── nginx/                         # Nginx config (if used)
│   └── php/                           # PHP config
│
├── storage/                           # File storage (persistent)
│   ├── app/
│   ├── logs/
│   └── framework/
│
├── resources/                         # View templates & assets
│   ├── css/
│   ├── js/
│   └── views/
│
├── public/                            # Web root
│   └── index.php                      # Entry point
│
├── tests/                             # Test suites
│   ├── Feature/
│   └── Unit/
│
├── scripts/                           # Utility scripts
│   ├── fix_complete_system.py
│   ├── md_simulation.py
│   ├── precheck.py
│   ├── smiles_to_pdbqt.py
│   └── vina_docking.py
│
├── ai_apps/                           # Microservices
│   │
│   ├── ADMIT/                         # ADMET Model Training & Inference
│   │   ├── README.md                  # ADMET documentation
│   │   ├── train_ADMET_model.ipynb    # Training notebook
│   │   └── admet_inference/
│   │       ├── Dockerfile            # FastAPI inference service
│   │       ├── app/
│   │       │   ├── main.py            # FastAPI app
│   │       │   ├── config.py
│   │       │   └── models/            # Pretrained models
│   │       └── requirements.txt
│   │
│   ├── Drug Reporposing/              # Drug Repurposing Pipeline
│   │   ├── README.md                  # Detailed docs
│   │   ├── QUICK_START.md             # 60-second setup
│   │   ├── PRODUCTION_GUIDE.md        # Complete guide
│   │   ├── IMPLEMENTATION_SUMMARY.md  # Implementation details
│   │   ├── app/
│   │   │   ├── main.py                # FastAPI app
│   │   │   ├── pipelines/             # 5-stage pipeline
│   │   │   └── models.py
│   │   ├── docker/
│   │   │   └── Dockerfile
│   │   ├── start.sh / start.bat        # Quick setup scripts
│   │   ├── test_api.py
│   │   └── requirements.txt
│   │
│   └── chemical-rag-system/           # Chemical Search & RAG
│       ├── README.md                  # RAG documentation
│       └── chemical-rag-system/
│           ├── Dockerfile            # FastAPI service
│           ├── app/
│           │   ├── main.py            # FastAPI app
│           │   ├── models.py
│           │   └── ingestion.py       # FAISS index builder
│           ├── data/
│           │   ├── compounds.json     # Chemical database
│           │   └── faiss_index        # FAISS index (built on first run)
│           └── requirements.txt
│
├── composer.json                      # PHP dependencies
├── package.json                       # Frontend dependencies (Vite)
├── phpunit.xml                        # Test configuration
└── vite.config.js                     # Frontend build config
```

---

## 🐛 Troubleshooting

### Container Issues

| Problem | Solution |
|---------|----------|
| **Container won't start** | Check logs: `docker compose logs -f <service>` and ensure 16GB+ RAM available |
| **Port already in use** | Change port in `docker-compose.yml` or stop conflicting containers |
| **Out of memory** | Increase Docker desktop memory allocation (Settings > Resources) |
| **Build failures** | Rebuild with no cache: `docker compose build --no-cache --parallel` |

### Database Issues

| Problem | Solution |
|---------|----------|
| **Migrations fail** | Ensure MySQL is healthy: `docker compose ps mysql` and `docker compose logs -f mysql` |
| **Can't connect to DB** | Check DB credentials in `docker/laravel.env` and run: `docker compose exec laravel php artisan db:ping` |
| **Data loss after restart** | Check volume persistence: `docker volume ls` and ensure `mysql-data` volume exists |

### AI Service Issues

| Problem | Solution |
|---------|----------|
| **Model loading errors** | Verify model files exist: `ls ai_apps/ADMIT/admet_inference/models/*/best_model.ckpt` |
| **Out of memory on GPU** | Reduce batch size in service config or disable GPU with `CUDA_VISIBLE_DEVICES=-1` |
| **Service timeout** | Increase startup timeout or check logs: `docker compose logs -f <service>` |
| **FAISS index build slow** | First run of Chemical RAG builds 1M compound index (~3-5 min) - this is normal |

### Development Issues

| Problem | Solution |
|---------|----------|
| **Python venv not working** | Ensure Python 3.10+ installed: `python --version` |
| **Missing dependencies** | Reinstall: `pip install -r requirements.txt --upgrade` |
| **PyTorch not finding CUDA** | Install CUDA-compatible PyTorch: `pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121` |
| **Permission denied on scripts** | Make executable: `chmod +x start.sh` (Mac/Linux) |

### Common Errors & Fixes

**Error:** `ERROR: Could not find a version that satisfies the requirement torchaudio==0.15.2`

**Fix:** This was resolved in v2.0. Update dependencies: `docker compose build --no-cache`

**Error:** `Connection refused: Cannot connect to laravel service`

**Fix:** Ensure Laravel is healthy: `curl http://localhost:8080/api/health` or check `docker compose logs -f laravel`

---

## 🔒 Production Guide

### Pre-Deployment Checklist

- [ ] All services tested locally with `docker compose up`
- [ ] Environment variables securely configured (no hardcoded secrets in code)
- [ ] Database backups configured
- [ ] Monitoring and logging endpoints configured
- [ ] Rate limiting applied to API endpoints
- [ ] HTTPS/TLS certificates provisioned

### Deployment Architecture

```yaml
┌────────────────────────────────────────────┐
│         PRODUCTION ENVIRONMENT             │
├────────────────────────────────────────────┤
│                                            │
│  ┌─────────────────────────────────────┐  │
│  │   NGINX Reverse Proxy + TLS         │  │
│  │   (Terminates HTTPS, routes traffic)│  │
│  └─────────────────────────────────────┘  │
│            │                               │
│  ┌─────────┴────────────────────────────┐ │
│  │  Docker Compose / Kubernetes         │ │
│  │  ├── Laravel API (3+ replicas)       │ │
│  │  ├── Queue Workers (2-4 replicas)    │ │
│  │  ├── MySQL Primary + Replicas        │ │
│  │  ├── ADMET Services (auto-scale)     │ │
│  │  ├── Drug Repurposing (auto-scale)   │ │
│  │  └── Chemical RAG (1+ replicas)      │ │
│  └──────────────────────────────────────┘ │
│            │                               │
│  ┌─────────┴────────────────────────────┐ │
│  │  Persistent Storage                  │ │
│  │  ├── MySQL Data Volume               │ │
│  │  ├── FAISS Index Cache               │ │
│  │  └── Model Artifacts                 │ │
│  └──────────────────────────────────────┘ │
│                                            │
└────────────────────────────────────────────┘
```

### Scaling Considerations

- **Horizontal Scaling:** Increase replicas for stateless services (Laravel, AI services)
- **Database Scaling:** Use read replicas for MySQL, implement connection pooling
- **Queue Scaling:** Add more queue workers based on job volume
- **Memory Management:** Each AI service requires: ADMET 6GB, Drug Repurposing 8GB, Chemical RAG 4GB

### Monitoring

Key metrics to monitor:

```bash
# Container health
docker compose ps

# Resource usage
docker stats

# Service logs
docker compose logs --tail=100 -f <service>

# Database connection pool
docker compose exec laravel php artisan tinker
```

---

## 📋  Testing

### Running Tests

```bash
# Laravel tests
docker compose exec laravel php artisan test

# AI service tests (Drug Repurposing example)
cd ai_apps/Drug\ Reporposing
python -m pytest test_api.py -v

# Integration tests
docker compose exec drug-repurposing python test_integration.py
```

### Health Check Scripts

Each service exposes `/health` endpoint:

```bash
# Check all services
for service in admet drug-repurposing chemical-rag; do
  echo "Testing $service..."
  curl http://localhost:${PORT}/health
done
```

---

## 🤝 Contributing

### Development Workflow

1. **Clone and Setup**
   ```bash
   git clone <repo-url>
   cd ailixir-backend
   docker compose build --parallel
   ```

2. **Make Changes**
   - Edit files directly (Docker volumes mount local code)
   - Services auto-reload in development mode

3. **Test Your Changes**
   ```bash
   docker compose exec laravel php artisan test
   python -m pytest ai_apps/Drug\ Reporposing/test_api.py
   ```

4. **Commit & Push**
   ```bash
   git add .
   git commit -m "Clear description of changes"
   git push origin feature-branch
   ```

### Code Style Guidelines

- **PHP:** PSR-12 standard (Laravel IDE Helper available)
- **Python:** PEP 8 standard (Black formatter can be used)
- **Commits:** Use conventional commit format (`feat:`, `fix:`, `docs:`)

### Documentation Updates

Update relevant documentation when:
- Adding new API endpoints → Update service README
- Changing environment variables → Update `docker/laravel.env` and this README
- Modifying Docker setup → Update `DOCKER.md`
- Changing deployment steps → Update `PRODUCTION_GUIDE.md`

---

## 📚 Additional Resources

### Service-Specific Documentation

- **[ADMET Inference](./ai_apps/ADMIT/README.md)** - MPNN models for drug properties
- **[Drug Repurposing](./ai_apps/Drug%20Reporposing/README.md)** - See also `QUICK_START.md` (60-second setup), `PRODUCTION_GUIDE.md`
- **[Chemical RAG](./ai_apps/chemical-rag-system/README.md)** - FAISS + LLM powered search

### Key Documentation Files

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System design, component diagrams, data flows
- **[DOCKER.md](./DOCKER.md)** - Docker-specific setup and configuration
- **[DOCKER_FIXES.md](./DOCKER_FIXES.md)** - Known issues and resolutions

### External Resources

- [Laravel Documentation](https://laravel.com/docs/12)
- [FastAPI Guide](https://fastapi.tiangolo.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [PyTorch Documentation](https://pytorch.org/docs/stable/index.html)

---

## 📞 Support & Contact

For issues or questions:

1. **Check existing documentation** first (ARCHITECTURE.md, service READMEs)
2. **Review troubleshooting guide** above
3. **Check container logs** for error details
4. **Contact team:** Omar Fadlalla & Development Team

---

## 📄 License

This project is proprietary software. All rights reserved. See LICENSE file for details.

---

## 🗺️ Roadmap

**v2.1 (Q3 2026)**
- [ ] Kubernetes deployment configs
- [ ] Advanced monitoring dashboard
- [ ] API rate limiting & caching
- [ ] GraphQL endpoint option

**v3.0 (Q4 2026)**
- [ ] Multi-tenant support
- [ ] Advanced result export formats
- [ ] Custom model upload capability
- [ ] Integration with external databases

---

**Last Updated:** May 2026 | **Version:** 2.0 | **Status:** Production Ready ✅

### Environment variables

Where to look:
- Laravel env template: [docker/laravel.env](docker/laravel.env)
- Service-specific `.env` or config files are found in each `ai_apps/*` folder (check `config.py`, `app/config.py`, or service `docker` folders).

Common variables (examples — confirm in each service):
```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=ailixir
DB_USERNAME=root
DB_PASSWORD=secret

AI_ADMET_URL=http://admet:8001
AI_DRUG_REPURPOSING_URL=http://drug-repurposing:8002
AI_CHEMICAL_RAG_URL=http://chemical-rag:8003
```

For local development, prefer using local `.env` files (not checked into git) and the service README in each `ai_apps` folder for any extra keys (e.g., HuggingFace API key, PubChem credentials, or model paths).

## 📚 Service Documentation

Each service has comprehensive documentation:

1. **ADMET Inference** → [Service README](./ai_apps/ADMIT/admet_inference/README.md)
   - MPNN model architecture
   - Batch prediction API
   - Performance benchmarks
   - Troubleshooting guide

2. **Drug Repurposing** → [Service README](./ai_apps/Drug%20Reporposing/README.md)
   - DeepPurpose model specifications
   - Drug-target binding prediction
   - API testing guide
   - Implementation notes

3. **Chemical RAG** → [Service README](./ai_apps/chemical-rag-system/README.md)
   - FAISS-IVF vector index
   - 1M+ compound library
   - Retrieval-augmented generation
   - RDKit chemistry engine

4. **Laravel Backend** → [API Documentation](./routes/api.php)
   - Authentication & authorization
   - Orchestration endpoints
   - Job queue management
   - Database schema

---

## 🗂️ Project Structure

```
AILIXIR_BackEnd/
├── app/                          # Laravel application
│   ├── Http/Controllers/        # API endpoints
│   ├── Models/                  # Database models
│   └── Jobs/                    # Background jobs
├── ai_apps/                     # AI microservices
│   ├── ADMIT/                   # ADMET prediction service
│   ├── Drug Reporposing/        # Drug repurposing pipeline
│   └── chemical-rag-system/     # Chemical retrieval system
├── config/                       # Configuration files
├── database/                     # Migrations & seeders
├── docker/                       # Docker configuration
├── routes/                       # API route definitions
├── storage/                      # Persistent data
├── docker-compose.yml          # Service orchestration
├── Dockerfile                   # Laravel container
└── README.md                    # This file
```

---

## 🚀 Common Tasks

### Build Containers
```bash
docker compose build --parallel
```

### View Logs
```bash
docker compose logs -f <service-name>
# Examples:
docker compose logs -f admet
docker compose logs -f drug-repurposing
docker compose logs -f laravel
```

### Run Migrations
```bash
docker compose exec laravel php artisan migrate
```

### Access Service Shells
```bash
# Laravel shell
docker compose exec laravel php artisan tinker

# Python service shell
docker compose exec admet python
```

### Stop Services
```bash
docker compose down
```

---

## 🧪 Testing

### Run API Tests
```bash
cd ai_apps/Drug\ Reporposing
jupyter notebook api_test_notebook.ipynb
```

### Run Unit Tests
```bash
docker compose exec laravel php artisan test
```

### Verify Container Health
```bash
docker compose ps
# All services should show "Up" status
```

---

## 📊 Known Issues & Resolutions

| Issue | Resolution | Status |
|-------|-----------|--------|
| `torchaudio==0.15.2` not found on PyPI | Updated to `torchaudio==2.0.1` | ✅ Fixed |
| Dockerfile casing warnings (linter) | Changed `as` to `AS` in multi-stage builds | ✅ Fixed |
| Drug Repurposing build timeouts | Added parallel build flag (`--parallel`) | ✅ Fixed |

---

## 🔐 Environment Configuration

Key variables configured in `docker/laravel.env`:

```env
APP_NAME=AILIXIR
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_NAME=ailixir

AI_ADMET_URL=http://admet:8001
AI_DRUG_REPURPOSING_URL=http://drug-repurposing:8002
AI_CHEMICAL_RAG_URL=http://chemical-rag:8003

```

---

## 📖 Additional Resources

- **[Quick Start Guide](./QUICK_START.md)** - 60-second setup
- **[Production Deployment](./PRODUCTION_GUIDE.md)** - Scaling & optimization
- **[Docker Documentation](./DOCKER.md)** - Container configuration
- **[Implementation Summary](./ai_apps/Drug%20Reporposing/IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[API Test Guide](./ai_apps/Drug%20Reporposing/API_TESTING_GUIDE.md)** - Testing endpoints

---

## 🆘 Troubleshooting

### Container Build Failures
```bash
# Clear Docker cache and rebuild
docker compose build --no-cache --parallel

# Check individual service logs
docker compose logs <service-name>
```

### Python Service Issues
- Ensure Python versions match: `python3.10` for Drug Repurposing, `3.11` for others
- Verify virtual environments created: `/opt/venv` inside containers

### API Connection Errors
- Verify all services are running: `docker compose ps`
- Check service health: `docker compose logs <service>`
- Test connectivity: `curl http://localhost:8000/api`

---

## 📄 License

Licensed under the MIT License. See LICENSE file for details.

---

## 👥 Support

For issues, feature requests, or questions:
- Check individual service documentation
- Review Docker logs: `docker compose logs -f`
- Consult [Production Guide](./PRODUCTION_GUIDE.md) for deployment issues
