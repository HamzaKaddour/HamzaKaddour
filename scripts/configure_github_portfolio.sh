#!/usr/bin/env bash
set -euo pipefail

# One-time repository-admin setup for HamzaKaddour's flagship portfolio repos.
# Requires GitHub CLI authenticated as the repository owner:
#   gh auth login
#   gh auth status
#
# Run:
#   bash scripts/configure_github_portfolio.sh

OWNER="HamzaKaddour"

gh auth status >/dev/null

set_repo() {
  local repo="$1"
  local description="$2"
  local homepage="$3"
  shift 3

  echo "Configuring $OWNER/$repo ..."
  gh api --method PATCH "repos/$OWNER/$repo"     -f description="$description"     -f homepage="$homepage" >/dev/null

  # Replace repository topics with the curated portfolio set.
  local json='{"names":['
  local first=1
  for topic in "$@"; do
    if [[ $first -eq 0 ]]; then json+=','; fi
    json+="\"$topic\""
    first=0
  done
  json+=']}'
  printf '%s' "$json" | gh api --method PUT "repos/$OWNER/$repo/topics" --input - >/dev/null
}

set_repo "Stats-from-the-World"   "Source-aware global development intelligence platform integrating World Bank WDI and IMF WEO with automated ETL, provenance, geospatial analytics, and country benchmarking."   "https://hamzakaddour.github.io/Stats-from-the-World/"   data-engineering world-bank imf data-visualization geospatial plotly parquet github-actions public-data analytics

set_repo "ragops-evaluation-dashboard"   "Local-first RAG evaluation and observability platform with hybrid retrieval, reranking, groundedness/citation checks, abstention, FastAPI, and benchmark-driven reliability."   "https://hamzakaddour.github.io/ragops-evaluation-dashboard/"   rag llm faiss information-retrieval reranking fastapi evaluation observability qwen sentence-transformers

set_repo "mlops-monitoring-dashboard"   "End-to-end MLOps monitoring platform with MLflow, FastAPI, prediction logging, Evidently drift analysis, Prometheus/Grafana observability, retraining signals, and CI."   "https://hamzakaddour.github.io/mlops-monitoring-dashboard/"   mlops mlflow evidently prometheus grafana fastapi model-monitoring docker github-actions machine-learning

set_repo "Wire-Detection-using-YOLO"   "Comparative aerial power-line and transmission-tower detection using YOLOv5, YOLOv8, and YOLOv11 across multiple image resolutions."   ""   computer-vision object-detection yolo yolov5 yolov8 yolov11 aerial-imagery deep-learning pytorch infrastructure-inspection

set_repo "Generalizable_Deep_RL_Smart_Handover_5G-"   "Generalizable deep reinforcement learning for intelligent handover in indoor WiGig networks using DQN, PPO, and A2C."   "https://doi.org/10.1109/VTC2025-Fall65116.2025.11310213"   reinforcement-learning deep-reinforcement-learning dqn ppo a2c 5g wireless-networks handover machine-learning research

set_repo "DL_ML_IoT_Security"   "Machine learning, deep learning, and reinforcement learning for IoT intrusion detection, with comparative evaluation on network-security data."   "https://doi.org/10.1109/ORSS62274.2024.10697949"   machine-learning deep-learning reinforcement-learning cybersecurity iot intrusion-detection network-security python research

protect_main() {
  local repo="$1"
  echo "Protecting $OWNER/$repo main branch ..."
  gh api --method PUT "repos/$OWNER/$repo/branches/main/protection"     -H "Accept: application/vnd.github+json"     --input - <<'JSON' >/dev/null
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["test"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": true
}
JSON
}

# These two repositories have CI checks named "test" and no workflow that needs
# to commit generated artifacts back to main.
protect_main "ragops-evaluation-dashboard"
protect_main "mlops-monitoring-dashboard"

echo "Done."
echo "Note: Stats-from-the-World is intentionally not protected by this script because its scheduled data-refresh workflow commits refreshed artifacts back to main."
