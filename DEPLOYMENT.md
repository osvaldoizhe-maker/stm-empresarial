# Preparación de despliegue en la nube

## 1. Requisitos
- Node.js LTS, Git y npm.
- Cuenta Supabase para PostgreSQL/Auth.
- Cuenta Vercel o infraestructura compatible con Next.js.
- Dominio y correo transaccional propio para producción.

## 2. Desarrollo local
1. Descomprimir el proyecto y ejecutar `npm install`.
2. Copiar `.env.example` a `.env.local`.
3. Configurar URL del proyecto Supabase y la publishable key (no usar service role en cliente).
4. Aplicar `supabase/migrations/001_initial_schema.sql` primero en un proyecto de prueba.
5. Ejecutar `npm run dev`; abrir `http://localhost:3000`.
6. Ejecutar `npm run lint` y `npm test` (las pruebas RLS requieren configurar pgTAP y datos de prueba).

## 3. Supabase
- Configurar proveedor Email, confirmación de correo, recuperación y SMTP propio.
- Activar MFA para usuarios privilegiados y proteger la cuenta de organización con MFA.
- Ejecutar migraciones desde control de versiones.
- Verificar RLS, grants y Security Advisor.
- Configurar SSL enforcement, restricciones de red según topología, alertas y backups.
- Crear bucket privado de Storage y añadir políticas específicas por tenant antes de habilitar adjuntos.

## 4. Vercel
- Importar repositorio Git privado.
- Configurar `NEXT_PUBLIC_SUPABASE_URL` y `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` por separado para Preview y Production.
- No subir `.env.local`; no colocar secretos en variables `NEXT_PUBLIC_`.
- Desplegar Preview, ejecutar pruebas y solo después promover a Production.
- Añadir dominio, verificar HTTPS, probar redirecciones y cabeceras.

## 5. Limitación actual
Esta plantilla incluye login y consulta de membresías como base, además del esquema SQL. No implementa aún alta segura de tenants, administración de usuarios, CRUD de mantenimiento completo, políticas de Storage, alertas, correo de negocio, auditoría server-side completa ni suite automatizada RLS. No usar con datos reales hasta completar esos puntos.
