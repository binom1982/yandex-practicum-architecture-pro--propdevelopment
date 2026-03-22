## Как запустить

Проверить, что kubectl видит кластер

```shell
kubectl cluster-info
```

Запуск скриптов

```shell
./scripts/create-users.sh
./scripts/create-roles.sh
./scripts/bind-roles.sh
```

Проверка

```shell
# Проверить токен группы security-specialist-token 
kubectl get secret security-specialist-token -n default -o jsonpath='{.data.token}' | base64 -d

# Проверка: Аналитик НЕ должен иметь доступа к секретам
kubectl auth can-i get secrets --as=system:serviceaccount:default:business-analyst
# Ожидаемый ответ: no

# Проверка: ИБ ДОЛЖЕН иметь доступ ко всему
kubectl auth can-i delete pods --as=system:serviceaccount:default:security-specialist
# Ожидаемый ответ: yes

# Проверка: Разработчик изолирован в своем неймспейсе
kubectl auth can-i get pods -n default --as=system:serviceaccount:dev-sales:developer-sales
# Ожидаемый ответ: no (так как он создан в ns dev-sales и роль действует только там)
```
