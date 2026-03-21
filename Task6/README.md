# Аудит активности пользователей и обнаружение инцидентов

## Запустить Minikube с политикой аудита# Удалить ранее запущенный кластер

```shell
# Удаление старого кластера
minikube delete --all --purge

minikube start --extra-config=apiserver.audit-policy-file=audit-policy.yaml

# Установка скрипта исполняеммым
chmod +x start-minikube.sh

# Запуск нового кластера с политикой аудита
./start-minikube.sh
```

## Проверка

```shell
# Проверка, что под API-сервера поднялся и видит файл:
minikube ssh "ls -l /etc/kubernetes/audit-config/audit-policy.yaml"
minikube ssh "ls -l /var/log/audit.log"
```

## Скрипт симуляции

```
bash simulate-incident.sh
```

## Скрипт анализа

```
chmod +x filter_audit.sh
./filter_audit.sh
```
