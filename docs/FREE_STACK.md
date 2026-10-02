# Vandana2 free-first architecture

## Runtime

Cloudflare Workers is the edge/frontend gateway. The existing Python FastAPI engine runs on an Oracle Cloud Always Free VM. Supabase Postgres is durable cloud memory, with SQLite as the local fallback.

The six AI layers are configurable provider slots:
1. Gemini
2. Groq
3. Cerebras
4. DeepSeek
5. Cloudflare Workers AI
6. Ollama

A provider with no key is disabled automatically. AI remains validation-only: it cannot invent strikes, entries, stops or targets.

Angel One credentials remain backend-only and must never be embedded in Flutter/web builds.

## Why Oracle Cloud for the core backend

The FastAPI process needs a persistent VM-style runtime for broker connectivity and WebSocket workloads. OCI documents Always Free compute resources, including up to 2 OCPUs and 12 GB RAM total for Ampere A1 across Always Free instances, subject to account/region capacity. OCI also supports reserved public IPv4 addresses that persist across reboot/redeployment. The Mumbai region is available as ap-mumbai-1.

This makes the runtime layout:

Cloudflare Worker -> HTTPS -> Oracle VM (FastAPI + Caddy) -> Angel One
                                      \
                                       -> Supabase memory
                                       -> six AI providers

The Cloudflare layer handles global edge/static delivery while the Oracle VM owns the long-running Python process and outbound broker session.

## Deployment order

1. Apply supabase/migrations/001_vandana2_memory.sql.
2. Create an OCI Always Free VM and reserve a public IPv4.
3. Copy deploy/oracle/.env.example to .env on the VM and add secrets there only.
4. Start deploy/oracle/docker-compose.yml.
5. Set cloudflare-worker/wrangler.toml BACKEND_ORIGIN to the VM's HTTPS API domain.
6. Deploy the Cloudflare Worker.
7. Point the Flutter/web API base URL at the Worker URL.
8. Keep live order placement disabled.

## CI

validate-free-stack.yml validates the backend, edge worker, Supabase migration, and Oracle deployment files. It intentionally does not make external provider credentials a CI requirement.

## Cost and availability note

Always Free means the eligible OCI resources are free for the life of the account, subject to OCI's published limits and policies. It does not mean guaranteed capacity or SLA. OCI also documents possible reclamation of sufficiently idle Always Free compute instances, so monitor the VM.

Free AI-provider quotas and Cloudflare/Supabase quotas can change. Treat all free tiers as quota-based rather than as an unlimited production guarantee.
