# 🚀 AILIXIR Backend - Integrated AI Drug Discovery Platform

**Status**: ✅ Production Ready | **Version**: 2.0.0 | **Last Updated**: 2026

A comprehensive microservices backend combining **Laravel**, **FastAPI**, and **PyTorch** for AI-driven drug discovery, including ADMET prediction, drug repurposing, and chemical retrieval systems.

---

## 📋 Quick Navigation

- **🏃 [Quick Start](./QUICK_START.md)** - Get running in 5 minutes
- **🐳 [Docker Setup](./DOCKER.md)** - Containerized deployment guide
- **🔧 [Production Guide](./PRODUCTION_GUIDE.md)** - Deployment & scaling
- **🧪 [API Testing](./ai_apps/Drug%20Reporposing/API_TESTING_GUIDE.md)** - Test all endpoints

---

## 🎯 System Overview

AILIXIR is an integrated backend combining four specialized AI services:

| Service | Purpose | Stack | Status |
|---------|---------|-------|--------|
| **[ADMET Inference](./ai_apps/ADMIT/admet_inference/README.md)** | Drug ADMET property prediction | PyTorch + FastAPI (Python 3.11) | ✅ Ready |
| **[Drug Repurposing](./ai_apps/Drug%20Reporposing/README.md)** | Identify therapeutic uses for existing drugs | DeepPurpose + FastAPI (Python 3.10) | ✅ Ready |
| **[Chemical RAG](./ai_apps/chemical-rag-system/README.md)** | Retrieve & generate chemical compounds | RDKit + FAISS + FastAPI (Python 3.11) | ✅ Ready |
| **[Laravel Backend](./app)** | REST API, authentication, job queue (PHP 8.3) | Laravel + Queue Worker | ✅ Ready |

---

## 🐳 Docker Architecture

All services run in isolated containers orchestrated by Docker Compose:

```yaml
Services:
├── laravel          (PHP 8.3-cli) - REST API & web server
├── queue            (PHP 8.3-cli) - Background job processor  
├── admet            (Python 3.11-slim) - ADMET predictions
├── drug-repurposing (Python 3.10-slim) - Drug repurposing AI
└── chemical-rag     (Python 3.11-slim) - Chemical retrieval
```

### 🔧 Recent Docker Fixes (v2.0)

We've resolved the following issues identified in CI/CD:

**✅ Fixed Issue #1: PyTorch Version Incompatibility**
- **Problem**: `torchaudio==0.15.2` did not exist on PyPI (version gap between 0.13.1 → 2.0.1)
- **Error**: "ERROR: Could not find a version that satisfies the requirement torchaudio==0.15.2"
- **Solution**: Updated to `torchaudio==2.0.1` (compatible with torch==2.0.1 and Python 3.10)
- **File**: `ai_apps/Drug Reporposing/requirements.txt` (lines 24-26)
- **Status**: ✅ Verified in container builds

**✅ Fixed Issue #2: Dockerfile Casing Warnings**
- **Problem**: FromAsCasing linter warnings on mixed-case `as`/`FROM` keywords
- **Solution**: Updated multi-stage build syntax to `FROM python:X-slim AS builder`
- **Files Updated**:
  - `ai_apps/ADMIT/admet_inference/Dockerfile` (line 4)
  - `ai_apps/Drug Reporposing/docker/Dockerfile` (line 1)
- **Status**: ✅ All Dockerfiles now pass style checks

---

## 📦 Installation & Deployment

### Prerequisites
- Docker & Docker Compose (v2.0+)
- 4GB+ available disk space
- Git (for cloning)

### Quick Start (5 minutes)

```bash
# Clone repository
git clone <repo-url>
cd AILIXIR_BackEnd

# Build all containers (with fixes applied)
docker compose build --parallel

# Start all services
docker compose up -d

# Verify services are running
docker compose ps
```

### Accessing Services

| Service | URL | Purpose |
|---------|-----|---------|
| Laravel API | `http://localhost:8000` | REST API endpoints |
| ADMET API | `http://localhost:8001/docs` | ADMET predictions |
| Drug Repurposing | `http://localhost:8002/docs` | Drug repurposing |
| Chemical RAG | `http://localhost:8003/docs` | Chemical retrieval |

---

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

AI_ADMET_URL=http://admet:8000
AI_DRUG_REPURPOSING_URL=http://drug-repurposing:8000
AI_CHEMICAL_RAG_URL=http://chemical-rag:8000
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
