import { describe, it, expect } from "vitest";
import { z } from "zod";

const loginSchema = z.object({
  email: z.string().trim().email().max(254),
  password: z.string().min(12).max(128)
});
describe("validación de acceso", () => {
  it("acepta credenciales con forma válida", () => {
    expect(loginSchema.safeParse({email:"persona@empresa.com",password:"una-frase-segura-2026"}).success).toBe(true);
  });
  it("rechaza correos inválidos", () => {
    expect(loginSchema.safeParse({email:"no-es-correo",password:"una-frase-segura-2026"}).success).toBe(false);
  });
  it("rechaza contraseñas cortas", () => {
    expect(loginSchema.safeParse({email:"persona@empresa.com",password:"123"}).success).toBe(false);
  });
});
