# Как запустить

## Развертывание сервисов (Pods)

```shell
./scripts/deploy-services.sh
```

## Сетевая политика (NetworkPolicy)

```shell
kubectl apply -f non-admin-api-allow.yaml
```

Проверка трафика

```shell
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
# HTML код Nginx: OK 
/ # wget -qO- --timeout=2 http://front-end-app
# Доступ закрыт: download timed out 
/ # wget -qO- --timeout=2 http://back-end-api-app

# HTML код Nginx: OK 
/ # wget -qO- --timeout=2 http://admin-front-end-app
# Доступ закрыт: download timed out 
/ # wget -qO- --timeout=2 http://admin-back-end-api-app
```

## Очистка

```shell
# Удаляем созданный NS
kubectl delete namespace prop-dev-ns
# Переключаем контекст обратно на default
kubectl config set-context --current --namespace=default
# Убеждаемся, что наш NS удален
kubectl get namespaces
```
