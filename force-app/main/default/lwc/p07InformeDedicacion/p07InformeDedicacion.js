import { LightningElement } from 'lwc';
import consultar from '@salesforce/apex/P07_InformeService.consultar';
import zona from '@salesforce/i18n/timeZone';
import { filtrosValidos, interpretar, lunesActual } from './modelo';

export default class P07InformeDedicacion extends LightningElement {
    modo = 'semana';
    desde = lunesActual(zona);
    hasta = this.desde;
    resultado;
    error = '';
    cargando = false;
    secuencia = 0;
    focoPendiente;
    opciones = [{label: 'Una semana', value: 'semana'}, {label: 'Intervalo de semanas', value: 'intervalo'}];
    get intervalo() { return this.modo === 'intervalo'; }
    get pendiente() { return !this.resultado && !this.cargando && !this.error; }
    get vacio() { return this.resultado && this.resultado.numeroLineas === 0; }
    get semanas() { return this.resultado ? this.resultado.semanas : []; }
    get hastaAplicable() { return this.intervalo ? this.hasta : this.desde; }

    cambiarFiltro(event) {
        const nombre = event.target.dataset.filtro;
        this[nombre] = event.detail.value;
        this.secuencia += 1;
        this.resultado = undefined;
        this.error = '';
        this.cargando = false;
        this.focoPendiente = undefined;
    }
    async ejecutar() {
        if (this.cargando) return;
        const desde = this.desde, hasta = this.hastaAplicable;
        const secuencia = ++this.secuencia;
        this.resultado = undefined;
        this.error = '';
        if (!filtrosValidos(desde, hasta)) {
            this.error = 'Selecciona lunes válidos; el inicio no puede ser posterior al final.';
            this.focoPendiente = '[data-error]';
            return;
        }
        this.cargando = true;
        try {
            const bruto = await consultar({peticionJson: JSON.stringify({desde, hasta})});
            if (secuencia !== this.secuencia) return;
            this.resultado = interpretar(bruto, desde, hasta);
            this.focoPendiente = '[data-resumen]';
        } catch (e) {
            if (secuencia !== this.secuencia) return;
            this.resultado = undefined;
            this.error = e instanceof Error && e.message ? e.message : 'No se pudo completar la consulta. Vuelve a intentarlo.';
            this.focoPendiente = '[data-error]';
        } finally {
            if (secuencia === this.secuencia) this.cargando = false;
        }
    }
    renderedCallback() {
        if (this.focoPendiente) {
            const nodo = this.template.querySelector(this.focoPendiente);
            if (nodo) { this.focoPendiente = undefined; nodo.focus(); }
        }
    }
}
