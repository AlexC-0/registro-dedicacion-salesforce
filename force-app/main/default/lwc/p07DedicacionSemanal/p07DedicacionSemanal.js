import { LightningElement } from 'lwc';
import timeZone from '@salesforce/i18n/timeZone';
import LightningConfirm from 'lightning/confirm';
import leerSemana from '@salesforce/apex/P07_DedicacionService.leerSemana';
import guardarSemana from '@salesforce/apex/P07_DedicacionService.guardarSemana';
import { clave, lunesDe, sumarDias, hoyEnZona, etiquetaFecha, analizarHoras, horasTexto, totalTexto, interpretarRespuesta, valores, editable, proponer, peticion } from './modelo';

export default class P07DedicacionSemanal extends LightningElement {
    semana;
    confirmado = null;
    borrador = {};
    textoEnEdicion = null;
    visibles = [];
    errores = [];
    estado = 'cargando';
    aviso = '';
    recuperacion = null;
    actual = null;
    seleccion = {};
    decision = false;
    secuencia = 0;
    foco;

    connectedCallback() {
        try { this.cargar(lunesDe(hoyEnZona(new Date(), timeZone)), true); }
        catch { this.estado = 'error'; this.errores = [{ mensaje: 'No se pudo determinar la semana. Selecciona una fecha para consultar.', proyectoId: null, fecha: null }]; }
    }
    disconnectedCallback() { this.secuencia++; }
    renderedCallback() {
        if (this.foco) { const destino = this.template.querySelector(this.foco); if (destino) { this.foco = null; destino.focus(); } }
    }
    get pendiente() { return Object.keys(this.borrador).length > 0; }
    get ocupado() { return this.estado === 'cargando' || this.estado === 'guardando' || this.decision; }
    get navegacionBloqueada() { return this.estado === 'guardando' || Boolean(this.recuperacion) || this.decision; }
    get edicionBloqueada() { return this.ocupado || Boolean(this.recuperacion); }
    get hayEstado() { return this.confirmado && this.confirmado.semana === this.semana; }
    get sinPermiso() { return this.hayEstado && !this.confirmado.puedeGuardar; }
    get guardarBloqueado() { return !this.hayEstado || !this.pendiente || this.edicionBloqueada || this.sinPermiso; }
    get descartarBloqueado() { return !this.pendiente || this.edicionBloqueada; }
    get selectorBloqueado() { return !this.hayEstado || this.edicionBloqueada || this.sinPermiso; }
    get resumenEstado() {
        if (this.estado === 'guardando') return 'Guardando todos los cambios…';
        if (this.estado === 'cargando') return 'Consultando la semana…';
        if (this.recuperacion === 'desconocido') return 'Resultado desconocido: el guardado pudo completarse. Consulta el estado actual antes de continuar.';
        if (this.recuperacion) return 'La semana ha cambiado. Revisa el estado actual y decide qué conservar.';
        if (this.pendiente) return (this.aviso ? this.aviso + ' ' : '') + Object.keys(this.borrador).length + ' celdas con cambios pendientes. Aún no están guardadas.';
        return this.aviso || 'Sin cambios pendientes.';
    }
    get tituloSemana() { return this.semana ? etiquetaFecha(this.semana) + ' — ' + etiquetaFecha(sumarDias(this.semana, 6)) : 'Selecciona una semana'; }
    get propuesta() { return this.hayEstado ? proponer(this.confirmado, this.borrador) : null; }
    get erroresVisibles() {
        const lista = [...(this.propuesta?.errores || []), ...this.errores];
        const unicos = new Map();
        lista.forEach((e) => {
            const p = this.confirmado?.proyectos.find((item) => item.id === e.proyectoId);
            const contexto = [p?.nombre, e.fecha ? etiquetaFecha(e.fecha) : null].filter(Boolean).join(' · ');
            const k = [e.proyectoId, e.fecha, e.mensaje].join('|');
            unicos.set(k, { ...e, key: k, texto: contexto ? contexto + ': ' + e.mensaje : e.mensaje });
        });
        return [...unicos.values()];
    }
    get hayErrores() { return this.erroresVisibles.length > 0; }
    get dias() {
        if (!this.hayEstado) return [];
        const propuesta = this.propuesta;
        return this.confirmado.dias.map((d) => ({ ...d, etiqueta: etiquetaFecha(d.fecha), total: totalTexto(propuesta.dias[d.fecha]), error: this.erroresVisibles.filter((e) => e.fecha === d.fecha && !e.proyectoId).map((e) => e.mensaje).join(' ') }));
    }
    get filas() {
        if (!this.hayEstado) return [];
        const base = valores(this.confirmado), propuesta = this.propuesta, errores = this.erroresVisibles;
        const ids = new Set([...this.visibles, ...this.confirmado.entradas.map((e) => e.proyectoId), ...Object.keys(this.borrador).map((k) => k.split('|')[0])]);
        return this.confirmado.proyectos.filter((p) => ids.has(p.id)).map((p) => ({
            id: p.id, nombre: p.nombre, inactivo: !p.activo, total: totalTexto(propuesta.proyectos[p.id] ?? (propuesta.proyectos[p.id] === null ? null : 0)),
            quitarBloqueado: this.edicionBloqueada || this.confirmado.entradas.some((e) => e.proyectoId === p.id) || Object.keys(this.borrador).some((k) => k.startsWith(p.id + '|')),
            quitarEtiqueta: 'Quitar fila vacía de ' + p.nombre,
            celdas: this.confirmado.dias.map((d) => {
                const k = clave(p.id, d.fecha), modificada = Object.hasOwn(this.borrador, k);
                const error = errores.filter((e) => e.proyectoId === p.id && e.fecha === d.fecha).map((e) => e.mensaje).join(' ');
                const valor = this.textoEnEdicion?.key === k ? this.textoEnEdicion.texto : modificada ? this.borrador[k] : horasTexto(base[k] || 0);
                return { key: k, proyectoId: p.id, fecha: d.fecha, valor, etiqueta: p.nombre + ', ' + etiquetaFecha(d.fecha) + ', horas', deshabilitada: this.edicionBloqueada || !editable(this.confirmado, p.id, d.fecha), modificada, error };
            })
        }));
    }
    get sinFilas() { return this.hayEstado && this.filas.length === 0; }
    get opciones() { const visibles = new Set(this.filas.map((f) => f.id)); return this.confirmado?.proyectos.filter((p) => p.activo && !visibles.has(p.id)).map((p) => ({ label: p.nombre + ' · ' + p.codigo, value: p.id })) || []; }
    get totalConfirmado() { return totalTexto(this.confirmado?.totalMinutos || 0); }
    get totalPropuesto() { return totalTexto(this.propuesta?.total ?? null); }
    get tituloTotales() { return this.pendiente ? 'Totales provisionales' : 'Totales confirmados'; }
    get comparaciones() {
        if (!this.actual) return [];
        const antes = valores(this.confirmado), ahora = valores(this.actual);
        return Object.entries(this.borrador).map(([k, texto]) => {
            const [proyectoId, fecha] = k.split('|'), valor = analizarHoras(texto);
            const permitido = editable(this.actual, proyectoId, fecha) && !valor.error;
            const coincide = !valor.error && valor.minutos === (ahora[k] || 0);
            return { key: k, etiqueta: (this.confirmado.proyectos.find((p) => p.id === proyectoId)?.nombre || 'Proyecto') + ' · ' + etiquetaFecha(fecha), antes: totalTexto(antes[k] || 0), solicitado: texto.trim() === '' ? 'Eliminar dedicación' : texto + ' h', ahora: totalTexto(ahora[k] || 0), coincide, motivo: coincide ? 'El valor solicitado ya aparece guardado.' : permitido ? 'Puedes incorporarlo al borrador actualizado.' : 'No se puede reaplicar: revisa permisos, proyecto, fecha o cantidad.', deshabilitada: this.ocupado || !permitido || coincide, marcada: Boolean(this.seleccion[k]) };
        });
    }
    get todosCoinciden() { return this.actual && this.comparaciones.length > 0 && this.comparaciones.every((c) => c.coincide); }
    get reaplicarBloqueado() { return this.ocupado || !this.comparaciones.some((c) => c.marcada && !c.deshabilitada); }
    adoptar(s, conservarFilas = false) {
        this.confirmado = s; this.semana = s.semana; this.borrador = {}; this.textoEnEdicion = null;
        this.visibles = conservarFilas ? this.visibles.filter((id) => s.proyectos.some((p) => p.id === id)) : [];
        this.errores = []; this.actual = null; this.recuperacion = null; this.seleccion = {}; this.estado = 'listo';
    }
    async cargar(semana, inicial = false) {
        const turno = ++this.secuencia; this.semana = semana; this.estado = 'cargando'; this.errores = []; this.aviso = '';
        try {
            const r = interpretarRespuesta(await leerSemana({ inicioSemana: semana }), semana);
            if (turno !== this.secuencia) return;
            if (!r.ok) { this.errores = r.errores; this.estado = 'error'; this.foco = '[data-id="errores"]'; return; }
            if (inicial && lunesDe(r.estado.hoy) !== semana) { await this.cargar(lunesDe(r.estado.hoy)); return; }
            this.adoptar(r.estado);
        } catch {
            if (turno !== this.secuencia) return;
            this.estado = 'error'; this.errores = [{ mensaje: 'No se pudo consultar la semana. Puedes volver a actualizar.', proyectoId: null, fecha: null }]; this.foco = '[data-id="errores"]';
        }
    }
    async confirmarDescarte() {
        if (!this.pendiente) return true;
        this.decision = true;
        try { return await LightningConfirm.open({ label: 'Cambios pendientes', message: 'Se descartarán los cambios sin guardar de esta semana. ¿Quieres continuar?', variant: 'header' }); }
        catch { return false; }
        finally { this.decision = false; this.foco = '[data-id="semana"]'; }
    }
    async cambiarSemana(fecha) {
        if (this.navegacionBloqueada) return;
        let lunes;
        try { lunes = lunesDe(fecha); } catch { this.errores = [{ mensaje: 'Selecciona una fecha válida.', proyectoId: null, fecha: null }]; return; }
        if (lunes === this.semana) return;
        if (!(await this.confirmarDescarte())) return;
        this.borrador = {}; this.textoEnEdicion = null; this.cargar(lunes);
    }
    anterior() { this.cambiarSemana(sumarDias(this.semana, -7)); }
    siguiente() { this.cambiarSemana(sumarDias(this.semana, 7)); }
    elegirSemana(e) { const fecha = e.target.value; e.target.value = this.semana; this.cambiarSemana(fecha); }
    async actualizar() {
        if (this.navegacionBloqueada) return;
        if (!(await this.confirmarDescarte())) return;
        this.borrador = {}; this.textoEnEdicion = null; this.cargar(this.semana);
    }
    async descartar() {
        if (this.descartarBloqueado) return;
        if (await this.confirmarDescarte()) { this.borrador = {}; this.textoEnEdicion = null; this.errores = []; this.aviso = 'Cambios descartados. Se muestran los valores confirmados.'; }
    }
    incorporar(e) {
        if (this.selectorBloqueado) return;
        const id = e.detail.value;
        if (this.opciones.some((p) => p.value === id)) this.visibles = [...new Set([...this.visibles, id])];
        this.foco = '[data-key="' + clave(id, this.semana) + '"]';
    }
    quitar(e) {
        const fila = this.filas.find((f) => f.id === e.currentTarget.dataset.id);
        if (fila && !fila.quitarBloqueado) { this.textoEnEdicion = null; this.visibles = this.visibles.filter((id) => id !== fila.id); this.foco = '[data-id="proyecto"]'; }
    }
    editar(e) {
        const k = e.target.dataset.key, [p, d] = k.split('|');
        if (this.edicionBloqueada || !this.hayEstado || !editable(this.confirmado, p, d)) return;
        const texto = e.target.value, valor = analizarHoras(texto), base = valores(this.confirmado)[k] || 0;
        const siguiente = { ...this.borrador };
        if (!valor.error && valor.minutos === base) delete siguiente[k]; else siguiente[k] = texto;
        this.textoEnEdicion = { key: k, texto };
        this.borrador = siguiente; this.errores = []; this.aviso = '';
    }
    async guardar() {
        if (this.guardarBloqueado) return;
        const p = peticion(this.confirmado, this.borrador);
        if (p.errores.length) { this.errores = p.errores; this.foco = '[data-id="errores"]'; return; }
        const turno = ++this.secuencia, semana = this.semana;
        this.estado = 'guardando'; this.errores = []; this.aviso = '';
        try {
            const r = interpretarRespuesta(await guardarSemana({ peticionJson: JSON.stringify(p.valor) }), semana);
            if (turno !== this.secuencia) return;
            if (r.ok) {
                const recibidos = valores(r.estado);
                if (r.estado.revision === p.valor.revisionEsperada || !p.valor.cambios.every((c) => (recibidos[clave(c.proyectoId, c.fecha)] || 0) === analizarHoras(c.horas).minutos)) throw new Error('Confirmación inesperada');
                this.adoptar(r.estado, true); this.aviso = 'Cambios guardados y confirmados.'; this.foco = '[data-id="estado"]'; }
            else {
                this.estado = 'listo'; this.errores = r.errores;
                if (r.errores.some((e) => ['REVISION_DESACTUALIZADA', 'CONFLICTO_CREACION'].includes(e.codigo))) this.recuperacion = 'conflicto';
                if (r.errores.some((e) => e.codigo === 'CONTENCION')) this.aviso = 'La semana está ocupada. Conservamos tus cambios; vuelve a intentarlo cuando esté disponible.';
                this.foco = '[data-id="errores"]';
            }
        } catch {
            if (turno !== this.secuencia) return;
            this.estado = 'listo'; this.recuperacion = 'desconocido'; this.foco = '[data-id="recuperacion"]';
        }
    }
    async consultarActual() {
        if (!this.recuperacion || this.ocupado) return;
        const turno = ++this.secuencia; this.estado = 'cargando'; this.actual = null; this.seleccion = {}; this.errores = [];
        try {
            const r = interpretarRespuesta(await leerSemana({ inicioSemana: this.semana }), this.semana);
            if (turno !== this.secuencia) return;
            if (!r.ok) this.errores = r.errores; else this.actual = r.estado;
        } catch {
            if (turno !== this.secuencia) return;
            this.errores = [{ mensaje: 'No se pudo consultar el estado actual. Conservamos el borrador; el resultado sigue sin resolverse.', proyectoId: null, fecha: null }];
        } finally { if (turno === this.secuencia) { this.estado = 'listo'; this.foco = this.actual ? '[data-id="comparacion"]' : '[data-id="errores"]'; } }
    }
    seleccionarCambio(e) {
        const k = e.target.dataset.key;
        if (this.comparaciones.some((c) => c.key === k && !c.deshabilitada)) this.seleccion = { ...this.seleccion, [k]: e.target.checked };
    }
    reaplicar() {
        if (this.reaplicarBloqueado) return;
        const elegidos = Object.fromEntries(this.comparaciones.filter((c) => c.marcada && !c.deshabilitada).map((c) => [c.key, this.borrador[c.key]]));
        const ids = Object.keys(elegidos).map((k) => k.split('|')[0]);
        this.adoptar(this.actual); this.borrador = elegidos; this.visibles = ids;
        this.aviso = 'Selección incorporada al borrador. Revisa los totales y pulsa Guardar para confirmar.'; this.foco = '[data-id="estado"]';
    }
    async aceptarActual() {
        if (!this.actual || this.ocupado) return;
        if (await this.confirmarDescarte()) { this.adoptar(this.actual); this.aviso = 'Se muestra el estado actual. No se ha enviado otro guardado.'; this.foco = '[data-id="estado"]'; }
    }
}
