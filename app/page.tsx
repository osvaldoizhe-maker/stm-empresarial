import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
export default async function Home() {
  let userEmail: string | null = null;
  let companyCount: number | null = null;
  let issue = "";
  try {
    const supabase = await createClient();
    const { data: claimsData } = await supabase.auth.getClaims();
    userEmail = typeof claimsData?.claims?.email === "string" ? claimsData.claims.email : null;
    if (userEmail) {
      const { data: companies, error } = await supabase.from("memberships").select("company_id").eq("active", true);
      if (error) issue = "No se pudo consultar la membresía. Comprueba que la migración SQL se haya aplicado.";
      else companyCount = companies?.length ?? 0;
    }
  } catch { /* La pantalla de configuración explica el siguiente paso. */ }
  return <main className="shell">
    <div className="brand"><div className="logo">STM</div><div><strong>SISTEMA TOTAL DE MANTENIMIENTO</strong><div className="muted">PLATAFORMA EMPRESARIAL · MULTITENANT</div></div></div>
    <section className="panel stack">
      <div className="top"><div><div className="muted">CENTRO DE OPERACIONES</div><h1 style={{margin:"5px 0"}}>STM Empresarial</h1></div><span className="pill">Base cloud</span></div>
      <p className="muted">Gestión centralizada de activos, órdenes de trabajo y planes preventivos con aislamiento de datos por empresa.</p>
      {userEmail ? <>
        <div className="notice">Sesión iniciada como <b>{userEmail}</b>. La cantidad de membresías activas visibles es {companyCount ?? "no disponible"}.</div>
        {issue && <p>{issue}</p>}
        <div className="grid">
          <div className="panel"><span className="muted">Módulo</span><h3>Activos</h3><p className="muted">Inventario y estado de equipos.</p></div>
          <div className="panel"><span className="muted">Módulo</span><h3>Órdenes</h3><p className="muted">Trabajo correctivo y seguimiento.</p></div>
          <div className="panel"><span className="muted">Módulo</span><h3>Preventivo</h3><p className="muted">Planes y próximas fechas.</p></div>
        </div>
      </> : <>
        <div className="notice">La aplicación necesita credenciales de tu proyecto Supabase para activar autenticación y datos. No se incluyen credenciales en el paquete.</div>
        <Link href="/login">Ir a inicio de sesión →</Link>
      </>}
      <p className="muted" style={{fontSize:12}}>Versión inicial de desarrollo. Completar onboarding, pruebas RLS y despliegue antes de usar datos reales.</p>
    </section>
  </main>;
}
