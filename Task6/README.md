# Аудит активности пользователей и обнаружение инцидентов

## Запустить Minikube с политикой аудита

Решение (без --mount) bash

```bash
mkdir C:\minikube\audit
mkdir C:\minikube\logs

minikube start --driver=docker \
  --mount --mount-string="C:/minikube:/mnt/audit" \
  --extra-config=apiserver.audit-policy-file=/mnt/audit/audit/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/mnt/audit/logs/audit.log \
  --extra-config=apiserver.audit-log-maxage=30 \
  --extra-config=apiserver.audit-log-maxbackup=10 \
  --extra-config=apiserver.audit-log-maxsize=100
```

Проверка

```bash
minikube status
# Ожидаем:
#   host: Running
#   kubelet: Running
#   apiserver: Running
#   kubeconfig: Configured

kubectl cluster-info
kubectl get pods -n kube-system -l component=kube-apiserver
```

Смонтировать на windows получилось только через PowerShell

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
# 1. Очистите старый кластер
minikube delete --purge
#minikube delete


# 3. Скопируйте audit-policy.yaml внутрь VM
# Путь на Windows (откуда):
$SOURCE = "C:\Users\binom\YandexDisk\Курсы\Архитектура ПО\Спринт 05 Проектная работа PropDevelopment\yandex-practicum-architecture-pro--propdevelopment\Task6"

# Путь внутри Minikube VM (куда):
$DEST = "/etc/kubernetes/audit-policy.yaml"

# 2. Запустите чистый кластер БЕЗ монтирования
minikube start --driver=docker --kubernetes-version=v1.32.0 --mount-string="${SOURCE}\audit-logs:/var/log"

minikube cp "${SOURCE}\audit-policy.yaml" "$DEST"

# 4. Проверьте, что файл внутри
minikube ssh "cat $DEST"

# 5. Перезапустите с конфигурацией аудита
minikube stop
minikube start --driver=docker `
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml `
  --extra-config=apiserver.audit-log-path=/var/log/audit.log


# 6. Создайте файл логов внутри VM
#minikube ssh "mkdir -p /var/log && touch /var/log/audit.log"

# 7. Настройте kubectl на minikube
minikube update-context
kubectl config use-context minikube
```

## Скрипт симуляции

```
bash simulate-incident.sh
```

## Проверка файлов

```bash
# Установите jq, если ещё не установлен
winget install jqlang.jq

# Проверка через jq (альтернатива скрипту)
jq 'select(.objectRef.resource=="secrets" and .verb=="get")' audit.log
jq 'select(.verb=="create" and .objectRef.subresource=="exec")' audit.log
jq 'select(.objectRef.resource=="pods" and .requestObject.spec.containers[].securityContext.privileged==true)' audit.log
grep -i 'audit-policy' audit.log

# Или через Python-скрипт
python filter_audit.py
```
