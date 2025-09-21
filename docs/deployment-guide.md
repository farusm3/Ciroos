# PetClinic Cross-Cluster Deployment Guide

## Prerequisites

### AWS Account Setup
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- kubectl installed and configured
- Docker installed for image building

### Required AWS Permissions
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ec2:*",
                "iam:*",
                "wafv2:*",
                "route53:*",
                "acm:*",
                "ecr:*",
                "logs:*",
                "cloudwatch:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### Environment Variables
```bash
export AWS_REGION_US_WEST_2=us-west-2
export AWS_REGION_US_EAST_1=us-east-1
export PROJECT_NAME=petclinic-microservices
export ENVIRONMENT=production
```

## Infrastructure Deployment

### Step 1: Deploy Core Infrastructure

1. **Initialize Terraform**:
```bash
cd infrastructure/terraform
terraform init
```

2. **Plan the deployment**:
```bash
terraform plan -var="environment=${ENVIRONMENT}"
```

3. **Deploy the infrastructure**:
```bash
terraform apply -var="environment=${ENVIRONMENT}"
```

4. **Save outputs**:
```bash
terraform output -json > terraform-outputs.json
```

### Step 2: Configure kubectl

1. **Configure C1 cluster**:
```bash
aws eks update-kubeconfig --region us-west-2 --name petclinic-c1
```

2. **Configure C2 cluster**:
```bash
aws eks update-kubeconfig --region us-east-1 --name petclinic-c2
```

3. **Verify cluster access**:
```bash
kubectl get nodes --context=arn:aws:eks:us-west-2:ACCOUNT:cluster/petclinic-c1
kubectl get nodes --context=arn:aws:eks:us-east-1:ACCOUNT:cluster/petclinic-c2
```

### Step 3: Deploy Application Services

1. **Deploy C1 services**:
```bash
kubectl apply -f infrastructure/k8s/c1/namespace.yaml
kubectl apply -f infrastructure/k8s/c1/customers-service.yaml
kubectl apply -f infrastructure/k8s/c1/ingress.yaml
```

2. **Deploy C2 services**:
```bash
kubectl apply -f infrastructure/k8s/c2/namespace.yaml
kubectl apply -f infrastructure/k8s/c2/visits-service.yaml
kubectl apply -f infrastructure/k8s/c2/ingress.yaml
```

3. **Verify deployments**:
```bash
kubectl get pods -n petclinic-c1
kubectl get pods -n petclinic-c2
kubectl get services -n petclinic-c1
kubectl get services -n petclinic-c2
```

### Step 4: Configure Cross-Cluster Communication

1. **Update service endpoints**:
```bash
# Get the actual service IPs
C1_SERVICE_IP=$(kubectl get service customers-service -n petclinic-c1 -o jsonpath='{.spec.clusterIP}')
C2_SERVICE_IP=$(kubectl get service visits-service -n petclinic-c2 -o jsonpath='{.spec.clusterIP}')

# Update external service configurations
kubectl patch endpoints customers-service-external -n petclinic-c1 --type='merge' -p='{"subsets":[{"addresses":[{"ip":"'$C2_SERVICE_IP'"}],"ports":[{"port":8080,"protocol":"TCP"}]}]}'
kubectl patch endpoints visits-service-external -n petclinic-c2 --type='merge' -p='{"subsets":[{"addresses":[{"ip":"'$C1_SERVICE_IP'"}],"ports":[{"port":8080,"protocol":"TCP"}]}]}'
```

### Step 5: Deploy Monitoring Stack

1. **Deploy Prometheus**:
```bash
kubectl create namespace monitoring
kubectl apply -f infrastructure/observability/prometheus-config.yaml
```

2. **Deploy Grafana**:
```bash
# Apply Grafana deployment
kubectl apply -f infrastructure/observability/grafana-deployment.yaml

# Import dashboard
kubectl apply -f infrastructure/observability/grafana-dashboard.json
```

3. **Verify monitoring**:
```bash
kubectl get pods -n monitoring
kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Access Grafana at http://localhost:3000
```

## Security Configuration

### Step 1: Configure WAF

1. **Associate WAF with ALB**:
```bash
# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers --names petclinic-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Associate WAF
aws wafv2 associate-web-acl --resource-arn $ALB_ARN --web-acl-arn $(terraform output -raw waf_web_acl_c1_arn)
```

### Step 2: Configure SSL/TLS

1. **Request SSL Certificate**:
```bash
# Request certificate for internal domains
aws acm request-certificate --domain-name "*.petclinic.internal" --validation-method DNS --region us-west-2
aws acm request-certificate --domain-name "*.petclinic.internal" --validation-method DNS --region us-east-1
```

2. **Update Ingress with Certificate**:
```bash
# Update ingress configurations with certificate ARN
kubectl patch ingress customers-service-ingress -n petclinic-c1 --type='merge' -p='{"metadata":{"annotations":{"alb.ingress.kubernetes.io/certificate-arn":"CERT_ARN"}}}'
```

### Step 3: Configure Network Policies

1. **Apply Network Policies**:
```bash
kubectl apply -f infrastructure/k8s/c1/network-policies.yaml
kubectl apply -f infrastructure/k8s/c2/network-policies.yaml
```

## Testing and Validation

### Step 1: Run Security Verification

1. **Configure verification tool**:
```bash
cd verification
# Update config.json with actual endpoints from terraform outputs
python security_verification_tool.py --config config.json
```

2. **Generate security report**:
```bash
python security_verification_tool.py --report security_report.json
```

### Step 2: Test Cross-Cluster Communication

1. **Test basic connectivity**:
```bash
# Test from C1 to C2
kubectl exec -it deployment/customers-service -n petclinic-c1 -- curl -v http://visits-service-external.petclinic-c2.svc.cluster.local:8080/actuator/health

# Test from C2 to C1
kubectl exec -it deployment/visits-service -n petclinic-c2 -- curl -v http://customers-service-external.petclinic-c1.svc.cluster.local:8080/owners
```

2. **Test business logic**:
```bash
# Create an owner in C1
kubectl exec -it deployment/customers-service -n petclinic-c1 -- curl -X POST http://localhost:8080/owners \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","address":"123 Main St","city":"Portland","telephone":"555-1234"}'

# Get visits from C2 (should call C1 for pet data)
kubectl exec -it deployment/visits-service -n petclinic-c2 -- curl http://localhost:8080/owners/*/pets/1/visits
```

### Step 3: Fault Injection Testing

1. **Inject latency fault**:
```bash
cd fault-injection
python fault-injection-script.py --inject latency_injection --duration 300
```

2. **Monitor effects in Grafana**:
```bash
# Port forward to Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Open browser to http://localhost:3000
# Navigate to "PetClinic Cross-Cluster Monitoring" dashboard
# Observe response time increases
```

3. **Remove fault**:
```bash
python fault-injection-script.py --remove latency_injection
```

## Operational Procedures

### Health Checks

1. **Service Health**:
```bash
# Check all services
kubectl get pods -A
kubectl get services -A
kubectl get ingress -A

# Check specific service health
curl http://customers-service.petclinic-c1.svc.cluster.local:8080/actuator/health
curl http://visits-service.petclinic-c2.svc.cluster.local:8080/actuator/health
```

2. **Cross-Cluster Connectivity**:
```bash
# Test transit gateway connectivity
aws ec2 describe-transit-gateway-attachments --filters "Name=transit-gateway-id,Values=$(terraform output -raw transit_gateway_id)"

# Test network policies
kubectl describe networkpolicy -A
```

### Monitoring and Alerting

1. **Check Prometheus Targets**:
```bash
# Port forward to Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# Access Prometheus at http://localhost:9090
# Navigate to Status > Targets
# Verify all services are being scraped
```

2. **Check AlertManager**:
```bash
# Port forward to AlertManager
kubectl port-forward svc/alertmanager 9093:9093 -n monitoring

# Access AlertManager at http://localhost:9093
# Check active alerts and silences
```

### Backup and Recovery

1. **Backup Configuration**:
```bash
# Backup Kubernetes configurations
kubectl get all -A -o yaml > kubernetes-backup.yaml

# Backup Terraform state
terraform state pull > terraform-state-backup.json
```

2. **Recovery Procedures**:
```bash
# Restore from backup
kubectl apply -f kubernetes-backup.yaml

# Restore Terraform state
terraform state push terraform-state-backup.json
```

## Troubleshooting

### Common Issues

1. **Cross-Cluster Communication Fails**:
```bash
# Check network policies
kubectl describe networkpolicy -A

# Check transit gateway
aws ec2 describe-transit-gateway-route-tables

# Check DNS resolution
kubectl exec -it deployment/customers-service -n petclinic-c1 -- nslookup visits-service-external.petclinic-c2.svc.cluster.local
```

2. **WAF Blocking Legitimate Traffic**:
```bash
# Check WAF logs
aws logs describe-log-groups --log-group-name-prefix aws-waf-logs

# Update WAF rules if needed
aws wafv2 update-web-acl --web-acl-arn $(terraform output -raw waf_web_acl_c1_arn) --rules file://updated-waf-rules.json
```

3. **Monitoring Not Working**:
```bash
# Check Prometheus configuration
kubectl get configmap prometheus-config -n monitoring -o yaml

# Check service discovery
kubectl get endpoints -A

# Check Prometheus targets
curl http://prometheus.monitoring.svc.cluster.local:9090/api/v1/targets
```

### Performance Optimization

1. **Resource Tuning**:
```bash
# Check resource usage
kubectl top pods -A
kubectl top nodes

# Adjust resource limits if needed
kubectl patch deployment customers-service -n petclinic-c1 --type='merge' -p='{"spec":{"template":{"spec":{"containers":[{"name":"customers-service","resources":{"requests":{"memory":"1Gi","cpu":"500m"}}}]}}}}'
```

2. **Network Optimization**:
```bash
# Check network latency
kubectl exec -it deployment/customers-service -n petclinic-c1 -- ping visits-service-external.petclinic-c2.svc.cluster.local

# Optimize transit gateway routes
aws ec2 describe-transit-gateway-routes --transit-gateway-route-table-id $(terraform output -raw tgw_route_table_id)
```

## Maintenance

### Regular Maintenance Tasks

1. **Weekly**:
   - Review security logs
   - Check certificate expiration
   - Update monitoring dashboards
   - Run fault injection tests

2. **Monthly**:
   - Review and update WAF rules
   - Analyze performance metrics
   - Update documentation
   - Security audit

3. **Quarterly**:
   - Disaster recovery testing
   - Capacity planning review
   - Security penetration testing
   - Architecture review

### Updates and Upgrades

1. **Application Updates**:
```bash
# Update container images
kubectl set image deployment/customers-service customers-service=springcommunity/spring-petclinic-customers-service:latest -n petclinic-c1
kubectl set image deployment/visits-service visits-service=springcommunity/spring-petclinic-visits-service:latest -n petclinic-c2

# Verify updates
kubectl rollout status deployment/customers-service -n petclinic-c1
kubectl rollout status deployment/visits-service -n petclinic-c2
```

2. **Infrastructure Updates**:
```bash
# Update Terraform modules
cd infrastructure/terraform
terraform init -upgrade
terraform plan
terraform apply
```

## Security Best Practices

1. **Regular Security Reviews**:
   - Monthly security group reviews
   - Quarterly IAM permission audits
   - Annual penetration testing

2. **Access Management**:
   - Principle of least privilege
   - Regular access reviews
   - Multi-factor authentication

3. **Monitoring and Alerting**:
   - 24/7 security monitoring
   - Automated threat detection
   - Incident response procedures

## Cost Optimization

1. **Resource Right-Sizing**:
   - Regular resource usage analysis
   - Automated scaling policies
   - Reserved instance planning

2. **Monitoring Costs**:
   - CloudWatch cost optimization
   - Log retention policies
   - Data transfer optimization

This deployment guide provides comprehensive instructions for deploying, configuring, and maintaining the PetClinic cross-cluster microservices architecture with enterprise-grade security and monitoring.
