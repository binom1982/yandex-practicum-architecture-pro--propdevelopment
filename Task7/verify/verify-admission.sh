#!/bin/bash
echo "Проверка отклонения небезопасных подов..."
kubectl apply -f ../insecure-manifests/ 2>&1 | grep -i "denied\|error"
if [ $? -eq 0 ]; then
  echo "SUCCESS: Небезопасные поды отклонены."
else
  echo "FAIL: Небезопасные поды прошли валидацию."
fi