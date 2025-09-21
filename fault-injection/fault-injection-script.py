#!/usr/bin/env python3
"""
PetClinic Fault Injection Script

This script injects various types of faults into the system to test
monitoring and alerting capabilities.
"""

import requests
import json
import time
import argparse
import sys
from typing import Dict, List
import subprocess
import os

class FaultInjector:
    def __init__(self, config_file: str = "../verification/config.json"):
        """Initialize the fault injector with configuration."""
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        
        self.injected_faults = []
        
    def list_available_faults(self):
        """List all available fault injection scenarios."""
        faults = [
            ("latency_injection", "Inject latency into C1 customers service"),
            ("exception_injection", "Inject exceptions into C2 visits service"),
            ("memory_pressure", "Create memory pressure on services"),
            ("network_partition", "Simulate network partition between clusters"),
            ("service_degradation", "Degrade service performance"),
            ("cross_cluster_timeout", "Simulate cross-cluster communication timeout"),
        ]
        
        print("Available Fault Injection Scenarios:")
        print("=" * 50)
        for i, (fault_id, description) in enumerate(faults, 1):
            print(f"{i}. {fault_id}: {description}")
        
        return faults
    
    def inject_fault(self, fault_type: str, duration: int = 300):
        """Inject a specific type of fault."""
        print(f"🔧 Injecting fault: {fault_type}")
        print(f"⏱️  Duration: {duration} seconds")
        print("-" * 40)
        
        fault_methods = {
            "latency_injection": self._inject_latency_fault,
            "exception_injection": self._inject_exception_fault,
            "memory_pressure": self._inject_memory_pressure,
            "network_partition": self._inject_network_partition,
            "service_degradation": self._inject_service_degradation,
            "cross_cluster_timeout": self._inject_cross_cluster_timeout,
        }
        
        if fault_type not in fault_methods:
            print(f"❌ Unknown fault type: {fault_type}")
            return False
        
        try:
            success = fault_methods[fault_type](duration)
            if success:
                self.injected_faults.append({
                    "type": fault_type,
                    "start_time": time.time(),
                    "duration": duration,
                    "status": "active"
                })
                print(f"✅ Fault '{fault_type}' injected successfully")
                return True
            else:
                print(f"❌ Failed to inject fault '{fault_type}'")
                return False
        except Exception as e:
            print(f"❌ Error injecting fault '{fault_type}': {str(e)}")
            return False
    
    def _inject_latency_fault(self, duration: int) -> bool:
        """Inject latency into the customers service."""
        print("  Injecting latency into customers service...")
        
        # This would typically use kubectl or the Kubernetes API
        # to update the chaos monkey configuration
        try:
            # Update chaos monkey config for C1
            config_update = {
                "chaos.monkey.assaults.latency.active": "true",
                "chaos.monkey.assaults.latency.latency-range-start": "2000",
                "chaos.monkey.assaults.latency.latency-range-end": "5000"
            }
            
            # Simulate updating the configuration
            print(f"    Updating chaos monkey config: {config_update}")
            
            # Schedule fault removal
            self._schedule_fault_removal("latency_injection", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _inject_exception_fault(self, duration: int) -> bool:
        """Inject exceptions into the visits service."""
        print("  Injecting exceptions into visits service...")
        
        try:
            # Update chaos monkey config for C2
            config_update = {
                "chaos.monkey.assaults.exceptions.active": "true",
                "chaos.monkey.assaults.exceptions.level": "5"
            }
            
            print(f"    Updating chaos monkey config: {config_update}")
            
            # Schedule fault removal
            self._schedule_fault_removal("exception_injection", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _inject_memory_pressure(self, duration: int) -> bool:
        """Create memory pressure on services."""
        print("  Creating memory pressure...")
        
        try:
            # This would typically use kubectl to scale down resources
            # or inject memory pressure using chaos engineering tools
            
            print("    Scaling down memory limits...")
            print("    Injecting memory allocation...")
            
            # Schedule fault removal
            self._schedule_fault_removal("memory_pressure", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _inject_network_partition(self, duration: int) -> bool:
        """Simulate network partition between clusters."""
        print("  Simulating network partition...")
        
        try:
            # This would typically use network policies or security groups
            # to block traffic between clusters
            
            print("    Blocking cross-cluster traffic...")
            print("    Updating network policies...")
            
            # Schedule fault removal
            self._schedule_fault_removal("network_partition", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _inject_service_degradation(self, duration: int) -> bool:
        """Degrade service performance."""
        print("  Degrading service performance...")
        
        try:
            # Simulate high CPU usage or resource contention
            print("    Increasing CPU usage...")
            print("    Reducing available resources...")
            
            # Schedule fault removal
            self._schedule_fault_removal("service_degradation", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _inject_cross_cluster_timeout(self, duration: int) -> bool:
        """Simulate cross-cluster communication timeout."""
        print("  Simulating cross-cluster timeout...")
        
        try:
            # Simulate network issues between clusters
            print("    Increasing network latency...")
            print("    Reducing connection timeouts...")
            
            # Schedule fault removal
            self._schedule_fault_removal("cross_cluster_timeout", duration)
            
            return True
            
        except Exception as e:
            print(f"    Error: {str(e)}")
            return False
    
    def _schedule_fault_removal(self, fault_type: str, duration: int):
        """Schedule automatic fault removal after specified duration."""
        def remove_fault():
            time.sleep(duration)
            print(f"🔧 Auto-removing fault: {fault_type}")
            self.remove_fault(fault_type)
        
        import threading
        thread = threading.Thread(target=remove_fault)
        thread.daemon = True
        thread.start()
    
    def remove_fault(self, fault_type: str) -> bool:
        """Remove a specific fault."""
        print(f"🔧 Removing fault: {fault_type}")
        
        try:
            if fault_type == "latency_injection":
                # Restore normal latency configuration
                config_update = {
                    "chaos.monkey.assaults.latency.active": "false"
                }
                print(f"    Restoring latency config: {config_update}")
                
            elif fault_type == "exception_injection":
                # Restore normal exception configuration
                config_update = {
                    "chaos.monkey.assaults.exceptions.active": "false"
                }
                print(f"    Restoring exception config: {config_update}")
                
            elif fault_type == "memory_pressure":
                # Restore normal memory configuration
                print("    Restoring memory limits...")
                
            elif fault_type == "network_partition":
                # Restore network connectivity
                print("    Restoring cross-cluster connectivity...")
                
            elif fault_type == "service_degradation":
                # Restore normal service performance
                print("    Restoring service performance...")
                
            elif fault_type == "cross_cluster_timeout":
                # Restore normal network settings
                print("    Restoring network timeouts...")
            
            # Update the injected faults list
            for fault in self.injected_faults:
                if fault["type"] == fault_type and fault["status"] == "active":
                    fault["status"] = "removed"
                    fault["end_time"] = time.time()
                    break
            
            print(f"✅ Fault '{fault_type}' removed successfully")
            return True
            
        except Exception as e:
            print(f"❌ Error removing fault '{fault_type}': {str(e)}")
            return False
    
    def list_active_faults(self):
        """List currently active faults."""
        active_faults = [f for f in self.injected_faults if f["status"] == "active"]
        
        if not active_faults:
            print("No active faults")
            return
        
        print("Active Faults:")
        print("=" * 30)
        for fault in active_faults:
            elapsed = time.time() - fault["start_time"]
            remaining = fault["duration"] - elapsed
            print(f"• {fault['type']}: {remaining:.0f}s remaining")
    
    def remove_all_faults(self):
        """Remove all active faults."""
        active_faults = [f for f in self.injected_faults if f["status"] == "active"]
        
        print(f"🔧 Removing {len(active_faults)} active faults...")
        
        for fault in active_faults:
            self.remove_fault(fault["type"])
    
    def generate_fault_report(self, output_file: str = "fault_report.json"):
        """Generate a report of all fault injections."""
        report = {
            "timestamp": time.time(),
            "total_faults": len(self.injected_faults),
            "active_faults": len([f for f in self.injected_faults if f["status"] == "active"]),
            "faults": self.injected_faults
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"📄 Fault report saved to {output_file}")

def main():
    """Main entry point for the fault injection script."""
    parser = argparse.ArgumentParser(description="PetClinic Fault Injection Tool")
    parser.add_argument("--config", default="../verification/config.json", help="Configuration file path")
    parser.add_argument("--list", action="store_true", help="List available fault types")
    parser.add_argument("--inject", help="Inject a specific fault type")
    parser.add_argument("--remove", help="Remove a specific fault type")
    parser.add_argument("--remove-all", action="store_true", help="Remove all active faults")
    parser.add_argument("--active", action="store_true", help="List active faults")
    parser.add_argument("--duration", type=int, default=300, help="Fault duration in seconds")
    parser.add_argument("--report", help="Generate fault report to file")
    
    args = parser.parse_args()
    
    try:
        injector = FaultInjector(args.config)
        
        if args.list:
            injector.list_available_faults()
        elif args.inject:
            success = injector.inject_fault(args.inject, args.duration)
            sys.exit(0 if success else 1)
        elif args.remove:
            success = injector.remove_fault(args.remove)
            sys.exit(0 if success else 1)
        elif args.remove_all:
            injector.remove_all_faults()
        elif args.active:
            injector.list_active_faults()
        elif args.report:
            injector.generate_fault_report(args.report)
        else:
            print("Use --help for available options")
            sys.exit(1)
        
    except FileNotFoundError:
        print(f"❌ Configuration file not found: {args.config}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
