#!/usr/bin/env python3
"""
Скрипт фильтрации audit.log для выявления подозрительных событий
в Kubernetes-кластере PropDevelopment.
"""

import json
import sys
from pathlib import Path


def is_suspicious(event: dict) -> bool:
    """Проверяет, является ли событие подозрительным."""
    obj_ref = event.get('objectRef', {})
    verb = event.get('verb')
    user = event.get('user', {}).get('username', '')
    request_obj = event.get('requestObject', {})

    # 1. Доступ к secrets
    if obj_ref.get('resource') == 'secrets' and verb == 'get':
        return True

    # 2. Создание привилегированных подов
    if (verb == 'create' and obj_ref.get('resource') == 'pods'):
        containers = request_obj.get('spec', {}).get('containers', [])
        for container in containers:
            if container.get('securityContext', {}).get('privileged') is True:
                return True

    # 3. kubectl exec в системные поды
    if (verb == 'create' and obj_ref.get('subresource') == 'exec'
            and obj_ref.get('namespace') == 'kube-system'):
        return True

    # 4. Удаление/изменение audit-policy
    if (obj_ref.get('resource') == 'configmaps'
            and 'audit' in obj_ref.get('name', '').lower()):
        if verb in ('delete', 'update', 'patch'):
            return True

    # 5. Создание RoleBinding с cluster-admin
    if (verb == 'create' and obj_ref.get('resource') == 'rolebindings'):
        role_ref = request_obj.get('roleRef', {})
        if role_ref.get('name') == 'cluster-admin':
            return True

    return False


def main():
    audit_log = Path('audit.log')
    output_file = Path('audit-extract.json')

    if not audit_log.exists():
        print(f"❌ Файл {audit_log} не найден", file=sys.stderr)
        sys.exit(1)

    suspicious_events = []

    with open(audit_log, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
                if is_suspicious(event):
                    suspicious_events.append(event)
            except json.JSONDecodeError as e:
                print(f"⚠️ Ошибка парсинга строки {line_num}: {e}", file=sys.stderr)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(suspicious_events, f, indent=2, ensure_ascii=False)

    print(f"✅ Найдено {len(suspicious_events)} подозрительных событий")
    print(f"📁 Результат сохранён в {output_file}")


if __name__ == '__main__':
    main()