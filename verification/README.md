# PetClinic Cross-Cluster Security Verification Tool

This Python tool verifies the security and connectivity of the PetClinic cross-cluster microservices deployment.

## Features

- **Network Connectivity Testing**: Verifies communication between C1 and C2 clusters
- **Public Access Verification**: Ensures services are not unintentionally exposed to the internet
- **Cross-Cluster Communication Testing**: Validates specific service-to-service communication patterns
- **Security Controls Testing**: Tests WAF, rate limiting, and other security measures
- **Service Health Monitoring**: Checks health endpoints of all services
- **Load Balancer Configuration**: Verifies ALB setup and security configurations

## Installation

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Configure the tool by editing `config.json` with your actual endpoints and configuration.

## Usage

### Basic Usage
```bash
python security_verification_tool.py
```

### With Custom Configuration
```bash
python security_verification_tool.py --config custom_config.json
```

### Generate Detailed Report
```bash
python security_verification_tool.py --report security_report.json
```

### Verbose Output
```bash
python security_verification_tool.py --verbose
```

## Configuration

The `config.json` file contains all the necessary configuration for the verification tool:

- **C1/C2 Cluster Configuration**: Endpoints, regions, VPC CIDRs
- **Cross-Cluster Communication**: Allowed ports, protocols, and CIDRs
- **Security Controls**: WAF, rate limiting, SSL requirements
- **Monitoring**: Prometheus, Grafana, and AlertManager endpoints

## Test Categories

### 1. Network Connectivity
Tests basic network connectivity between clusters using socket connections.

### 2. Public Access Verification
Attempts to access services from public endpoints to ensure they're properly restricted.

### 3. Cross-Cluster Communication
Tests specific communication patterns:
- Visits service (C2) calling customers service (C1)
- Validates API endpoints and data flow

### 4. Security Controls
- **WAF Protection**: Tests against SQL injection, XSS, and other common attacks
- **Rate Limiting**: Sends rapid requests to verify rate limiting works
- **Malicious Payload Blocking**: Tests various malicious input patterns

### 5. Service Health
Checks health endpoints of all services to ensure they're running properly.

### 6. Load Balancer Configuration
Verifies ALB configuration including:
- WAF integration
- SSL/TLS configuration
- Health check setup
- Target group configuration

## Output

The tool provides:
- Real-time console output with test results
- Summary of all tests with pass/fail status
- Optional detailed JSON report

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed or unexpected error occurred

## Example Output

```
🔍 Starting PetClinic Cross-Cluster Security Verification...
============================================================

📋 Network Connectivity
----------------------------------------
Testing network connectivity...
✓ C1→C2: ✓, C2→C1: ✓

📋 Public Access Verification
----------------------------------------
Testing public access restrictions...
✓ Public access to internal-alb-c1.us-west-2.elb.amazonaws.com is properly blocked
✓ Public access to internal-alb-c2.us-east-1.elb.amazonaws.com is properly blocked

📋 Cross-Cluster Communication
----------------------------------------
Testing cross-cluster communication...
✓ Cross-cluster communication working

============================================================
📊 VERIFICATION SUMMARY
============================================================
Tests Passed: 6/6

✅ PASS Network Connectivity
    C1→C2: ✓, C2→C1: ✓

✅ PASS Public Access Blocked
    All public endpoints are properly restricted

✅ PASS Cross-Cluster Communication
    Visits service can communicate with customers service

🎉 All security verifications passed! The system is secure.
```

## Troubleshooting

### Common Issues

1. **Connection Timeouts**: Check that services are running and accessible
2. **Configuration Errors**: Verify all endpoints in config.json are correct
3. **Permission Issues**: Ensure the tool has necessary network access

### Debug Mode

Use the `--verbose` flag for detailed output and debugging information.

## Contributing

To add new verification tests:

1. Add a new test method to the `SecurityVerificationTool` class
2. Follow the naming convention `test_*`
3. Return `True` for success, `False` for failure
4. Add the test to the `run_all_tests()` method
5. Update this README with test description
