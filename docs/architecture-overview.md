# PetClinic Cross-Cluster Microservices Architecture

## Overview

This document describes the architecture of the PetClinic cross-cluster microservices deployment, designed to demonstrate enterprise-class application deployment with secure cross-cluster communication, comprehensive monitoring, and fault tolerance.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                AWS Multi-Region Deployment                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────┐                    ┌─────────────────────┐                │
│  │    US-WEST-2 (C1)   │                    │    US-EAST-1 (C2)   │                │
│  │                     │                    │                     │                │
│  │  ┌───────────────┐  │                    │  ┌───────────────┐  │                │
│  │  │      VPC      │  │                    │  │      VPC      │  │                │
│  │  │   10.0.0.0/16 │  │                    │  │   10.1.0.0/16 │  │                │
│  │  │                │  │                    │  │                │  │                │
│  │  │  ┌──────────┐  │  │                    │  │  ┌──────────┐  │  │                │
│  │  │  │Private   │  │  │                    │  │  │Private   │  │  │                │
│  │  │  │Subnets   │  │  │                    │  │  │Subnets   │  │  │                │
│  │  │  │          │  │  │                    │  │  │          │  │  │                │
│  │  │  │┌───────┐ │  │  │                    │  │  │┌───────┐ │  │  │                │
│  │  │  ││  EKS  │ │  │  │                    │  │  ││  EKS  │ │  │  │                │
│  │  │  ││Cluster│ │  │  │                    │  │  ││Cluster│ │  │  │                │
│  │  │  ││  C1   │ │  │  │                    │  │  ││  C2   │ │  │  │                │
│  │  │  │└───────┘ │  │  │                    │  │  │└───────┘ │  │  │                │
│  │  │  │          │  │  │                    │  │  │          │  │  │                │
│  │  │  │┌───────┐ │  │  │                    │  │  │┌───────┐ │  │  │                │
│  │  │  ││Custom │ │  │  │                    │  │  ││Visits │ │  │  │                │
│  │  │  ││Service│ │  │  │                    │  │  ││Service│ │  │  │                │
│  │  │  │└───────┘ │  │  │                    │  │  │└───────┘ │  │  │                │
│  │  │  │          │  │  │                    │  │  │          │  │  │                │
│  │  │  │┌───────┐ │  │  │                    │  │  │┌───────┐ │  │  │                │
│  │  │  ││ ALB   │ │  │  │                    │  │  ││ ALB   │ │  │  │                │
│  │  │  ││+ WAF  │ │  │  │                    │  │  ││+ WAF  │ │  │  │                │
│  │  │  │└───────┘ │  │  │                    │  │  │└───────┘ │  │  │                │
│  │  └──────────┘  │  │                    │  │  └──────────┘  │  │                │
│  └─────────────────────┘                    └─────────────────────┘                │
│           │                                           │                            │
│           │                                           │                            │
│           │            ┌─────────────────────┐        │                            │
│           └────────────┤  Transit Gateway    │────────┘                            │
│                        │                     │                                     │
│                        │  Cross-Region       │                                     │
│                        │  Connectivity       │                                     │
│                        └─────────────────────┘                                     │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                           Monitoring & Observability                       │   │
│  │                                                                             │   │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │   │
│  │  │ Prometheus  │    │   Grafana   │    │AlertManager │    │    Chaos    │  │   │
│  │  │             │    │             │    │             │    │  Monkey     │  │   │
│  │  │ Metrics     │    │ Dashboards  │    │ Alerts      │    │Fault Inject │  │   │
│  │  │ Collection  │    │ Visualization│    │ Management  │    │             │  │   │
│  │  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Cross-Cluster Communication Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           Cross-Cluster Communication Flow                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  User Request ──┐                                                                   │
│                 │                                                                   │
│                 ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                          Load Balancer (ALB)                               │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   WAF Rules     │              │   SSL/TLS       │                      │   │
│  │  │                 │              │   Termination   │                      │   │
│  │  │ • Geo Blocking  │              │                 │                      │   │
│  │  │ • SQL Injection │              │                 │                      │   │
│  │  │ • XSS Protection│              │                 │                      │   │
│  │  │ • Rate Limiting │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                 │                                                                   │
│                 ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Kubernetes Ingress                                 │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Route Rules   │              │   Health Checks │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • Path Matching │              │                 │                      │   │
│  │  │ • Service       │              │                 │                      │   │
│  │  │   Discovery     │              │                 │                      │   │
│  │  │ • Load          │              │                 │                      │   │
│  │  │   Balancing     │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                 │                                                                   │
│                 ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Service Communication                              │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Visits        │              │   Customers     │                      │   │
│  │  │   Service (C2)  │─────────────▶│   Service (C1)  │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • Pet Visit     │              │ • Owner Data    │                      │   │
│  │  │   Management    │              │ • Pet Data      │                      │   │
│  │  │ • Cross-Cluster │              │ • Pet Types     │                      │   │
│  │  │   API Calls     │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  │         │                                   │                              │   │
│  │         │                                   │                              │   │
│  │         ▼                                   ▼                              │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Database      │              │   Database      │                      │   │
│  │  │   (H2 Memory)   │              │   (H2 Memory)   │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                 │                                                                   │
│                 ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Transit Gateway                                    │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   VPC           │              │   VPC           │                      │   │
│  │  │   Attachment    │              │   Attachment    │                      │   │
│  │  │   (C2)          │              │   (C1)          │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  │         │                                   │                              │   │
│  │         └───────────────┬───────────────────┘                              │   │
│  │                         │                                                  │   │
│  │                         ▼                                                  │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │                    Route Table                                     │   │   │
│  │  │                                                                     │   │   │
│  │  │  • C1 to C2: 10.1.0.0/16 → C2 VPC Attachment                      │   │   │
│  │  │  • C2 to C1: 10.0.0.0/16 → C1 VPC Attachment                      │   │   │
│  │  │  • Least Privilege Access Only                                     │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                               Security Layers                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                              Layer 1: WAF                                  │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │   │
│  │  │   Geo Blocking  │  │  SQL Injection  │  │   XSS Protection│             │   │
│  │  │                 │  │   Protection    │  │                 │             │   │
│  │  │ • Block CN/RU   │  │ • Pattern Match │  │ • Script Block  │             │   │
│  │  │ • Allow US Only │  │ • Query Analysis│  │ • Content Filter│             │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘             │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │   │
│  │  │  Rate Limiting  │  │   DDoS          │  │   Custom Rules  │             │   │
│  │  │                 │  │   Protection    │  │                 │             │   │
│  │  │ • 2000 req/min  │  │ • Traffic       │  │ • Business      │             │   │
│  │  │ • IP-based      │  │   Analysis      │  │   Logic         │             │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘             │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Layer 2: Network Security                          │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │  Security       │              │  Network ACLs   │                      │   │
│  │  │  Groups         │              │                 │                      │   │
│  │  │                 │              │ • Inbound Rules │                      │   │
│  │  │ • EKS Cluster   │              │ • Outbound Rules│                      │   │
│  │  │ • Node Groups   │              │ • CIDR Blocking │                      │   │
│  │  │ • ALB Access    │              │ • Port          │                      │   │
│  │  │ • Cross-Cluster │              │   Restrictions  │                      │   │
│  │  │   Only          │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Layer 3: Kubernetes Security                       │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │  Network        │              │  Pod Security   │                      │   │
│  │  │  Policies       │              │  Standards      │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • Ingress Rules │              │ • Non-root User │                      │   │
│  │  │ • Egress Rules  │              │ • Read-only FS  │                      │   │
│  │  │ • Namespace     │              │ • Security      │                      │   │
│  │  │   Isolation     │              │   Context       │                      │   │
│  │  │ • Cross-Cluster │              │ • Resource      │                      │   │
│  │  │   Allowance     │              │   Limits        │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Layer 4: Application Security                      │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │  SSL/TLS        │              │  Input          │                      │   │
│  │  │  Encryption     │              │  Validation     │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • End-to-End    │              │ • Request       │                      │   │
│  │  │ • Certificate   │              │   Sanitization  │                      │   │
│  │  │   Management    │              │ • Data Type     │                      │   │
│  │  │ • Perfect       │              │   Validation    │                      │   │
│  │  │   Forward       │              │ • SQL Injection │                      │   │
│  │  │   Secrecy       │              │   Prevention    │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Monitoring and Observability Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        Monitoring & Observability Stack                            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                            Data Collection                                 │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │   │
│  │  │   Application   │  │   Infrastructure│  │   Custom        │             │   │
│  │  │   Metrics       │  │   Metrics       │  │   Metrics       │             │   │
│  │  │                 │  │                 │  │                 │             │   │
│  │  │ • HTTP Requests │  │ • CPU Usage     │  │ • Business      │             │   │
│  │  │ • Response Time │  │ • Memory Usage  │   │   Metrics      │             │   │
│  │  │ • Error Rates   │  │ • Disk I/O      │  │ • Cross-Cluster │             │   │
│  │  │ • JVM Metrics   │  │ • Network I/O   │  │   Communication │             │   │
│  │  │ • Custom        │  │ • Container     │  │ • User Activity │             │   │
│  │  │   Business      │  │   Metrics       │  │                 │             │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘             │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                               │
│                                    ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                            Prometheus                                      │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Scrape        │              │   Storage       │                      │   │
│  │  │   Configuration │              │                 │                      │   │
│  │  │                 │              │ • Time Series   │                      │   │
│  │  │ • C1 Services   │              │   Database      │                      │   │
│  │  │ • C2 Services   │              │ • Retention     │                      │   │
│  │  │ • Kubernetes    │              │   Policies      │                      │   │
│  │  │   Components    │              │ • Query Engine  │                      │   │
│  │  │ • Custom Jobs   │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Alert Rules   │              │   Recording     │                      │   │
│  │  │                 │              │   Rules         │                      │   │
│  │  │ • Error Rate    │              │                 │                      │   │
│  │  │ • Response Time │              │ • Aggregated    │                      │   │
│  │  │ • Resource      │              │   Metrics       │                      │   │
│  │  │   Usage         │              │ • SLA           │                      │   │
│  │  │ • Cross-Cluster │              │   Calculations  │                      │   │
│  │  │   Failures      │              │                 │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                               │
│                                    ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                          AlertManager                                      │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Alert         │              │   Notification  │                      │   │
│  │  │   Processing    │              │   Channels      │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • Deduplication │              │ • Email         │                      │   │
│  │  │ • Grouping      │              │ • Slack         │                      │   │
│  │  │ • Routing       │              │ • PagerDuty     │                      │   │
│  │  │ • Silence       │              │ • Webhooks      │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                               │
│                                    ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                            Grafana                                        │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │   │
│  │  │   Dashboards    │  │   Alerts        │  │   Data Sources  │             │   │
│  │  │                 │  │                 │  │                 │             │   │
│  │  │ • Overview      │  │ • SLA           │  │ • Prometheus    │             │   │
│  │  │ • Service       │  │   Monitoring    │  │ • AlertManager  │             │   │
│  │  │   Health        │  │ • Anomaly       │  │ • Loki          │             │   │
│  │  │ • Cross-Cluster │  │   Detection     │  │ • Jaeger        │             │   │
│  │  │   Communication │  │ • Business      │  │                 │             │   │
│  │  │ • Resource      │  │   Metrics       │  │                 │             │   │
│  │  │   Utilization   │  │                 │  │                 │             │   │
│  │  │ • Business      │  │                 │  │                 │             │   │
│  │  │   Metrics       │  │                 │  │                 │             │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘             │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         Chaos Engineering                                  │   │
│  │                                                                             │   │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │   │
│  │  │   Fault         │              │   Monitoring    │                      │   │
│  │  │   Injection     │              │   Integration   │                      │   │
│  │  │                 │              │                 │                      │   │
│  │  │ • Latency       │              │ • Real-time     │                      │   │
│  │  │   Injection     │              │   Dashboards    │                      │   │
│  │  │ • Exception     │              │ • Alert         │                      │   │
│  │  │   Injection     │              │   Triggers      │                      │   │
│  │  │ • Memory        │              │ • Recovery      │                      │   │
│  │  │   Pressure      │              │   Validation    │                      │   │
│  │  │ • Network       │              │ • Resilience    │                      │   │
│  │  │   Partition     │              │   Testing       │                      │   │
│  │  └─────────────────┘              └─────────────────┘                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Key Design Principles

### 1. Security-First Design
- **Defense in Depth**: Multiple security layers (WAF, Network ACLs, Kubernetes Network Policies)
- **Least Privilege**: Only necessary permissions and network access
- **Zero Trust**: No implicit trust between services or clusters
- **Encryption**: End-to-end encryption for all communications

### 2. High Availability and Resilience
- **Multi-Region Deployment**: Active-active across two AWS regions
- **Fault Tolerance**: Services designed to handle failures gracefully
- **Circuit Breakers**: Prevent cascade failures
- **Health Checks**: Continuous monitoring of service health

### 3. Observability and Monitoring
- **Comprehensive Metrics**: Application, infrastructure, and business metrics
- **Real-time Dashboards**: Grafana dashboards for operational visibility
- **Proactive Alerting**: Early warning system for issues
- **Chaos Engineering**: Regular fault injection to validate resilience

### 4. Scalability and Performance
- **Horizontal Scaling**: Kubernetes-native scaling capabilities
- **Load Balancing**: Application Load Balancer with health checks
- **Resource Optimization**: Right-sized containers with resource limits
- **Caching**: Strategic caching to reduce cross-cluster calls

## Technology Stack

### Infrastructure
- **AWS EKS**: Managed Kubernetes clusters
- **AWS Transit Gateway**: Cross-region connectivity
- **AWS Application Load Balancer**: Layer 7 load balancing
- **AWS WAF**: Web Application Firewall
- **AWS VPC**: Isolated network environments

### Container Orchestration
- **Kubernetes**: Container orchestration
- **Docker**: Container runtime
- **Helm**: Package management (optional)

### Security
- **AWS WAF**: Web application protection
- **Kubernetes Network Policies**: Network segmentation
- **AWS Security Groups**: Network access control
- **AWS NACLs**: Subnet-level security

### Monitoring and Observability
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and management
- **Spring Boot Actuator**: Application metrics

### Chaos Engineering
- **Chaos Monkey**: Fault injection
- **Custom Scripts**: Targeted fault scenarios
- **Monitoring Integration**: Real-time fault effect observation

## Deployment Architecture

### Cluster C1 (US-WEST-2)
- **Customers Service**: Manages customer and pet data
- **API Gateway**: Routes requests to appropriate services
- **Config Server**: Centralized configuration management
- **Discovery Server**: Service registry and discovery

### Cluster C2 (US-EAST-1)
- **Visits Service**: Manages pet visit records
- **GenAI Service**: AI-powered chatbot interface
- **Admin Server**: Application monitoring and management

### Cross-Cluster Communication
- **Transit Gateway**: Secure, private connectivity
- **Service Mesh**: Optional for advanced traffic management
- **API Gateway**: Centralized request routing
- **Circuit Breakers**: Resilience patterns

## Security Controls

### Network Security
- **Private Subnets**: No direct internet access
- **NAT Gateways**: Outbound internet access only
- **Security Groups**: Granular access control
- **Network ACLs**: Subnet-level filtering

### Application Security
- **WAF Protection**: SQL injection, XSS, DDoS protection
- **Rate Limiting**: Request throttling
- **SSL/TLS**: End-to-end encryption
- **Input Validation**: Request sanitization

### Access Control
- **IAM Roles**: Least privilege access
- **Kubernetes RBAC**: Role-based access control
- **Service Accounts**: Secure service-to-service communication
- **VPC Endpoints**: Private AWS service access

## Monitoring Strategy

### Metrics Collection
- **Application Metrics**: Response time, error rate, throughput
- **Infrastructure Metrics**: CPU, memory, disk, network
- **Business Metrics**: User activity, service usage
- **Custom Metrics**: Cross-cluster communication health

### Alerting Strategy
- **SLA Monitoring**: Service level agreement tracking
- **Anomaly Detection**: Unusual pattern identification
- **Escalation Policies**: Tiered alert response
- **Integration**: Email, Slack, PagerDuty notifications

### Dashboard Strategy
- **Executive Dashboard**: High-level business metrics
- **Operations Dashboard**: Technical metrics and health
- **Development Dashboard**: Application-specific metrics
- **Security Dashboard**: Security events and compliance

## Disaster Recovery

### Backup Strategy
- **Database Backups**: Regular automated backups
- **Configuration Backups**: Infrastructure as Code
- **Application Backups**: Container images and configurations
- **Cross-Region Replication**: Data replication for RTO/RPO

### Recovery Procedures
- **RTO Target**: 15 minutes for critical services
- **RPO Target**: 5 minutes data loss maximum
- **Automated Failover**: Health check-based switching
- **Manual Override**: Emergency procedures for complex scenarios

## Compliance and Governance

### Security Compliance
- **AWS Well-Architected**: Security pillar alignment
- **Industry Standards**: SOC 2, PCI DSS considerations
- **Data Protection**: GDPR, CCPA compliance
- **Audit Trail**: Comprehensive logging and monitoring

### Operational Governance
- **Change Management**: Controlled deployment processes
- **Access Review**: Regular permission audits
- **Security Scanning**: Vulnerability assessments
- **Incident Response**: Documented procedures and playbooks
