
### Tools

https://github.com/openargus
https://www.solarwinds.com/netflow-traffic-analyzer/use-cases/what-is-netflow
https://ragraph.ratio-case.nl/
https://securityonionsolutions.com/

- Full packet logging 
	- Collect data transferred between system => generate signature, monitor activity, identify stolen data
	- Collect evidence to support an internal investigation or legal matter

### Questions to deploy network sensor

- Where are the network egress points?
- Does the network use specific routes to control internal traffic? External traffic?
- Are “choke points” available at suborganization or administrative boundaries?
- How is endpoint traffic encapsulated when it arrives at firewalls or “choke points”? Is VLAN trunking in use, for example?
- Where are network address translation devices in use? Web proxies?

Then verify : 

- Is the monitor receiving the traffic that you intend to monitor ? 
- Is the hardware responsive enough to accomplish the monitoring goals you set?