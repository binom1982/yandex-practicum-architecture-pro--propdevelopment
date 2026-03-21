# Аудит активности пользователей и обнаружение инцидентов

## Запустить Minikube с политикой аудита# Удалить ранее запущенный кластер

```shell
 Удаление старого кластера
minikube delete --all --purge
minikube stop

# Запустик с монтированием файла   
MSYS_NO_PATHCONV=1 minikube start \
  --driver=docker \
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/var/log/audit.log \
  --mount \
  --mount-string="//c/Users/binom/YandexDisk/Курсы/Архитектура\ ПО/Спринт\ 05\ Проектная\ работа\ PropDevelopment/yandex-practicum-architecture-pro--propdevelopment/Task6:/etc/kubernetes" \
  --mount-string="//c/Users/binom/YandexDisk/Курсы/Архитектура\ ПО/Спринт\ 05\ Проектная\ работа\ PropDevelopment/yandex-practicum-architecture-pro--propdevelopment/Task6/audit-logs:/var/log"
```

Смонтировать на windows получилось только через PowerShell

```powershell
# Использовать короткий путь без пробелов/кириллицы
$CONFIG_PATH = "C:\Users\binom\YandexDisk\Курсы\Архитектура ПО\Спринт 05 Проектная работа PropDevelopment\yandex-practicum-architecture-pro--propdevelopment\Task6"
New-Item -ItemType Directory -Force -Path $CONFIG_PATH
Copy-Item .\audit-policy.yaml -Destination "$CONFIG_PATH/"

minikube delete --purge
minikube start `
  --driver=docker `
  --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml `
  --extra-config=apiserver.audit-log-path=/var/log/audit.log `
  --mount `
  --mount-string="${CONFIG_PATH}:/etc/kubernetes" `
  --mount-string="${CONFIG_PATH}\audit-logs:/var/log"
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
