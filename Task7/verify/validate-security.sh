#!/bin/bash
echo "Проверка принятия безопасных подов..."
kubectl apply -f ../secure-manifests/
if [ $? -eq 0 ]; then
  echo "SUCCESS: Безопасные поды созданы."
  kubectl delete -f ../secure-manifests/
else
  echo "FAIL: Безопасные поды отклонены."
fi