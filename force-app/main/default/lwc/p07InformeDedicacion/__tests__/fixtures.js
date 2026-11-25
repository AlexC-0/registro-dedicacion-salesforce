export const DIA = '2026-11-23';
export function resultado(desde = DIA, hasta = DIA) {
    return {desde, hasta, completo: true, limiteLineas: 1000, numeroLineas: 3, totalMinutos: 105, semanas: [
        {inicio: DIA, totalMinutos: 105, miembros: [
            {id: 'uA', nombre: 'Miembro A', totalMinutos: 105, proyectos: [
                {id: 'p1', nombre: 'Revisión', codigo: 'R', activo: true, totalMinutos: 60, detalle: [{id: 'l1', fecha: DIA, minutos: 60}]},
                {id: 'p2', nombre: 'Histórico', codigo: 'H', activo: false, totalMinutos: 45, detalle: [
                    {id: 'l2', fecha: DIA, minutos: 30}, {id: 'l3', fecha: '2026-11-24', minutos: 15}
                ]}
            ]}
        ]}
    ]};
}
export const bien = d => JSON.stringify({ok: true, resultado: d, errores: []});
export const mal = () => JSON.stringify({ok: false, resultado: null, errores: [{codigo: 'ACCESO_DENEGADO', mensaje: 'Falta acceso de lectura.'}]});
export const vacio = (desde = DIA, hasta = DIA) => ({desde, hasta, completo: true, limiteLineas: 1000, numeroLineas: 0, totalMinutos: 0, semanas: []});
export function diferida() { let resolve, reject; const promise = new Promise((a, b) => { resolve = a; reject = b; }); return {resolve, reject, promise}; }
