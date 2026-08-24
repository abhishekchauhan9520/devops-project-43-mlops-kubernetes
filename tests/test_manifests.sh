#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
from pathlib import Path

required = [
    Path('k8s/base/deployment.yaml'),
    Path('k8s/base/service.yaml'),
    Path('k8s/base/hpa.yaml'),
    Path('k8s/base/pdb.yaml'),
    Path('k8s/base/networkpolicy.yaml'),
    Path('k8s/overlays/staging/kustomization.yaml'),
    Path('k8s/overlays/production/kustomization.yaml'),
]
for path in required:
    assert path.exists(), path

dep = Path('k8s/base/deployment.yaml').read_text()
for marker in ['runAsNonRoot: true','allowPrivilegeEscalation: false','readOnlyRootFilesystem: true','type: RuntimeDefault','readinessProbe:','livenessProbe:','startupProbe:','MODEL_VERSION','MODEL_ALIAS:','prometheus.io/scrape: "true"']:
    assert marker in dep, marker

hpa = Path('k8s/base/hpa.yaml').read_text()
assert 'minReplicas: 2' in hpa and 'maxReplicas: 10' in hpa

pdb = Path('k8s/base/pdb.yaml').read_text()
assert 'minAvailable: 1' in pdb

np = Path('k8s/base/networkpolicy.yaml').read_text()
assert 'policyTypes:' in np and '  - Ingress' in np and '  - Egress' in np
assert 'port: 53' in np
assert '4317' not in np

for overlay in ['staging','production']:
    text = Path(f'k8s/overlays/{overlay}/patch.yaml').read_text()
    assert 'model-version: v1' in text
    assert 'mlops.example.com/model-alias:' in text

print('Project 43 manifest/security assertions passed.')
PY
