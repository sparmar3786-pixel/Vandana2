# Vandana2 — Oracle Cloud backend

This directory is the non-Render deployment path for the Python FastAPI backend.

## Target architecture

- Oracle Cloud Always Free VM (prefer Ampere A1 in the Mumbai home region when available)
- Reserved public IPv4 on the VM
- Caddy for HTTPS on ports 80/443
- FastAPI + Uvicorn only on the private Docker network
- Cloudflare Worker remains the edge/frontend gateway
- Supabase remains the durable cloud-memory layer
- Angel One credentials remain on the VM only

## VM sizing

For an Always Free tenancy, OCI documents up to 2 OCPUs and 12 GB RAM total for Ampere A1 across Always Free instances. Actual capacity can vary by region/availability.

## First-time setup

1. Create an Ubuntu 24.04 ARM64 or Oracle Linux ARM64 OCI VM in the home region.
2. Attach a reserved public IPv4 address.
3. Allow TCP 22, 80 and 443 in the OCI VCN/security rules.
4. Install Docker and the Docker Compose plugin.
5. Copy .env.example to .env and fill secrets on the VM only.
6. Set the DNS A record for API_DOMAIN to the reserved public IPv4.
7. Start with: docker compose up -d --build
8. Confirm with: curl https://api.example.com/health

## Cloudflare gateway

Set cloudflare-worker/wrangler.toml BACKEND_ORIGIN to the HTTPS API domain served by this VM, then deploy the Worker.

Do not put Angel API keys, Client ID, PIN or TOTP in Flutter/web assets or Cloudflare static assets.

## Operational note

OCI documents that idle Always Free compute instances can be reclaimed when CPU, network and (for A1) memory utilization stay below its idle thresholds for seven days. This is not a contractual uptime guarantee.
