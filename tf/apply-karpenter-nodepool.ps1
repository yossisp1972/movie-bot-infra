# Get cluster name from Terraform output
$CLUSTER_NAME = terraform output -raw cluster_name

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-1

# Replace placeholder in NodePool YAML and apply
(Get-Content ..\karpenter\nodepool.yaml) -replace '\${CLUSTER_NAME}', $CLUSTER_NAME | kubectl apply -f -

Write-Host "Karpenter NodePool configured with Spot instances for cluster: $CLUSTER_NAME"
