#!/bin/bash
echo "=== Создание пользователей (ServiceAccounts) для PropDevelopment ==="

# 1. Специалист по ИБ (нужен полный доступ и доступ к секретам для аудита)
kubectl create sa security-specialist --namespace=default
echo "User 'security-specialist' created."

# 2. DevOps-инженер (нужен полный доступ к управлению ресурсами в неймспейсах)
kubectl create sa devops-engineer --namespace=default
echo "User 'devops-engineer' created."

# 3. Разработчик (ограниченный доступ только к своему домену, например, sales)
kubectl create ns dev-sales
kubectl create sa developer-sales --namespace=dev-sales
echo "Namespace 'dev-sales' and User 'developer-sales' created."

# 4. Бизнес-аналитик (только просмотр)
kubectl create sa business-analyst --namespace=default
echo "User 'business-analyst' created."

# Генерация токенов для аутентификации (для K8s 1.24+)
for user in security-specialist devops-engineer business-analyst; do
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${user}-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: ${user}
type: kubernetes.io/service-account-token
EOF
done

# Токен для разработчика в его неймспейсе
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: developer-sales-token
  namespace: dev-sales
  annotations:
    kubernetes.io/service-account.name: developer-sales
type: kubernetes.io/service-account-token
EOF

echo "Токены созданы. Для получения токена используйте:"
echo "kubectl get secret <name>-token -n <namespace> -o jsonpath='{.data.token}' | base64 -d"