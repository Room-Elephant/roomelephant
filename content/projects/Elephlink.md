+++
title = "Elephlink"
tags = ["java", "dns", "cloudflare", "dns-updater"]
topics = ["projects"]
featured = true
date = "2025-06-24"
+++

<div align="center">
	<img src="elephlink.png"  height="150"  />
	<h1>Elephlink</h1>
  <p><b>A powerful, lightweight Dynamic DNS client that uses the Cloudflare API to keep your domain name pointing to your home network.</p>
  <p>It allows you to reliably access self-hosted services (like a NAS, media server, or smart home hub) via a custom domain, even when
your Internet Service Provider assigns you a dynamic IP address.</p>
</div>

## 🔥 Why Elephlink?

- **Cost-Effective**: No need to pay your ISP for a static IP address.
- **Effortless**: Runs on a schedule to automatically detect IP changes and update your DNS records in seconds.
- **Flexible**: Supports multiple domains, configurable IP detection services and cron-based scheduling.
- **Secure**: Works with modern Cloudflare API tokens for granular, secure access.
- **Footprint**: Low footprint on your system.

## 🚀 Features

- Seamless integration with the Cloudflare v4 API.
- Supports multiple DNS records across different domains.
- Periodic IP checking with cron-based scheduling.
- Pluggable IP detection services using a configurable list of providers.
- All configuration is external, making it perfect for containerized deployments.

## ⚙️ How it Works

1. **IP Detection**: Regularly checks your public IP using one or more external services (at your choice).
2. **Cloudflare Validation**: Authenticates with Cloudflare and verifies your DNS records.
3. **DNS Update**: If your public IP changes, automatically updates the specified Cloudflare DNS records.
4. **Scheduling**: Runs on a user-defined schedule (e.g. every few minutes) using cron expressions.

## 🏃 Getting Started

### Prerequisites

- A Cloudflare account: https://dash.cloudflare.com/sign-up
- A registered domain name managed by Cloudflare.
- An `A` record created in your Cloudflare DNS dashboard that you want to keep updated. The initial IP can be a placeholder like `1.1.1.1`.
- A Cloudflare API Token: https://dash.cloudflare.com/profile/api-tokens

| Type | Name       | Content | Proxy status | TTL  | 
|------|------------|---------|--------------|------|
| A    | domain.com | 1.1.1.1 | Proxied      | Auto |

### Running on Docker

1. **Running in Docker**

```bash
docker run \
  --name elephlink \
  --restart unless-stopped \
  -v /path/to/config/dir/:/config \
  -e JAVA_OPTS=-Xmx15m \
  roomelephant/elephlink:latest
```

or

```yml
services:
  elephlink:
    image: roomelephant/elephlink:latest
    volumes:
      - /path/to/config/dir/cloudflare.yml:/config/cloudflare.yml
      - /path/to/config/dir/ip-services.yml:/config/ip-services.yml
      - /path/to/config/dir/dns-records.yml:/config/dns-records.yml
```

2. **Configuration**

The application will validate your configuration, verify the DNS records in Cloudflare and start the update schedule.

Create three YAML configuration files. You can start by copying the examples from `src/main/resources/`.

[cloudflare.yml](https://github.com/Room-Elephant/ElephLink/blob/main/src/main/resources/cloudflare.yml): This file handles your Cloudflare API credentials.

```yml
# The email associated with your Cloudflare account.
email: user@example.com
# Your Cloudflare API token or Global API key.
key: YOUR_CLOUDFLARE_API_TOKEN
# The Zone Identifier for your domain, found on the "Overview" page in the Cloudflare dashboard.
zoneIdentifier: YOUR_ZONE_ID
```

[dns-records.yml](https://github.com/Room-Elephant/ElephLink/blob/main/src/main/resources/dns-records.yml): This file defines which DNS records to update and how often.

```yml
# A list of DNS records you want ElephLink to manage.
records:
  - subdomain.yourdomain.com
  - another.yourdomain.com
# UNIX Cron Expression for the update schedule.
# This example runs every day at 04:00 AM
cron-expression: "0 4 * * *"
# Timeout for requesting and updating dns records
timeout-in-milliseconds: 3000 # default 1000 milliseconds
```

A quick guide to cron expressions:

```
 ┌───────────── minute (0 - 59)
 │ ┌───────────── hour (0 - 23)
 │ │ ┌───────────── day of month (1 - 31)
 │ │ │ ┌───────────── month (1 - 12 or JAN-DEC)
 │ │ │ │ ┌───────────── day of week (0 - 6 or SUN-SAT, 0 = Sunday)
 │ │ │ │ │
 │ │ │ │ │
 * * * * *
```

[ip-services.yml](https://github.com/Room-Elephant/ElephLink/blob/main/src/main/resources/ip-services.yml): A list of web services that return your public IP address as plain text. ElephLink will try them in order until one succeeds.

```yml
# A list of plaintext IP reflector services.
services:
  - https://api.ipify.org
  - https://icanhazip.com
  - https://ipinfo.io/ip
# Timeout for requesting external ip
timeout-in-milliseconds: 1000 # default 1000 milliseconds
```

### Running Java

1. **Download jar**

Download jar from the release notes: https://github.com/Room-Elephant/ElephLink/releases

```bash
wget https://github.com/Room-Elephant/ElephLink/releases/download/v1.0.1/elephlink-1.0.1.jar
```

2. **Run the Application**

Requires Java 21 or higher.

```bash
java -jar elephlink-1.0.1.jar \
   --cloudflare-file=path/to/cloudflare.yaml \
   --dns-records-file=path/to/dns-records.yaml \
   --ip-service-file=path/to/ip-services.yaml
```

If your configuration files are in the same directory as the JAR, you can omit the arguments:

```bash
java -jar elephlink-1.0.1.jar
```

### Build locally

1. **Build from Source**

```bash
git clone https://github.com/Room-Elephant/ElephLink.git
cd ElephLink
mvn clean install
```

2. **Run java application**

Use IntelliJ configuration [.run/Main.run.xml](.run/Main.run.xml) to run locally.
Or use the configuration provided above.

2. **Build the Docker image**

```bash
docker build -t elephlink .
```

3. **Run the container**
   Place your configuration files (cloudflare.yaml, dns-records.yaml, ip-services.yaml) in a single directory (e.g., ./config). Then, run the
   container with that directory mounted as a volume.

```bash
docker run --name elephlink \
  -v $(pwd)/src/main/resources:/config \
  --restart always \
  -e JAVA_OPTS=-Xmx15m -XX:+UseSerialGC \
  elephlink
```

### Troubleshooting

You can use `-Dlog.level=DEBUG` to activate debugging logs. On docker, you can use the env variable `JAVA_OPTS` to pass the logging level.

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## 🙇‍♂️ Acknowledgments

This project was inspired by the functionality of
the [K0p1-Git/cloudflare-ddns-updater](https://github.com/K0p1-Git/cloudflare-ddns-updater) bash script.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
