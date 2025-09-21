# PetClinic Fault Injection Tool

This tool provides controlled fault injection capabilities for testing the PetClinic cross-cluster microservices deployment. It helps validate monitoring, alerting, and resilience mechanisms.

## Features

- **Multiple Fault Types**: Latency, exceptions, memory pressure, network partitions, and more
- **Automatic Recovery**: Faults are automatically removed after a specified duration
- **Real-time Monitoring**: Integration with Grafana dashboards to observe fault effects
- **Controlled Testing**: Safe fault injection with automatic cleanup

## Installation

1. Ensure you have access to the Kubernetes clusters
2. Install Python dependencies:
```bash
pip install -r ../verification/requirements.txt
```

## Available Fault Types

### 1. Latency Injection
Injects artificial latency (2-5 seconds) into the customers service (C1) to simulate slow responses.

```bash
python fault-injection-script.py --inject latency_injection --duration 300
```

### 2. Exception Injection
Injects exceptions into the visits service (C2) to simulate application errors.

```bash
python fault-injection-script.py --inject exception_injection --duration 300
```

### 3. Memory Pressure
Creates memory pressure on services to test resource limits and monitoring.

```bash
python fault-injection-script.py --inject memory_pressure --duration 300
```

### 4. Network Partition
Simulates network partition between clusters to test cross-cluster communication resilience.

```bash
python fault-injection-script.py --inject network_partition --duration 300
```

### 5. Service Degradation
Degrades service performance by increasing CPU usage and reducing available resources.

```bash
python fault-injection-script.py --inject service_degradation --duration 300
```

### 6. Cross-Cluster Timeout
Simulates network issues causing timeouts in cross-cluster communication.

```bash
python fault-injection-script.py --inject cross_cluster_timeout --duration 300
```

## Usage Examples

### List Available Fault Types
```bash
python fault-injection-script.py --list
```

### Inject a Fault
```bash
python fault-injection-script.py --inject latency_injection --duration 600
```

### List Active Faults
```bash
python fault-injection-script.py --active
```

### Remove a Specific Fault
```bash
python fault-injection-script.py --remove latency_injection
```

### Remove All Active Faults
```bash
python fault-injection-script.py --remove-all
```

### Generate Fault Report
```bash
python fault-injection-script.py --report fault_report.json
```

## Monitoring Fault Effects

After injecting a fault, monitor the following in Grafana:

### 1. Response Time Metrics
- **Panel**: Response Time Percentiles
- **Expected Behavior**: Increased latency for affected services
- **Alert**: High response time alerts should trigger

### 2. Error Rate Metrics
- **Panel**: Error Rate by Service
- **Expected Behavior**: Increased error rates for affected services
- **Alert**: High error rate alerts should trigger

### 3. Cross-Cluster Communication
- **Panel**: Cross-Cluster Request Flow
- **Expected Behavior**: Reduced or failed cross-cluster requests
- **Alert**: Cross-cluster communication failure alerts should trigger

### 4. Resource Utilization
- **Panel**: Memory Usage by Pod / CPU Usage by Pod
- **Expected Behavior**: Increased resource usage during faults
- **Alert**: High resource usage alerts should trigger

## Expected Monitoring Behavior

### Latency Injection
- Response times increase to 2-5 seconds
- Error rate may increase due to timeouts
- Cross-cluster communication may fail

### Exception Injection
- Error rate spikes significantly
- 5xx HTTP status codes increase
- Service health checks may fail

### Memory Pressure
- Memory usage increases
- Potential out-of-memory errors
- Service restarts may occur

### Network Partition
- Cross-cluster communication fails
- Timeout errors increase
- Service isolation occurs

## Safety Features

1. **Automatic Cleanup**: All faults are automatically removed after the specified duration
2. **Manual Override**: Any fault can be manually removed at any time
3. **Status Tracking**: Active faults are tracked and can be listed
4. **Safe Defaults**: Conservative fault parameters to avoid system damage

## Integration with Monitoring

The fault injection tool is designed to work with the Grafana monitoring setup:

1. **Prometheus Metrics**: Faults trigger metrics changes that Prometheus collects
2. **Grafana Dashboards**: Real-time visualization of fault effects
3. **AlertManager**: Alerts are triggered based on fault-induced metric changes
4. **Custom Alerts**: Specific alerts for cross-cluster communication failures

## Best Practices

1. **Start Small**: Begin with short-duration faults (60-300 seconds)
2. **Monitor Continuously**: Watch Grafana dashboards during fault injection
3. **Document Results**: Record which alerts trigger and response times
4. **Test Recovery**: Verify that systems recover properly after fault removal
5. **Schedule Tests**: Run fault injection during low-traffic periods

## Troubleshooting

### Fault Not Injecting
- Check Kubernetes cluster access
- Verify service configurations
- Check chaos monkey configuration

### Monitoring Not Showing Changes
- Verify Prometheus scraping configuration
- Check Grafana data source settings
- Ensure metrics are being collected

### Faults Not Auto-Removing
- Check system time synchronization
- Verify fault injection script is running
- Manually remove faults if necessary

## Example Testing Workflow

1. **Baseline Monitoring**: Ensure all systems are healthy
2. **Inject Fault**: Choose appropriate fault type and duration
3. **Monitor Effects**: Watch Grafana dashboards for metric changes
4. **Verify Alerts**: Confirm that expected alerts are triggered
5. **Document Results**: Record response times and alert behavior
6. **Cleanup**: Ensure fault is properly removed
7. **Verify Recovery**: Confirm systems return to normal state

## Configuration

The fault injection tool uses the same configuration file as the security verification tool (`config.json`). Ensure the configuration includes:

- Cluster endpoints
- Service namespaces
- Monitoring endpoints
- Cross-cluster communication settings
