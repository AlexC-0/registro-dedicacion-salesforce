import { esLunes, filtrosValidos, interpretar, lunesActual } from '../modelo';
import { DIA, resultado, bien, vacio } from './fixtures';
test('fechas reales, cambio de año y validación de ambos extremos', () => {
    expect(esLunes('2025-12-29')).toBe(true);
    expect(filtrosValidos('2025-12-29', '2026-01-05')).toBe(true);
    expect(filtrosValidos(DIA, '2026-11-24')).toBe(false);
    expect(esLunes('2026-02-30')).toBe(false);
});
test('lunes según zona Salesforce cerca de cambio de día', () => {
    jest.useFakeTimers(); jest.setSystemTime(new Date('2026-11-22T23:30:00Z'));
    expect(lunesActual('Europe/Madrid')).toBe(DIA);
    expect(lunesActual('America/New_York')).toBe('2026-11-16'); jest.useRealTimers();
});
test('acepta detalle completo y vacío coherente', () => {
    expect(interpretar(bien(resultado()), DIA, DIA).totalMinutos).toBe(105);
    expect(interpretar(bien(vacio()), DIA, DIA).numeroLineas).toBe(0);
});
test.each([
    d => { d.semanas[0].totalMinutos++; },
    d => { d.semanas[0].miembros[0].totalMinutos++; },
    d => { d.semanas[0].miembros[0].proyectos[0].totalMinutos++; },
    d => { d.semanas[0].miembros[0].proyectos[1].detalle[0].id = 'l1'; },
    d => { d.semanas[0].miembros[0].proyectos[0].detalle[0].fecha = '2026-11-30'; },
    d => { d.semanas[0].miembros[0].proyectos[0].detalle[0].minutos = 0; },
    d => { d.semanas[0].miembros.push(d.semanas[0].miembros[0]); },
    d => { d.numeroLineas--; },
    d => { d.limiteLineas = 2000; }
])('rechaza duplicados, detalle fuera de semana y sumas incorrectas', cambiar => {
    const d = resultado(); cambiar(d); expect(() => interpretar(bien(d), DIA, DIA)).toThrow();
});
test.each(['{', 'null', '{}', '{"ok":false,"resultado":{},"errores":[]}'])('rechaza contrato mal formado %s', bruto => {
    expect(() => interpretar(bruto, DIA, DIA)).toThrow();
});
