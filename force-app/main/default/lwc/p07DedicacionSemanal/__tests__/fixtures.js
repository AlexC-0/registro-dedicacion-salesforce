export const SEMANA = '2026-11-16';
export const id = (n) => 'a01' + String(n).padStart(12, '0') + 'AAA';
export function estado({ semana = SEMANA, hoy = '2026-11-18', revision = '1', puedeGuardar = true, proyectos = 3, entradas = [{ proyectoId: id(1), fecha: semana, minutos: 60 }], inactivos = [] } = {}) {
    const dias = Array.from({ length: 7 }, (_, i) => {
        const d = new Date(semana + 'T12:00:00Z'); d.setUTCDate(d.getUTCDate() + i); const fecha = d.toISOString().slice(0, 10);
        return { fecha, minutos: entradas.filter((e) => e.fecha === fecha).reduce((s, e) => s + e.minutos, 0), editable: puedeGuardar && fecha <= hoy };
    });
    return { semana, hoy, revision, existe: revision !== '0', puedeGuardar, proyectos: Array.from({ length: proyectos }, (_, i) => ({ id: id(i + 1), nombre: 'Proyecto ' + (i + 1), codigo: 'P' + (i + 1), activo: !inactivos.includes(i + 1), editable: puedeGuardar && !inactivos.includes(i + 1) })), entradas: entradas.map((e) => ({ ...e, editable: puedeGuardar && e.fecha <= hoy && !inactivos.some((n) => id(n) === e.proyectoId) })), dias, totalMinutos: entradas.reduce((s, e) => s + e.minutos, 0) };
}
export const bien = (s) => JSON.stringify({ ok: true, estado: s, errores: [] });
export const mal = (codigo, proyectoId = null, fecha = null, mensaje = 'Revisa los cambios indicados.') => JSON.stringify({ ok: false, estado: null, errores: [{ codigo, proyectoId, fecha, mensaje }] });
export const diferida = () => { let resolve, reject; const promise = new Promise((a, b) => { resolve = a; reject = b; }); return { promise, resolve, reject }; };
