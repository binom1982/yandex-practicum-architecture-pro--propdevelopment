# Аудит безопасности контейнеров (PropDevelopment)

## Структура

- `01-create-namespace.yaml`: Создание NS с PSS restricted.
- `insecure-manifests/`: Примеры нарушений (privileged, hostPath, root).
- `secure-manifests/`: Исправленные версии (соответствуют PSS restricted).
- `gatekeeper/`: Политики OPA (ConstraintTemplates и Constraints).
- `verify/`: Скрипты проверки.

## Инструкция

1. Создать namespace: `kubectl apply -f 01-create-namespace.yaml`
2. Установить Gatekeeper (предварительно).
3. Применить политики: `kubectl apply -f gatekeeper/`
4. Проверка блокировки: `bash verify/verify-admission.sh`
5. Проверка допуска: `bash verify/validate-security.sh`

## Соответствие

- PSS Restricted: Через лейблы namespace.
- OPA Gatekeeper: Запрет privileged, hostPath, требование non-root.
