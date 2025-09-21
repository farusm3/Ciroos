# PetClinic Cross-Cluster Microservices Deployment

## Overview

This repository contains a comprehensive enterprise-class microservices deployment demonstrating secure cross-cluster communication between two independent Kubernetes clusters in different AWS regions. The deployment includes advanced security controls, comprehensive monitoring, and fault injection capabilities.

## 🏗️ Architecture

The solution implements a cross-cluster microservices architecture with the following key components:

- **Cluster C1 (US-WEST-2)**: Customers Service, API Gateway, Config Server, Discovery Server
- **Cluster C2 (US-EAST-1)**: Visits Service, GenAI Service, Admin Server
- **Cross-Cluster Communication**: Secure connectivity via AWS Transit Gateway
- **Security**: Multi-layered security with WAF, Network ACLs, and Kubernetes Network Policies
- **Monitoring**: Prometheus, Grafana, and AlertManager for comprehensive observability
- **Fault Injection**: Chaos engineering for resilience testing

## 📋 Requirements Met

### ✅ Infrastructure Requirements
- [x] Two independent Kubernetes clusters (C1 and C2) in different AWS regions
- [x] Enterprise-class application deployment
- [x] Cross-cluster service communication (C1 ↔ C2)
- [x] Clear, testable requests and responses

### ✅ Private Connectivity
- [x] Private network communication using AWS Transit Gateway
- [x] Least-privilege network access principles
- [x] VPC isolation and secure routing

### ✅ Security Controls
- [x] WAF protection with comprehensive rules
- [x] Security groups and network ACLs
- [x] Endpoint policies and access restrictions
- [x] No public network exposure of services

### ✅ Verification
- [x] Python-based verification tool
- [x] No unintended public access path validation
- [x] C1 → C2 communication validation

### ✅ Observability
- [x] Grafana dashboards and monitoring
- [x] Log and metrics collection
- [x] Cross-cluster monitoring setup

### ✅ Fault Testing
- [x] Fault injection mechanisms
- [x] Monitoring and alerting validation
- [x] Fault detection demonstration

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- Python 3.8+
- Docker

### 1. Deploy Infrastructure
```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 2. Configure Kubernetes Access
```bash
# C1 Cluster
aws eks update-kubeconfig --region us-west-2 --name petclinic-c1

# C2 Cluster  
aws eks update-kubeconfig --region us-east-1 --name petclinic-c2
```

### 3. Deploy Applications
```bash
# Deploy C1 services
kubectl apply -f infrastructure/k8s/c1/

# Deploy C2 services
kubectl apply -f infrastructure/k8s/c2/
```

### 4. Setup Monitoring
```bash
kubectl apply -f infrastructure/observability/
```

### 5. Run Verification
```bash
cd verification
pip install -r requirements.txt
python security_verification_tool.py
```

### 6. Test Fault Injection
```bash
cd fault-injection
python fault-injection-script.py --inject latency_injection --duration 300
```

## 📁 Repository Structure

```
├── infrastructure/
│   ├── terraform/                 # Infrastructure as Code
│   │   ├── main.tf               # Main Terraform configuration
│   │   └── modules/              # Terraform modules
│   │       ├── eks-cluster/      # EKS cluster module
│   │       ├── transit-gateway/  # Cross-region connectivity
│   │       └── security-controls/ # WAF, NACLs, VPC endpoints
│   ├── k8s/                      # Kubernetes manifests
│   │   ├── c1/                   # Cluster C1 configurations
│   │   └── c2/                   # Cluster C2 configurations
│   └── observability/            # Monitoring stack
│       ├── prometheus-config.yaml
│       └── grafana-dashboard.json
├── verification/                 # Security verification tools
│   ├── security_verification_tool.py
│   ├── config.json
│   └── requirements.txt
├── fault-injection/              # Chaos engineering tools
│   ├── fault-injection-script.py
│   ├── chaos-engineering.yaml
│   └── README.md
├── docs/                         # Documentation
│   ├── architecture-overview.md
│   ├── deployment-guide.md
│   └── design-choices-and-tradeoffs.md
└── spring-petclinic-microservices/ # Original application code
```

## 🔧 Key Components

### Infrastructure
- **AWS EKS**: Managed Kubernetes clusters
- **Transit Gateway**: Cross-region connectivity
- **Application Load Balancer**: Layer 7 load balancing
- **WAF**: Web application firewall
- **VPC**: Isolated network environments

### Applications
- **Customers Service (C1)**: Manages customer and pet data
- **Visits Service (C2)**: Manages pet visit records
- **Cross-Cluster Communication**: Visits service calls customers service

### Security
- **WAF Rules**: Geo-blocking, SQL injection, XSS protection, rate limiting
- **Network ACLs**: Subnet-level security controls
- **Security Groups**: Instance-level access control
- **Kubernetes Network Policies**: Pod-level network segmentation

### Monitoring
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and management
- **Custom Dashboards**: Cross-cluster monitoring

## 🔍 Verification and Testing

### Security Verification Tool
The Python verification tool validates:
- Network connectivity between clusters
- Public access restrictions
- Cross-cluster communication functionality
- Security controls effectiveness
- Service health and performance

```bash
cd verification
python security_verification_tool.py --config config.json --report security_report.json
```

### Fault Injection Testing
Comprehensive fault injection capabilities:
- Latency injection
- Exception injection
- Memory pressure
- Network partition simulation
- Service degradation testing

```bash
cd fault-injection
python fault-injection-script.py --inject latency_injection --duration 300
```

## 📊 Monitoring and Observability

### Grafana Dashboards
- **Cross-Cluster Communication Health**: Real-time connectivity monitoring
- **Error Rate by Service**: Service-specific error tracking
- **Response Time Percentiles**: Performance monitoring
- **Resource Utilization**: CPU and memory usage tracking
- **Business Metrics**: Application-specific KPIs

### Prometheus Metrics
- Application metrics (HTTP requests, response times, errors)
- Infrastructure metrics (CPU, memory, disk, network)
- Custom business metrics
- Cross-cluster communication metrics

### Alerting
- High error rate detection
- Service downtime alerts
- Cross-cluster communication failures
- Resource utilization thresholds

## 🛡️ Security Features

### Multi-Layer Security
1. **WAF Layer**: Web application protection
2. **Network Layer**: Security groups and NACLs
3. **Kubernetes Layer**: Network policies and RBAC
4. **Application Layer**: Input validation and security headers

### Access Control
- Least privilege access model
- Role-based access control (RBAC)
- Service-to-service authentication
- Network segmentation

### Compliance
- AWS Well-Architected Security Pillar
- Industry security best practices
- Comprehensive audit trails
- Security documentation

## 🧪 Chaos Engineering

### Fault Injection Types
- **Latency Injection**: Simulate slow responses
- **Exception Injection**: Simulate application errors
- **Memory Pressure**: Test resource limits
- **Network Partition**: Simulate connectivity issues
- **Service Degradation**: Test performance under load

### Monitoring Integration
- Real-time fault effect observation
- Automated alert triggering
- Recovery validation
- Resilience measurement

## 📈 Performance and Scalability

### Horizontal Scaling
- Kubernetes-native scaling capabilities
- Load balancer health checks
- Resource optimization
- Auto-scaling policies

### Cross-Cluster Optimization
- Efficient routing via Transit Gateway
- Connection pooling
- Circuit breaker patterns
- Retry mechanisms

## 🔄 Deployment and Operations

### Infrastructure as Code
- Terraform for infrastructure management
- Version-controlled configurations
- Reproducible deployments
- Environment consistency

### CI/CD Integration
- Automated testing pipeline
- Security scanning integration
- Deployment automation
- Rollback capabilities

### Operational Procedures
- Health check procedures
- Monitoring and alerting
- Backup and recovery
- Incident response

## 📚 Documentation

### Comprehensive Documentation
- [Architecture Overview](docs/architecture-overview.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Design Choices and Trade-offs](docs/design-choices-and-tradeoffs.md)
- [Security Verification Tool](verification/README.md)
- [Fault Injection Guide](fault-injection/README.md)

## 🎯 Demo Scenarios

### Live Demo Checklist
1. **Application Access**: Show running application with end-user access
2. **WAF Status**: Display WAF configuration and blocked requests
3. **ALB Configuration**: Show load balancer setup and health checks
4. **Grafana Dashboards**: Demonstrate real-time monitoring
5. **Security Validation**: Confirm only intended C1→C2 communication
6. **Fault Injection**: Inject fault and show detection in Grafana
7. **Recovery**: Demonstrate automatic fault removal and recovery

### Key Metrics to Monitor
- Cross-cluster request success rate
- Response time percentiles
- Error rates by service
- Resource utilization
- Security event logs

## 🚨 Troubleshooting

### Common Issues
1. **Cross-cluster connectivity**: Check Transit Gateway routes
2. **WAF blocking**: Review WAF logs and rules
3. **Monitoring gaps**: Verify Prometheus targets
4. **Service discovery**: Check Kubernetes DNS resolution

### Support Resources
- Comprehensive troubleshooting guide in deployment documentation
- Security verification tool for automated diagnostics
- Monitoring dashboards for real-time issue identification

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request

### Testing Requirements
- Run security verification tool
- Test fault injection scenarios
- Validate monitoring setup
- Update documentation

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Spring PetClinic team for the original microservices application
- AWS for infrastructure services
- Kubernetes community for container orchestration
- Prometheus and Grafana communities for monitoring tools

---

## 📞 Support

For questions, issues, or contributions:
- Create an issue in the repository
- Review the comprehensive documentation
- Use the verification tools for diagnostics
- Check monitoring dashboards for system status

**Note**: This is a demonstration deployment. For production use, implement persistent databases, enhanced security controls, and comprehensive backup strategies.
