import { signIn } from "./actions";
export default async function Login({ searchParams }: { searchParams: Promise<{error?:string}> }) {
  const {error} = await searchParams;
  return <main className="shell">
    <div className="brand"><div className="logo">STM</div><div><strong>STM EMPRESARIAL</strong><div className="muted">ACCESO SEGURO</div></div></div>
    <section className="panel" style={{maxWidth:520,margin:"auto"}}>
      <h1>Iniciar sesión</h1>
      <p className="muted">Usa la cuenta autorizada por el administrador de tu empresa.</p>
      {error && <p className="notice">{error==="invalid"?"Revisa el formato del correo y que la contraseña tenga al menos 12 caracteres.":"No se pudo iniciar sesión. Revisa tus credenciales o la configuración de Auth."}</p>}
      <form action={signIn} className="form">
        <label>Correo electrónico<input name="email" type="email" autoComplete="email" required maxLength={254}/></label>
        <label>Contraseña<input name="password" type="password" autoComplete="current-password" required minLength={12} maxLength={128}/></label>
        <button className="primary" type="submit">Entrar</button>
      </form>
      <p className="muted" style={{fontSize:12}}>El alta de empresas y asignación de roles debe realizarla un flujo administrativo seguro; el registro público está deshabilitado por diseño.</p>
    </section>
  </main>;
}
