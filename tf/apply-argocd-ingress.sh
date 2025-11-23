#!/bin/bash

# Wait for ALB Controller to be ready
echo "Waiting for AWS Load Balancer Controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

# Apply Argo CD Ingress
echo "Applying Argo CD Ingress..."
kubectl apply -f ../argocd-ingress.yaml

# Wait for Ingress to be created
echo "Waiting for Ingress to be created..."
sleep 10

# Wait for ALB to be provisioned (up to 5 minutes)
echo "Waiting for ALB to be provisioned..."
for i in {1..30}; do
  ARGOCD_URL=$(kubectl get ingress -n argocd argocd-server-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [ ! -z "$ARGOCD_URL" ]; then
    break
  fi
  echo "Still waiting for ALB... ($i/30)"
  sleep 10
done

if [ -z "$ARGOCD_URL" ]; then
  echo "Warning: ALB not provisioned yet. Check status with:"
  echo "kubectl describe ingress -n argocd argocd-server-ingress"
  exit 0
fi

echo "================================================"
echo "Argo CD is accessible at: http://$ARGOCD_URL"
echo "================================================"

# Get Argo CD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
