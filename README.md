# STM Cloud Multitenant — starter técnico
Aplicación Next.js + Supabase diseñada para empresas independientes con datos aislados por tenant.

**No es todavía un producto de producción completo.** Consulta `IMPLEMENTATION_STATUS.md` y `SECURITY_CHECKLIST.md` antes de desplegar.

- Guía local y cloud: `DEPLOYMENT.md`
- Esquema y RLS: `supabase/migrations/001_initial_schema.sql`
- Escenarios RLS: `supabase/tests/rls_smoke_test.sql`
- Seguridad: `SECURITY_CHECKLIST.md`

Fuentes oficiales consultadas:
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase SSR: https://supabase.com/docs/guides/auth/server-side/creating-a-client
- Supabase producción: https://supabase.com/docs/guides/deployment/going-into-prod
- Vercel variables: https://vercel.com/docs/environment-variables
