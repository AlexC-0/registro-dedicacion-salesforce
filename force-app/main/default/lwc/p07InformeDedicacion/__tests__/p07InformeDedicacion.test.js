import { createElement } from 'lwc';
import Componente from 'c/p07InformeDedicacion';
import consultar from '@salesforce/apex/P07_InformeService.consultar';
import { DIA, resultado, bien, mal, vacio, diferida } from './fixtures';
jest.mock('@salesforce/apex/P07_InformeService.consultar', () => ({__esModule: true, default: jest.fn()}), {virtual: true});
jest.mock('@salesforce/i18n/timeZone', () => ({__esModule: true, default: 'Europe/Madrid'}), {virtual: true});
const flush = async () => { for (let i = 0; i < 12; i++) await Promise.resolve(); };
const q = (e, s) => e.shadowRoot.querySelector(s);
const texto = e => e.shadowRoot.textContent;
const click = async e => { q(e, 'lightning-button').click(); await flush(); };
const filtro = async (e, nombre, value) => { q(e, '[data-filtro="' + nombre + '"]').dispatchEvent(new CustomEvent('change', {detail: {value}})); await flush(); };
async function montar() { const e = createElement('c-p07-informe-dedicacion', {is: Componente}); document.body.appendChild(e); await flush(); return e; }
beforeEach(() => { jest.useFakeTimers(); jest.setSystemTime(new Date('2026-11-25T12:00:00Z')); consultar.mockReset(); });
afterEach(() => { document.body.innerHTML = ''; jest.useRealTimers(); });

test('semana inicial y petición mínima, sin consulta automática', async () => {
    const e = await montar(); expect(consultar).not.toHaveBeenCalled();
    expect(q(e, '[data-filtro="desde"]').value).toBe(DIA); expect(texto(e)).toContain('pendientes de aplicar');
    consultar.mockResolvedValueOnce(bien(resultado())); await click(e);
    expect(consultar).toHaveBeenCalledWith({peticionJson: JSON.stringify({desde: DIA, hasta: DIA})});
    expect(texto(e)).toContain('105 minutos'); expect(texto(e)).toContain('Proyecto inactivo');
    expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(3);
    expect(e.shadowRoot.activeElement).toBe(q(e, '[data-resumen]'));
});
test('intervalo explícito y filtro editado retira detalle y totales anteriores', async () => {
    const e = await montar(); consultar.mockResolvedValueOnce(bien(resultado())); await click(e);
    await filtro(e, 'modo', 'intervalo'); await filtro(e, 'desde', '2026-11-16');
    expect(q(e, '[data-resumen]')).toBeNull(); expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(0);
    expect(texto(e)).toContain('pendientes de aplicar');
    consultar.mockResolvedValueOnce(bien(resultado('2026-11-16', DIA))); await click(e);
    expect(JSON.parse(consultar.mock.calls[1][0].peticionJson)).toEqual({desde: '2026-11-16', hasta: DIA});
    expect(texto(e)).toContain('2026-11-16');
});
test.each(['2026-11-24', '2026-02-30', '', '2026-1-05'])('rechaza lunes inválido %s sin red y enfoca el error', async valor => {
    const e = await montar(); await filtro(e, 'desde', valor); await click(e);
    expect(consultar).not.toHaveBeenCalled(); expect(q(e, '[data-error]')).not.toBeNull();
    expect(e.shadowRoot.activeElement).toBe(q(e, '[data-error]'));
});
test('intervalo invertido no invoca servidor', async () => {
    const e = await montar(); await filtro(e, 'modo', 'intervalo'); await filtro(e, 'hasta', '2026-11-16'); await click(e);
    expect(consultar).not.toHaveBeenCalled();
});
test('carga bloquea duplicados, mantiene filtros y permite vaciar resultados', async () => {
    const e = await montar(), d = diferida(); consultar.mockReturnValueOnce(d.promise);
    await click(e); await click(e);
    expect(consultar).toHaveBeenCalledTimes(1); expect(q(e, 'lightning-button').disabled).toBe(true);
    expect(q(e, '[data-filtro="desde"]').disabled).not.toBe(true); expect(texto(e)).toContain('Consultando');
    d.resolve(bien(vacio())); await flush();
    expect(texto(e)).toContain('No hay dedicaciones accesibles'); expect(texto(e)).toContain('0 minutos');
    expect(q(e, 'lightning-button').disabled).toBe(false);
});
test.each(['rechazo', 'contrato'])('fallo %s elimina resultado anterior y permite recuperar', async tipo => {
    const e = await montar(); consultar.mockResolvedValueOnce(bien(resultado())); await click(e);
    if (tipo === 'rechazo') consultar.mockRejectedValueOnce({body: {message: 'transporte'}});
    else consultar.mockResolvedValueOnce(mal());
    await click(e);
    expect(q(e, '[data-resumen]')).toBeNull(); expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(0);
    expect(q(e, '[data-error]')).not.toBeNull();
    consultar.mockResolvedValueOnce(bien(resultado())); await click(e);
    expect(q(e, '[data-error]')).toBeNull(); expect(texto(e)).toContain('105 minutos');
});
test.each(['resuelve', 'rechaza'])('respuesta anterior %s no sustituye filtro ni resultado nuevos', async tipo => {
    const e = await montar(), antigua = diferida(), nueva = diferida();
    consultar.mockReturnValueOnce(antigua.promise).mockReturnValueOnce(nueva.promise); await click(e);
    await filtro(e, 'desde', '2026-11-16'); await click(e);
    nueva.resolve(bien(vacio('2026-11-16', '2026-11-16'))); await flush();
    if (tipo === 'resuelve') antigua.resolve(bien(resultado())); else antigua.reject(new Error('Error anterior'));
    await flush(); expect(texto(e)).toContain('0 minutos'); expect(texto(e)).not.toContain('105 minutos');
    expect(q(e, '[data-error]')).toBeNull(); expect(q(e, '[data-resumen]').textContent).toContain('2026-11-16');
});
test('editar durante carga sin nueva consulta invalida respuesta pendiente', async () => {
    const e = await montar(), d = diferida(); consultar.mockReturnValueOnce(d.promise); await click(e);
    await filtro(e, 'desde', '2026-11-16'); d.resolve(bien(resultado())); await flush();
    expect(q(e, '[data-resumen]')).toBeNull(); expect(texto(e)).toContain('pendientes de aplicar');
});
test.each([
    d => { d.totalMinutos = 999; },
    d => { d.completo = false; },
    d => { d.desde = '2026-11-16'; },
    d => { d.numeroLineas = 1001; },
    d => { d.semanas[0].miembros[0].proyectos[0].detalle[0].minutos = 1.5; }
])('respuesta incoherente no se presenta como resultado', async alterar => {
    const e = await montar(), d = resultado(); alterar(d); consultar.mockResolvedValueOnce(bien(d)); await click(e);
    expect(q(e, '[data-resumen]')).toBeNull(); expect(q(e, '[data-error]').textContent).toContain('coherente');
});
test('controles etiquetados, foco y tablas semánticas sin edición', async () => {
    const e = await montar(); expect(q(e, 'lightning-combobox').label).toBe('Selección');
    expect(q(e, 'lightning-input').label).toBe('Lunes inicial');
    expect(q(e, 'lightning-button').label).toBe('Consultar');
    consultar.mockResolvedValueOnce(bien(resultado())); await click(e);
    expect(q(e, '[data-resumen]').getAttribute('tabindex')).toBe('-1');
    expect(e.shadowRoot.querySelectorAll('table caption')).toHaveLength(2);
    expect(e.shadowRoot.querySelectorAll('th[scope="col"]')).toHaveLength(4);
    expect(e.shadowRoot.querySelectorAll('tbody input, tbody button')).toHaveLength(0);
});
