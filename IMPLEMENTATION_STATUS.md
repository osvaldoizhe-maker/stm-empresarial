# Estado honesto de la implementación

## Generado en este paquete
- App Router de Next.js con TypeScript.
- Cliente Supabase SSR con cookies y proxy de actualización de sesión.
- Página de acceso con validación básica server-side y sin registro público abierto.
- Pantalla inicial conectada a la consulta de membresías.
- Esquema PostgreSQL multiempresa con roles y políticas RLS iniciales.
- Cabeceras de seguridad básicas.
- Plan de despliegue y checklist.
- Casos de prueba RLS definidos como escenarios pendientes.

## No verificado todavía
- `npm install`, compilación y despliegue no se ejecutaron en este entorno.
- SQL no se ejecutó en un proyecto Supabase real.
- Aislamiento multiempresa no ha pasado pruebas automatizadas.
- No se ha configurado ninguna cuenta, dominio, SMTP, almacenamiento ni proveedor cloud.
- No existe certificación ni garantía de seguridad.

## Próximas tareas de ingeniería
1. Probar/migrar el SQL en staging y corregir errores de migración si los hubiera.
2. Crear RPC o endpoint de onboarding con verificación de invitación, evitando escalamiento de privilegios.
3. Crear tests pgTAP concretos para roles y tenants y ejecutarlos en CI.
4. Implementar CRUD completo con validación Zod y autorización server-side.
5. Añadir Storage privado y pruebas de acceso.
6. Implementar auditoría de negocio, notificaciones y backups.
7. Ejecutar escaneo de dependencias, revisión de amenazas, pruebas de carga y pentest antes del lanzamiento.
