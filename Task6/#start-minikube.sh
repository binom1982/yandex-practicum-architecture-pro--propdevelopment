#!/bin/bash
echo $HOME

# Отключаем конвертацию путей Git Bash (критично для работы с путями типа /var/log)
export MSYS_NO_PATHCONV=1

# Загружаем переменные из файла .env-audit, если он существует
if [ -f .env-audit ]; then
    set -a # Автоматически экспортировать все переменные
    source .env-audit
    set +a
else
    echo "Warning: .env-audit not found. Using default values."
    AUDIT_POLICY_PATH="/etc/kubernetes/audit-policy.yaml"
    AUDIT_LOG_PATH="/var/log/audit.log"
    AUDIT_MAXAGE="1"
    AUDIT_MAXBACKUP="1"
    AUDIT_MAXSIZE="100"
fi

# Проверяем наличие папки для логов
mkdir -p audit-logs

echo "Starting Minikube with Audit Policy..."
echo "Policy file host path: $(pwd)/audit-policy.yaml"
echo "Log host path: $(pwd)/audit-logs"

# Запуск Minikube
# Мы используем переменные ${VAR} вместо хардкода длинных флагов
minikube start \
  --driver=docker \
  --extra-config=apiserver.audit-policy-file="${AUDIT_POLICY_PATH}" \
  --extra-config=apiserver.audit-log-path="${AUDIT_LOG_PATH}" \
  --extra-config=apiserver.audit-log-maxage="${AUDIT_MAXAGE}" \
  --extra-config=apiserver.audit-log-maxbackup="${AUDIT_MAXBACKUP}" \
  --extra-config=apiserver.audit-log-maxsize="${AUDIT_MAXSIZE}" \
  --mount \
  --mount-string="$(pwd):/etc/kubernetes" \
  --mount-string="$(pwd)/audit-logs:/var/log"

echo "Minikube started successfully."