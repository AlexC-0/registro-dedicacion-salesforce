const CODIGOS = new Set(['VALIDACION', 'ACCESO_DENEGADO', 'REVISION_DESACTUALIZADA', 'CONFLICTO_CREACION', 'CONTENCION', 'FALLO_TECNICO']);
const idValido = (id) => typeof id === 'string' && /^(?:[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})$/.test(id);
const entero = (n) => Number.isSafeInteger(n) && n >= 0;
const asegurar = (condicion) => { if (!condicion) throw new Error('Respuesta no válida'); };
export const clave = (proyectoId, fecha) => proyectoId + '|' + fecha;
export function fechaCivil(iso) {
    if (typeof iso !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(iso)) throw new Error('Fecha no válida');
    const [y, m, d] = iso.split('-').map(Number);
    const fecha = new Date(0);
    fecha.setUTCFullYear(y, m - 1, d); fecha.setUTCHours(0, 0, 0, 0);
    if (fecha.getUTCFullYear() !== y || fecha.getUTCMonth() !== m - 1 || fecha.getUTCDate() !== d) throw new Error('Fecha no válida');
    return fecha;
}
function isoCivil(fecha) { return String(fecha.getUTCFullYear()).padStart(4, '0') + '-' + String(fecha.getUTCMonth() + 1).padStart(2, '0') + '-' + String(fecha.getUTCDate()).padStart(2, '0'); }
export function sumarDias(iso, cantidad) { const d = fechaCivil(iso); d.setUTCDate(d.getUTCDate() + cantidad); return isoCivil(d); }
export function lunesDe(iso) { const dia = fechaCivil(iso).getUTCDay(); return sumarDias(iso, -((dia + 6) % 7)); }
export function hoyEnZona(instante, zona) {
    const partes = new Intl.DateTimeFormat('en-US', { timeZone: zona, year: 'numeric', month: '2-digit', day: '2-digit' }).formatToParts(instante);
    const valor = (tipo) => partes.find((p) => p.type === tipo).value;
    return valor('year') + '-' + valor('month') + '-' + valor('day');
}
export function etiquetaFecha(iso) { return new Intl.DateTimeFormat('es-ES', { timeZone: 'UTC', weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' }).format(fechaCivil(iso)); }
export function horasTexto(minutos) { return minutos === 0 ? '' : String(minutos / 60).replace('.', ','); }
export function totalTexto(minutos) { return minutos === null ? 'Pendiente de corregir' : String(minutos / 60).replace('.', ',') + ' h'; }
export function analizarHoras(entrada) {
    const texto = String(entrada).trim();
    if (texto === '') return { minutos: 0, horas: '', error: null };
    if (!/^(0|[1-9][0-9]?)([.,][0-9]{1,2})?$/.test(texto)) return { error: 'Introduce horas con coma o punto y hasta dos decimales, sin signos ni separadores de miles.' };
    const [entera, decimal = ''] = texto.replace(',', '.').split('.');
    const centesimas = Number(entera) * 100 + Number(decimal.padEnd(2, '0'));
    if (centesimas > 2400 || centesimas % 25 !== 0) return { error: 'Usa incrementos de 0,25 horas, entre 0 y 24.' };
    return { minutos: centesimas * 60 / 100, horas: String(centesimas / 100), error: null };
}
export function interpretarRespuesta(texto, semana) {
    asegurar(typeof texto === 'string' && texto.length > 0);
    const r = JSON.parse(texto);
    asegurar(r && typeof r.ok === 'boolean' && Array.isArray(r.errores));
    if (!r.ok) {
        asegurar(r.estado === null && r.errores.length > 0);
        r.errores.forEach((e) => {
            asegurar(e && CODIGOS.has(e.codigo) && typeof e.mensaje === 'string' && e.mensaje.length > 0);
            asegurar(e.proyectoId === null || idValido(e.proyectoId));
            if (e.fecha !== null) fechaCivil(e.fecha);
        });
        return r;
    }
    const s = r.estado;
    asegurar(r.errores.length === 0 && s && s.semana === semana && lunesDe(s.semana) === s.semana);
    fechaCivil(s.hoy);
    asegurar(typeof s.revision === 'string' && /^(0|[1-9][0-9]{0,17})$/.test(s.revision));
    asegurar(typeof s.existe === 'boolean' && typeof s.puedeGuardar === 'boolean');
    asegurar(Array.isArray(s.proyectos) && s.proyectos.length <= 1000 && Array.isArray(s.entradas) && s.entradas.length <= 700 && Array.isArray(s.dias) && s.dias.length === 7 && entero(s.totalMinutos));
    const proyectos = new Set();
    s.proyectos.forEach((p) => {
        asegurar(p && idValido(p.id) && !proyectos.has(p.id) && typeof p.nombre === 'string' && typeof p.codigo === 'string' && typeof p.activo === 'boolean' && typeof p.editable === 'boolean'); proyectos.add(p.id);
    });
    const dias = Object.fromEntries(s.dias.map((d, i) => {
        asegurar(d && d.fecha === sumarDias(semana, i) && entero(d.minutos) && typeof d.editable === 'boolean'); return [d.fecha, 0];
    }));
    const celdas = new Set();
    s.entradas.forEach((e) => {
        asegurar(e && proyectos.has(e.proyectoId) && Object.hasOwn(dias, e.fecha) && entero(e.minutos) && e.minutos > 0 && e.minutos <= 1440 && e.minutos % 15 === 0 && typeof e.editable === 'boolean');
        const k = clave(e.proyectoId, e.fecha); asegurar(!celdas.has(k)); celdas.add(k); dias[e.fecha] += e.minutos;
    });
    asegurar(s.dias.every((d) => dias[d.fecha] === d.minutos && d.minutos <= 1440));
    asegurar(Object.values(dias).reduce((a, b) => a + b, 0) === s.totalMinutos);
    asegurar(s.existe || (s.revision === '0' && s.entradas.length === 0));
    return r;
}
export function valores(s) { return Object.fromEntries(s.entradas.map((e) => [clave(e.proyectoId, e.fecha), e.minutos])); }
export function editable(s, proyectoId, fecha) {
    const p = s.proyectos.find((item) => item.id === proyectoId);
    const d = s.dias.find((item) => item.fecha === fecha);
    const e = s.entradas.find((item) => item.proyectoId === proyectoId && item.fecha === fecha);
    return Boolean(s.puedeGuardar && p?.activo && p.editable && d?.editable && fecha <= s.hoy && (!e || e.editable));
}
export function proponer(s, borrador) {
    const celdas = valores(s), errores = [], invalidas = new Set();
    Object.entries(borrador).forEach(([k, texto]) => {
        const [proyectoId, fecha] = k.split('|'); const valor = analizarHoras(texto);
        if (valor.error) { errores.push({ proyectoId, fecha, mensaje: valor.error }); invalidas.add(k); }
        else celdas[k] = valor.minutos;
        if (!editable(s, proyectoId, fecha)) errores.push({ proyectoId, fecha, mensaje: 'Esta celda ya no se puede editar. Actualiza el estado y revisa tus cambios.' });
    });
    const dias = Object.fromEntries(s.dias.map((d) => [d.fecha, 0])); const proyectos = {};
    Object.entries(celdas).forEach(([k, n]) => { const [p, d] = k.split('|'); dias[d] += n; proyectos[p] = (proyectos[p] || 0) + n; });
    invalidas.forEach((k) => { const [p, d] = k.split('|'); dias[d] = null; proyectos[p] = null; });
    Object.entries(dias).forEach(([fecha, n]) => { if (n > 1440) errores.push({ proyectoId: null, fecha, mensaje: 'La suma de este día supera 24 horas.' }); });
    return { celdas, dias, proyectos, total: invalidas.size ? null : Object.values(dias).reduce((a, b) => a + b, 0), errores };
}
export function limitesPeticion(p) {
    const errores = [];
    if (p.cambios.length > 140) errores.push('Solo puedes guardar hasta 140 celdas modificadas a la vez. Reduce los cambios pendientes.');
    if (new Set(p.cambios.map((c) => c.proyectoId)).size > 20) errores.push('Solo puedes modificar hasta 20 proyectos en un guardado. Reduce los cambios pendientes.');
    if (JSON.stringify(p).length > 60000) errores.push('Los cambios superan el tamaño permitido. Reduce el conjunto antes de guardar.');
    return errores.map((mensaje) => ({ proyectoId: null, fecha: null, mensaje }));
}
export function peticion(s, borrador) {
    const cambios = Object.entries(borrador).map(([k, texto]) => { const [proyectoId, fecha] = k.split('|'); return { proyectoId, fecha, horas: analizarHoras(texto).horas }; });
    const resultado = { semana: s.semana, revisionEsperada: s.revision, cambios };
    return { valor: resultado, errores: [...proponer(s, borrador).errores, ...limitesPeticion(resultado)] };
}
