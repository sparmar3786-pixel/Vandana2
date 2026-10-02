# Vandana2 free-first architecture

Cloudflare Workers is the edge/frontend gateway. The existing Python FastAPI engine remains the market-data and Angel One integration layer. Supabase Postgres is durable cloud memory, with SQLite as the local fallback.

The six AI layers are provider slots, not six mandatory paid subscriptions:
1. Gemini
2. Groq
3. Cerebras
4. DeepSeek
5. Cloudflare Workers AI
6. Ollama

A provider with no key is disabled automatically. AI remains validation-only: it cannot invent strikes, entries, stops or targets.

Angel One credentials remain backend-only and must never be embedded in Flutter/web builds.

Deployment order:
1. Apply supabase/migrations/001_vandana2_memory.sql.
2. Deploy the existing FastAPI backend and set secrets from .env.example.
3. Deploy cloudflare-worker with BACKEND_ORIGIN set to the FastAPI HTTPS origin.
4. Point the Flutter/web API base URL at the Worker URL.
5. Keep live order placement disabled.

Free quotas can change. Cloudflare Workers Free currently documents 100,000 Worker requests/day; Supabase documents two free projects and 500 MB database/project. Treat these as quota limits, not guarantees of permanent free production hosting.
