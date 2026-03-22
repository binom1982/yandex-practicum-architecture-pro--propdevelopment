#!/bin/bash

# Создаем namespace для изоляции
kubectl create namespace prop-dev-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=prop-dev-ns

# 1. Front-end
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port=80 --restart=Always

# 2. Back-end-api
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port=80 --restart=Always

# 3. Admin-front-end
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port=80 --restart=Always

# 4. Admin-back-end-api
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port=80 --restart=Always

# Проверка создания
kubectl get pods --show-labels
kubectl get services