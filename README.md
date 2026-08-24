# Project 43 — MLOps Platform on Kubernetes

Production-style Kubernetes platform for serving an ML model produced by Project 42.

## Architecture

```text
MLflow / Model Registry
        |
        | model version / alias
        v
Model package / container
        |
        v
Kubernetes Deployment
        |
        +--> Service
        +--> HPA
        +--> PDB
        +--> NetworkPolicy
        +--> Probes
        +--> Prometheus metrics
        |
        v
Inference clients
```

## What this demonstrates

- Kubernetes model-serving workload
- Explicit model version metadata
- Immutable container image references
- Readiness/liveness/startup probes
- CPU and memory requests/limits
- HPA for inference replicas
- PodDisruptionBudget
- Topology spreading / anti-affinity
- Network isolation
- Prometheus metrics annotations
- Rollout and rollback procedures
- Environment overlays
- GitOps-compatible manifests
- CI manifest/security validation

## Deployment

```bash
kubectl apply -k k8s/overlays/staging
kubectl -n mlops-platform rollout status deployment/model-server --timeout=180s
```

Production is intentionally a separate overlay and should be promoted through Git review / GitOps rather than direct CI mutation.

## Model lifecycle

Project 42 produces and promotes a model through MLflow aliases. This project consumes the resulting model release as deployment metadata. The serving image remains immutable while the model version is explicitly labeled on the workload.

## Production hardening

- Use a private image registry.
- Pull by image digest in production.
- Store model artifacts in durable object storage.
- Use workload identity for object-store access.
- Add request/latency/error SLOs.
- Add GPU node pools for GPU models.
- Add canary or progressive model rollout.
- Use KServe/Seldon or another specialized serving layer where model lifecycle complexity requires it.

## Validation

```bash
./tests/test_manifests.sh
```

A live cluster deployment is not claimed because this repository is validated offline/through CI unless connected to a real Kubernetes cluster.

## License

MIT
