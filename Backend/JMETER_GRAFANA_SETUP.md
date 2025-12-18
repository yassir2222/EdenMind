# JMeter with Prometheus and Grafana Monitoring Setup

This guide will help you run JMeter tests and visualize results in Grafana using Prometheus.

## Prerequisites

- Docker and Docker Compose installed
- JMeter installed locally
- Java 8 or higher

## Quick Start

### 1. Start Monitoring Stack (Prometheus + Grafana)

```powershell
cd Backend
docker-compose -f docker-compose-monitoring.yml up -d
```

This will start:
- **Prometheus** on port 9090 (metrics collection)
- **Grafana** on port 3001 (visualization)

### 2. Access Services

**Prometheus**: http://localhost:9090
**Grafana**: http://localhost:3001
- Username: `admin`
- Password: `admin`

### 3. Install JMeter Prometheus Plugin

#### Download the plugin:

1. Download Prometheus Listener JAR from:
   https://github.com/johrstrom/jmeter-prometheus-plugin/releases

   Or download directly:
   ```powershell
   Invoke-WebRequest -Uri "https://github.com/johrstrom/jmeter-prometheus-plugin/releases/latest/download/jmeter-prometheus-plugin-0.6.0.jar" -OutFile "$env:JMETER_HOME\lib\ext\jmeter-prometheus-plugin.jar"
   ```

2. If you don't have `$env:JMETER_HOME` set, manually download and place the JAR file in:
   ```
   <JMETER_INSTALLATION>/lib/ext/
   ```

3. Restart JMeter if it's running

### 4. Configure JMeter Test Plan

#### Option A: Add Prometheus Listener via GUI

1. Open JMeter
2. Open your test plan (e.g., `backend_test_plan.jmx`)
3. Right-click on Test Plan → Add → Listener → Prometheus Listener
4. Configure the listener:
   - **Port**: 9270
   - Leave other settings as default
5. Save the test plan

#### Option B: Add Prometheus Listener Manually to .jmx file

Add this XML inside your `<hashTree>` under the test plan:

```xml
<PrometheusListener guiclass="com.github.johrstrom.listener.gui.PrometheusListenerGui" testclass="com.github.johrstrom.listener.PrometheusListener" testname="Prometheus Listener" enabled="true">
  <collectionProp name="prometheus.collector_definitions"/>
  <stringProp name="prometheus.port">9270</stringProp>
  <boolProp name="prometheus.save_threads">true</boolProp>
  <boolProp name="prometheus.save_jvm">true</boolProp>
</PrometheusListener>
```

### 5. Run JMeter Tests

```powershell
# Navigate to Backend directory
cd C:\Users\karzo\OneDrive\Bureau\study\ed\EdenMind\Backend

# Run backend test plan
jmeter -n -t jmeter/backend_test_plan.jmx -l jmeter/result.jtl

# Or run critical flows test
jmeter -n -t jmeter/critical_flows_performance.jmx -l jmeter/result.jtl
```

**Important**: Keep JMeter running during the test so Prometheus can scrape metrics from port 9270.

### 6. Verify Metrics in Prometheus

1. Open http://localhost:9090
2. Go to Status → Targets
3. Check that `jmeter` target is UP
4. Query metrics by typing in the search: `jmeter_`

Common metrics:
- `jmeter_response_time_milliseconds`
- `jmeter_requests_total`
- `jmeter_errors_total`
- `jmeter_threads_running`

### 7. View Results in Grafana

1. Go to http://localhost:3001
2. Login (admin/admin)
3. Navigate to Dashboards → JMeter Performance Dashboard
4. Watch real-time metrics:
   - Response times
   - Throughput (requests per second)
   - Error rates
   - Active threads

## Alternative: Using JMeter Backend Listener for Prometheus

If the plugin doesn't work, you can also use the built-in Backend Listener with a Prometheus exporter:

1. Add Backend Listener to your test plan
2. Implementation: `org.apache.jmeter.visualizers.backend.graphite.GraphiteBackendListenerClient`
3. Configure:
   - Graphite Host: `localhost`
   - Graphite Port: `2003`
   - Prefix: `jmeter`

Then add a Graphite exporter to the docker-compose.

## Generate HTML Reports (Traditional JMeter Reports)

```powershell
# Generate report from results
jmeter -g jmeter/result.jtl -o jmeter/report
```

Open `jmeter/report/index.html` in browser.

## Stop Monitoring Stack

```powershell
cd Backend
docker-compose -f docker-compose-monitoring.yml down
```

## Configuration Details

### Prometheus
- URL: http://localhost:9090
- Scrape interval: 15s
- JMeter metrics endpoint: http://host.docker.internal:9270/metrics

### Grafana
- URL: http://localhost:3001
- Username: `admin`
- Password: `admin`

## Troubleshooting

### 1. Prometheus can't scrape JMeter metrics

**Symptom**: Target shows as DOWN in Prometheus

**Solutions**:
- Ensure JMeter is running with Prometheus Listener
- Check JMeter is exposing metrics: http://localhost:9270/metrics
- Verify firewall isn't blocking port 9270
- Make sure you're using `host.docker.internal` in prometheus.yml

### 2. No metrics in Grafana

**Solutions**:
- Verify Prometheus datasource is connected: Grafana → Configuration → Data Sources
- Check Prometheus has data: http://localhost:9090
- Ensure JMeter test is running

### 3. Plugin not loading

**Solutions**:
- Verify JAR is in correct directory: `<JMETER_HOME>/lib/ext/`
- Check JMeter logs: `<JMETER_HOME>/bin/jmeter.log`
- Restart JMeter completely
- Verify Java version compatibility

### 4. Port conflicts

**Solutions**:
- Grafana: Change port in docker-compose-monitoring.yml
- Prometheus: Change port in docker-compose-monitoring.yml
- JMeter metrics: Change port in Prometheus Listener configuration

## Useful Commands

```powershell
# Check running containers
docker ps

# View Prometheus logs
docker logs prometheus

# View Grafana logs
docker logs grafana

# Restart containers
docker-compose -f docker-compose-monitoring.yml restart

# Check if JMeter metrics endpoint is working
Invoke-WebRequest -Uri http://localhost:9270/metrics
```

## Next Steps

1. Customize Grafana dashboard panels
2. Add alerting rules in Prometheus
3. Create custom JMeter samplers
4. Set up long-term metrics storage
