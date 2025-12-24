#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
INFRA_DIR="$ROOT_DIR/infra"

echo "Using infra dir: $INFRA_DIR"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform not found in PATH. Please install Terraform v1.x.x or newer." >&2
  exit 1
fi

# Check LocalStack health (basic TCP check)
LOCALSTACK_HOST=${LOCALSTACK_HOST:-localhost}
LOCALSTACK_PORT=${LOCALSTACK_PORT:-4566}

echo "Checking LocalStack at http://$LOCALSTACK_HOST:$LOCALSTACK_PORT..."
check_localstack() {
  host="$1"
  port="$2"

  # Try nc (netcat) if available
  if command -v nc >/dev/null 2>&1; then
    if nc -z "$host" "$port" >/dev/null 2>&1; then
      return 0
    fi
  fi

  # Fallback to curl (checks HTTP health endpoint)
  if command -v curl >/dev/null 2>&1; then
    # Try LocalStack health endpoint first
    if curl -sS --fail "http://$host:$port/health" >/dev/null 2>&1; then
      return 0
    fi
    # Then try root URL
    if curl -sS --fail "http://$host:$port/" >/dev/null 2>&1; then
      return 0
    fi
  fi

  return 1
}

if ! check_localstack "$LOCALSTACK_HOST" "$LOCALSTACK_PORT"; then
  echo "LocalStack not reachable at $LOCALSTACK_HOST:$LOCALSTACK_PORT. Start LocalStack before running this script." >&2
  exit 1
fi

# Bucket name from env or argument
BUCKET_NAME=${BUCKET_NAME:-appinspector-jobs}
if [ -z "$BUCKET_NAME" ]; then
  if [ $# -ge 1 ]; then
    BUCKET_NAME="$1"
  else
    echo "Usage: $0 <bucket-name>  (or set BUCKET_NAME env var)" >&2
    exit 1
  fi
fi

echo "Bucket name: $BUCKET_NAME"

pushd "$INFRA_DIR" >/dev/null

# create terraform.tfvars
cat > terraform.tfvars <<EOF
bucket_name = "$BUCKET_NAME"
EOF

terraform init -input=false
terraform apply -auto-approve

echo "Done. Outputs:"
terraform output

popd >/dev/null
