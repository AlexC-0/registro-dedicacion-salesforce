export function fechaValida(valor) {
    if (typeof valor !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(valor)) return false;
    const d = new Date(valor + 'T00:00:00Z');
    return !Number.isNaN(d.valueOf()) && d.toISOString().slice(0, 10) === valor;
}
export function esLunes(valor) {
    return fechaValida(valor) && new Date(valor + 'T00:00:00Z').getUTCDay() === 1;
}
export function filtrosValidos(desde, hasta) {
    return esLunes(desde) && esLunes(hasta) && desde <= hasta;
}
export function lunesActual(zona) {
    const partes = new Intl.DateTimeFormat('en-CA', {timeZone: zona, year: 'numeric', month: '2-digit', day: '2-digit'}).formatToParts(new Date());
    const valores = Object.fromEntries(partes.map(p => [p.type, p.value]));
    const d = new Date(valores.year + '-' + valores.month + '-' + valores.day + 'T00:00:00Z');
    d.setUTCDate(d.getUTCDate() - (d.getUTCDay() + 6) % 7);
    return d.toISOString().slice(0, 10);
}
const entero = n => Number.isSafeInteger(n) && n >= 0;
const texto = s => typeof s === 'string' && s.trim().length > 0;
const lista = a => Array.isArray(a) && a.length > 0;
function exigir(condicion) {
    if (!condicion) throw new Error('La respuesta no permite mostrar un resultado completo y coherente. Vuelve a consultar.');
}
export function interpretar(bruto, desde, hasta) {
    let r;
    try { r = JSON.parse(bruto); } catch { exigir(false); }
    exigir(r && typeof r.ok === 'boolean' && Array.isArray(r.errores));
    if (!r.ok) {
        exigir(r.resultado === null && r.errores.length > 0 && r.errores.every(e => e && texto(e.codigo) && texto(e.mensaje)));
        throw new Error(r.errores.map(e => e.mensaje).join(' '));
    }
    const d = r.resultado;
    exigir(r.errores.length === 0 && d && d.desde === desde && d.hasta === hasta && d.completo === true &&
        d.limiteLineas === 1000 && entero(d.numeroLineas) && d.numeroLineas <= d.limiteLineas &&
        entero(d.totalMinutos) && Array.isArray(d.semanas));
    const ids = new Set(), semanas = new Set();
    let total = 0, numero = 0;
    for (const s of d.semanas) {
        exigir(s && esLunes(s.inicio) && s.inicio >= desde && s.inicio <= hasta && !semanas.has(s.inicio) && lista(s.miembros));
        semanas.add(s.inicio);
        const fin = new Date(s.inicio + 'T00:00:00Z'); fin.setUTCDate(fin.getUTCDate() + 6);
        const domingo = fin.toISOString().slice(0, 10), miembros = new Set();
        let sumaSemana = 0;
        for (const m of s.miembros) {
            exigir(m && texto(m.id) && texto(m.nombre) && !miembros.has(m.id) && lista(m.proyectos));
            miembros.add(m.id);
            const proyectos = new Set(); let sumaMiembro = 0;
            for (const p of m.proyectos) {
                exigir(p && texto(p.id) && texto(p.nombre) && texto(p.codigo) && typeof p.activo === 'boolean' && !proyectos.has(p.id) && lista(p.detalle));
                proyectos.add(p.id); let sumaProyecto = 0;
                for (const l of p.detalle) {
                    exigir(l && texto(l.id) && !ids.has(l.id) && fechaValida(l.fecha) && l.fecha >= s.inicio && l.fecha <= domingo &&
                        entero(l.minutos) && l.minutos > 0 && l.minutos <= 1440);
                    ids.add(l.id); sumaProyecto += l.minutos; numero += 1;
                }
                exigir(p.totalMinutos === sumaProyecto); sumaMiembro += sumaProyecto;
            }
            exigir(m.totalMinutos === sumaMiembro); sumaSemana += sumaMiembro;
        }
        exigir(s.totalMinutos === sumaSemana); total += sumaSemana;
    }
    exigir(total === d.totalMinutos && numero === d.numeroLineas);
    return d;
}
