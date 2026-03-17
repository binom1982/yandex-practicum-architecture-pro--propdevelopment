#!/bin/bash
echo "=== Привязка ролей (RoleBindings) ==="

# 1. Специалист по ИБ -> cluster-admin
# Обоснование: Аудит, расследование инцидентов, доступ к секретам (требование задания).
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-specialist-binding
subjects:
- kind: ServiceAccount
  name: security-specialist
  namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
echo "Binding: security-specialist -> cluster-admin"

# 2. DevOps-инженер -> cluster-admin (или namespace-configurator, если хотим разделить)
# В малой команде (один специалист по ИБ) DevOps часто имеет полные права для поддержки.
# Но следуя принципу разделения: дадим им права настройщика кластера (namespace-configurator).
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devops-engineer-binding
subjects:
- kind: ServiceAccount
  name: devops-engineer
  namespace: default
roleRef:
  kind: ClusterRole
  name: namespace-configurator
  apiGroup: rbac.authorization.k8s.io
EOF
echo "Binding: devops-engineer -> namespace-configurator"

# 3. Бизнес-аналитик -> cluster-viewer
# Обоснование: Только просмотр статусов сервисов для отчетности.
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: business-analyst-binding
subjects:
- kind: ServiceAccount
  name: business-analyst
  namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-viewer
  apiGroup: rbac.authorization.k8s.io
EOF
echo "Binding: business-analyst -> cluster-viewer"

# 4. Разработчик (Sales) -> developer-restricted (в своем NS)
# Обоснование: Разграничение доступа по организационной структуре (домен продаж).
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-sales-binding
  namespace: dev-sales
subjects:
- kind: ServiceAccount
  name: developer-sales
  namespace: dev-sales
roleRef:
  kind: Role
  name: developer-restricted
  apiGroup: rbac.authorization.k8s.io
EOF
echo "Binding: developer-sales -> developer-restricted (in dev-sales)"

echo "=== Готово ==="
echo "Проверка прав:"
echo "1. Может ли аналитик видеть секреты? (Должно быть no)"
echo "kubectl auth can-i get secrets --as=system:serviceaccount:default:business-analyst"
echo ""
echo "2. Может ли разработчик sales видеть поды в kube-system? (Должно быть no)"
echo "kubectl auth can-i get pods -n kube-system --as=system:serviceaccount:dev-sales:developer-sales"
echo ""
echo "3. Может ли ИБ удалять поды? (Должно быть yes)"
echo "kubectl auth can-i delete pods --as=system:serviceaccount:default:security-specialist"