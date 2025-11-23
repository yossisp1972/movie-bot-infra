#!/bin/bash

# Apply Argo CD Ingress after ALB controller is ready
echo "Applying Argo CD Ingress..."
kubectl apply -f ../argocd-ingress.yaml

# Wait for ALB to be provisioned
echo "Waiting for ALB to be created..."
sleep 30

# Get ALB DNS name
ARGOCD_URL=$(kubectl get ingress -n argocd argocd-server-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "================================================"
echo "Argo CD is accessible at: http://$ARGOCD_URL"
echo "================================================"

# Get Argo CD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
