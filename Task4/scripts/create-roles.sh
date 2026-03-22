#!/bin/bash
echo "=== Создание Ролей и ClusterRoles ==="

# 1. Роль: Cluster Admin (Привилегированная группа)
# Полномочия: Полный доступ ко всем ресурсам, включая секреты.
# Группы: Специалист по ИБ, DevOps-инженеры.
# Используем встроенную роль cluster-admin, явное создание не требуется, 
# но для наглядности логики оставим комментарий. В скрипте bind мы привяжем их к встроенной роли.
echo "Роль 'cluster-admin' уже существует в кластере по умолчанию."

# 2. Роль: Namespace Configurator (Группа настройки)
# Полномочия: Полный доступ к ресурсам внутри конкретного NS (deployments, services, configmaps), 
# но без удаления самих NS или управления узлами.
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-configurator
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "services", "configmaps", "persistentvolumeclaims", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch", "create", "update"] # DevOps может управлять секретами приложений
EOF
echo "ClusterRole 'namespace-configurator' created."

# 3. Роль: Cluster Viewer (Группа только на просмотр)
# Полномочия: Только чтение основных ресурсов. Доступ к секретам ЗАПРЕЩЕН.
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-viewer
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "services", "replicasets", "jobs", "configmaps"]
  verbs: ["get", "list", "watch"]
EOF
echo "ClusterRole 'cluster-viewer' created."

# 4. Роль: Developer Restricted (Для разработчиков в своем домене)
# Полномочия: Только управление подами и деплоями в своем NS. Нет доступа к секретам и конфигмапам (или только чтение).
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-restricted
  namespace: dev-sales
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
# Явно нет прав на secrets и configmaps для безопасности
EOF
echo "Role 'developer-restricted' created in namespace 'dev-sales'."