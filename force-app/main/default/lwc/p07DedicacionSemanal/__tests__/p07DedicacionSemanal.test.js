import { createElement } from 'lwc';
import Componente from 'c/p07DedicacionSemanal';
import leerSemana from '@salesforce/apex/P07_DedicacionService.leerSemana';
import guardarSemana from '@salesforce/apex/P07_DedicacionService.guardarSemana';
import LightningConfirm from 'lightning/confirm';
import { estado, bien, mal, id, SEMANA, diferida } from './fixtures';

jest.mock('@salesforce/apex/P07_DedicacionService.leerSemana', () => ({__esModule:true,default:jest.fn()}), {virtual:true});
jest.mock('@salesforce/apex/P07_DedicacionService.guardarSemana', () => ({__esModule:true,default:jest.fn()}), {virtual:true});
jest.mock('@salesforce/i18n/timeZone', () => ({__esModule:true,default:'Europe/Madrid'}), {virtual:true});
jest.mock('lightning/confirm', () => ({__esModule:true,default:{open:jest.fn()}}), {virtual:true});
const flush = async () => { for(let i=0;i<12;i++) await Promise.resolve(); };
const q=(e,n)=>e.shadowRoot.querySelector('[data-id="'+n+'"]');
const celda=(e,n,fecha=SEMANA)=>e.shadowRoot.querySelector('[data-id="celda"][data-key="'+id(n)+'|'+fecha+'"]');
const click=async(e,n)=>{q(e,n).click();await flush();};
const editar=async(e,n,valor,fecha=SEMANA)=>{const input=celda(e,n,fecha); input.value=valor;input.dispatchEvent(new CustomEvent('change'));await flush();};
const incorporar=async(e,n)=>{q(e,'proyecto').dispatchEvent(new CustomEvent('change',{detail:{value:id(n)}}));await flush();};
async function montar(s=estado()) { leerSemana.mockResolvedValueOnce(bien(s));const e=createElement('c-p07-dedicacion-semanal',{is:Componente});document.body.appendChild(e);await flush();return e; }
beforeEach(()=>{jest.useFakeTimers();jest.setSystemTime(new Date('2026-11-18T12:00:00Z'));leerSemana.mockReset();guardarSemana.mockReset();LightningConfirm.open.mockReset();LightningConfirm.open.mockResolvedValue(false);});
afterEach(()=>{while(document.body.firstChild)document.body.removeChild(document.body.firstChild);jest.useRealTimers();});

test('carga siete días y solo filas persistidas; selector añade sin borrar',async()=>{
    const e=await montar();expect(leerSemana).toHaveBeenCalledWith({inicioSemana:SEMANA});
    expect(e.shadowRoot.querySelectorAll('thead th')).toHaveLength(10);
    expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(1);
    await incorporar(e,2);expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(2);
    expect(q(e,id(1)).disabled).toBe(true);await click(e,id(2));expect(e.shadowRoot.querySelectorAll('tbody tr')).toHaveLength(1);
    expect(guardarSemana).not.toHaveBeenCalled();
});
test('semana que cruza año y respuesta inicial ajustada por hoy del servidor',async()=>{
    jest.setSystemTime(new Date('2026-01-01T12:00:00Z'));
    const e=await montar(estado({semana:'2025-12-29',hoy:'2026-01-01',entradas:[]}));
    expect(leerSemana).toHaveBeenCalledWith({inicioSemana:'2025-12-29'});expect(e.shadowRoot.textContent).toContain('4 ene 2026');
});
test('borrador conserva original, normaliza coma, revierte y elimina explícitamente',async()=>{
    const e=await montar();await editar(e,1,'1,25');expect(q(e,'estado').textContent).toContain('1 celdas');expect(q(e,'total').textContent).toContain('1,25 h');expect(e.shadowRoot.textContent).toContain('1 h');
    await editar(e,1,'1,00');expect(q(e,'guardar').disabled).toBe(true);
    await editar(e,1,'');guardarSemana.mockResolvedValueOnce(bien(estado({revision:'2',entradas:[]})));await click(e,'guardar');
    expect(JSON.parse(guardarSemana.mock.calls[0][0].peticionJson).cambios).toEqual([{proyectoId:id(1),fecha:SEMANA,horas:''}]);expect(q(e,'estado').textContent).toContain('confirmados');
});
test('texto inválido se conserva, totales no exactos y servidor no invocado',async()=>{
    const e=await montar();await editar(e,1,'0,001');await click(e,'guardar');
    expect(celda(e,1).value).toBe('0,001');expect(q(e,'total').textContent).toContain('Pendiente de corregir');expect(q(e,'errores')).not.toBeNull();expect(guardarSemana).not.toHaveBeenCalled();
});
test('totales incluyen líneas omitidas e histórico inactivo',async()=>{
    const e=await montar(estado({entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:60},{proyectoId:id(2),fecha:SEMANA,minutos:120}],inactivos:[2]}));
    expect(celda(e,2).disabled).toBe(true);await editar(e,1,'24');await click(e,'guardar');expect(q(e,'total').textContent).toContain('26 h');expect(q(e,'errores').textContent).toContain('supera 24');expect(guardarSemana).not.toHaveBeenCalled();
});
test('un guardado conjunto, revisión textual grande y bloqueo durante el envío',async()=>{
    const e=await montar(estado({revision:'9007199254740993'}));await incorporar(e,2);await editar(e,1,'2,25');await editar(e,2,'0,5');
    const d=diferida();guardarSemana.mockReturnValueOnce(d.promise);await click(e,'guardar');await click(e,'guardar');await click(e,'siguiente');await editar(e,1,'4');
    expect(guardarSemana).toHaveBeenCalledTimes(1);expect(q(e,'semana').disabled).toBe(true);expect(celda(e,1).disabled).toBe(true);expect(leerSemana).toHaveBeenCalledTimes(1);
    const p=JSON.parse(guardarSemana.mock.calls[0][0].peticionJson);expect(p.revisionEsperada).toBe('9007199254740993');expect(p.cambios.map(c=>c.horas)).toEqual(['2.25','0.5']);expect(Object.keys(p).sort()).toEqual(['cambios','revisionEsperada','semana']);
    d.resolve(bien(estado({revision:'9007199254740994',entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:135},{proyectoId:id(2),fecha:SEMANA,minutos:30}]})));await flush();expect(q(e,'total').textContent).toContain('2,75 h');expect(q(e,'guardar').disabled).toBe(true);
});
test.each([[id(1),SEMANA,'celda'],[null,SEMANA,'día'],[null,null,'conjunto']])('error contextual %s %s conserva borrador',async(p,f,n)=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockResolvedValueOnce(mal('VALIDACION',p,f,'Error de '+n));await click(e,'guardar');expect(celda(e,1).value).toBe('2');expect(q(e,'errores').textContent).toContain('Error de '+n);expect(q(e,'estado').textContent).not.toContain('guardados y confirmados');
});
test.each(['REVISION_DESACTUALIZADA','CONFLICTO_CREACION'])('conflicto %s exige lectura y selección explícita',async(codigo)=>{
    const e=await montar();await incorporar(e,2);await editar(e,1,'2');await editar(e,2,'0,5');guardarSemana.mockResolvedValueOnce(mal(codigo));await click(e,'guardar');expect(q(e,'guardar').disabled).toBe(true);
    leerSemana.mockResolvedValueOnce(bien(estado({revision:'8',entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:90},{proyectoId:id(3),fecha:SEMANA,minutos:30}]})));await click(e,'consultar');
    expect(q(e,'comparacion').textContent).toContain('Ahora: 1,5 h');expect(q(e,'reaplicar').disabled).toBe(true);expect(guardarSemana).toHaveBeenCalledTimes(1);
    const checkbox=e.shadowRoot.querySelector('[data-id="seleccion"][data-key="'+id(1)+'|'+SEMANA+'"]');checkbox.checked=true;checkbox.dispatchEvent(new CustomEvent('change'));await flush();await click(e,'reaplicar');
    expect(guardarSemana).toHaveBeenCalledTimes(1);expect(celda(e,1).value).toBe('2');expect(celda(e,3).value).toBe('0,5');expect(celda(e,2)).toBeNull();
    guardarSemana.mockResolvedValueOnce(bien(estado({revision:'9',entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:120},{proyectoId:id(3),fecha:SEMANA,minutos:30}]})));await click(e,'guardar');
    const p=JSON.parse(guardarSemana.mock.calls[1][0].peticionJson);expect(p.revisionEsperada).toBe('8');expect(p.cambios).toHaveLength(1);expect(p.cambios[0].proyectoId).toBe(id(1));
});
test('reaplicación respeta desactivación y retirada de permiso',async()=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockResolvedValueOnce(mal('REVISION_DESACTUALIZADA'));await click(e,'guardar');
    leerSemana.mockResolvedValueOnce(bien(estado({revision:'2',puedeGuardar:false,inactivos:[1]})));await click(e,'consultar');expect(q(e,'seleccion').disabled).toBe(true);expect(q(e,'reaplicar').disabled).toBe(true);expect(celda(e,1).value).toBe('2');
});
test('contención conserva y no reintenta automáticamente',async()=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockResolvedValueOnce(mal('CONTENCION',null,null,'No se pudo completar la operación. Recarga antes de volver a intentarlo.'));await click(e,'guardar');expect(celda(e,1).value).toBe('2');expect(q(e,'estado').textContent).toContain('La semana está ocupada');expect(guardarSemana).toHaveBeenCalledTimes(1);
});
test('cambio de semana requiere decidir, cancelación conserva',async()=>{
    const e=await montar();await editar(e,1,'2');await click(e,'siguiente');expect(LightningConfirm.open).toHaveBeenCalledTimes(1);expect(leerSemana).toHaveBeenCalledTimes(1);expect(celda(e,1).value).toBe('2');
    LightningConfirm.open.mockResolvedValueOnce(true);leerSemana.mockResolvedValueOnce(bien(estado({semana:'2026-11-23',revision:'0',entradas:[]})));await click(e,'siguiente');expect(leerSemana).toHaveBeenLastCalledWith({inicioSemana:'2026-11-23'});expect(q(e,'vacio')).not.toBeNull();
});
test('actualizar y descartar requieren decisión explícita',async()=>{
    const e=await montar();await editar(e,1,'2');await click(e,'actualizar');expect(leerSemana).toHaveBeenCalledTimes(1);await click(e,'descartar');expect(celda(e,1).value).toBe('2');
    LightningConfirm.open.mockResolvedValueOnce(true);await click(e,'descartar');expect(celda(e,1).value).toBe('1');expect(q(e,'guardar').disabled).toBe(true);
});
test('lecturas fuera de orden no sustituyen la selección más reciente',async()=>{
    const primera=diferida(),segunda=diferida();leerSemana.mockReturnValueOnce(primera.promise).mockReturnValueOnce(segunda.promise);
    const e=createElement('c-p07-dedicacion-semanal',{is:Componente});document.body.appendChild(e);await flush();await click(e,'siguiente');
    segunda.resolve(bien(estado({semana:'2026-11-23',revision:'0',entradas:[]})));await flush();primera.resolve(bien(estado()));await flush();expect(q(e,'semana').value).toBe('2026-11-23');expect(q(e,'vacio')).not.toBeNull();
});
test('transporte perdido y valores actuales coincidentes no atribuyen confirmación',async()=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockRejectedValueOnce(new Error('red'));await click(e,'guardar');expect(q(e,'estado').textContent).toContain('Resultado desconocido');expect(q(e,'guardar').disabled).toBe(true);
    leerSemana.mockResolvedValueOnce(bien(estado({revision:'2',entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:120}]})));await click(e,'consultar');expect(q(e,'comparacion').textContent).toContain('no confirma qué petición');expect(guardarSemana).toHaveBeenCalledTimes(1);
    LightningConfirm.open.mockResolvedValueOnce(true);await click(e,'aceptar');expect(q(e,'estado').textContent).toContain('No se ha enviado otro guardado');expect(q(e,'guardar').disabled).toBe(true);
});
test('reconciliación fallida mantiene incertidumbre y borrador',async()=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockRejectedValueOnce(new Error('red'));await click(e,'guardar');leerSemana.mockRejectedValueOnce(new Error('red'));await click(e,'consultar');
    expect(q(e,'estado').textContent).toContain('Resultado desconocido');expect(celda(e,1).value).toBe('2');expect(q(e,'guardar').disabled).toBe(true);expect(q(e,'errores').textContent).toContain('sigue sin resolverse');
});
test.each(['', '{', JSON.stringify({ok:true,estado:{},errores:[]})])('respuesta inválida al guardar conserva borrador e incertidumbre: %s',async(texto)=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockResolvedValueOnce(texto);await click(e,'guardar');expect(q(e,'estado').textContent).toContain('Resultado desconocido');expect(celda(e,1).value).toBe('2');
});
test('lectura inválida no muestra datos como confirmados',async()=>{
    leerSemana.mockResolvedValueOnce('no json');const e=createElement('c-p07-dedicacion-semanal',{is:Componente});document.body.appendChild(e);await flush();expect(q(e,'errores').textContent).toContain('No se pudo consultar');expect(q(e,'guardar')).toBeNull();
});
test('sin permiso y fechas futuras no admiten edición',async()=>{
    const e=await montar(estado({puedeGuardar:false}));expect(celda(e,1).disabled).toBe(true);expect(q(e,'proyecto').disabled).toBe(true);await editar(e,1,'2');expect(q(e,'guardar').disabled).toBe(true);
    document.body.removeChild(e);const otro=await montar();expect(celda(otro,1,'2026-11-19').disabled).toBe(true);await editar(otro,1,'2','2026-11-19');expect(q(otro,'guardar').disabled).toBe(true);
});
test('21 proyectos se rechazan sin fragmentar ni perder cambios',async()=>{
    const e=await montar(estado({proyectos:21,revision:'0',entradas:[]}));
    for(let n=1;n<=21;n++){await incorporar(e,n);await editar(e,n,'0,25');}
    await click(e,'guardar');expect(guardarSemana).not.toHaveBeenCalled();expect(q(e,'errores').textContent).toContain('20 proyectos');expect(celda(e,21).value).toBe('0,25');
});

test('hoy del servidor corrige la semana inicial si el reloj difiere',async()=>{
    leerSemana.mockResolvedValueOnce(bien(estado({hoy:'2026-11-23'}))).mockResolvedValueOnce(bien(estado({semana:'2026-11-23',hoy:'2026-11-23',revision:'0',entradas:[]})));
    const e=createElement('c-p07-dedicacion-semanal',{is:Componente});document.body.appendChild(e);await flush();
    expect(leerSemana).toHaveBeenCalledTimes(2);expect(q(e,'semana').value).toBe('2026-11-23');
});
test('confirmación coherente pero sin los valores enviados mantiene incertidumbre',async()=>{
    const e=await montar();await editar(e,1,'2');guardarSemana.mockResolvedValueOnce(bien(estado({revision:'2'})));await click(e,'guardar');
    expect(q(e,'estado').textContent).toContain('Resultado desconocido');expect(celda(e,1).value).toBe('2');
});
test('error de lectura antiguo no sustituye una lectura nueva',async()=>{
    const primera=diferida(),segunda=diferida();leerSemana.mockReturnValueOnce(primera.promise).mockReturnValueOnce(segunda.promise);
    const e=createElement('c-p07-dedicacion-semanal',{is:Componente});document.body.appendChild(e);await flush();await click(e,'anterior');
    segunda.resolve(bien(estado({semana:'2026-11-09',revision:'0',entradas:[]})));await flush();primera.reject(new Error('red'));await flush();
    expect(q(e,'semana').value).toBe('2026-11-09');expect(q(e,'errores')).toBeNull();
});
test('etiquetas y foco de error en DOM; diálogo cancelado vuelve al selector',async()=>{
    const e=await montar();expect(celda(e,1).label).toContain('Proyecto 1');expect(celda(e,1).label).toContain('16 nov');
    expect(e.shadowRoot.querySelector('tbody th').getAttribute('scope')).toBe('row');expect(e.shadowRoot.querySelector('.cuadricula').getAttribute('tabindex')).toBe('0');
    await editar(e,1,'0,001');await click(e,'guardar');expect(e.shadowRoot.activeElement).toBe(q(e,'errores'));
    const foco=jest.spyOn(q(e,'semana'),'focus');await click(e,'siguiente');expect(foco).toHaveBeenCalled();
});

test('conserva el cero al corregir una celda vacía carácter a carácter',async()=>{
    const e=await montar();await incorporar(e,2);await editar(e,2,'0,3');
    await editar(e,2,'0');
    expect(celda(e,2).value).toBe('0');
    expect(q(e,'guardar').disabled).toBe(true);
    await editar(e,2,celda(e,2).value+',');
    await editar(e,2,celda(e,2).value+'5');
    expect(celda(e,2).value).toBe('0,5');
    expect(q(e,'errores')).toBeNull();
    expect(q(e,'total').textContent).toContain('1,5 h');
    expect(guardarSemana).not.toHaveBeenCalled();
    LightningConfirm.open.mockResolvedValueOnce(true);await click(e,'descartar');
    expect(celda(e,2).value).toBe('');
    expect(q(e,'guardar').disabled).toBe(true);
    expect(q(e,'total').textContent).toContain('1 h');
});

test.each(['rechazo de promesa','respuesta ok=false'])('actualizar tras aceptar descarte limpia la presentación aunque falle: %s',async(tipo)=>{
    const e=await montar();await editar(e,1,'2');
    const lectura=diferida();leerSemana.mockReturnValueOnce(lectura.promise);
    LightningConfirm.open.mockResolvedValueOnce(true);await click(e,'actualizar');
    if(tipo==='rechazo de promesa')lectura.reject(new Error('red'));
    else lectura.resolve(mal('ACCESO_DENEGADO',null,null,'Lectura denegada.'));
    await flush();
    expect(q(e,'errores')).not.toBeNull();
    expect(celda(e,1).value).toBe('1');
    expect(q(e,'total').textContent).toBe('1 h');
    expect(q(e,'estado').textContent).toBe('Sin cambios pendientes.');
    expect(q(e,'guardar').disabled).toBe(true);
    expect(q(e,'descartar').disabled).toBe(true);
    expect(guardarSemana).not.toHaveBeenCalled();
});

test.each(['rechazo de promesa','respuesta ok=false'])('cambio de semana descarta presentación incluso si fallan las lecturas: %s',async(tipo)=>{
    const e=await montar();await editar(e,1,'2');
    const fallar=()=>tipo==='rechazo de promesa'
        ? leerSemana.mockRejectedValueOnce(new Error('red'))
        : leerSemana.mockResolvedValueOnce(mal('ACCESO_DENEGADO'));
    LightningConfirm.open.mockResolvedValueOnce(true);fallar();await click(e,'siguiente');
    expect(q(e,'semana').value).toBe('2026-11-23');
    expect(celda(e,1)).toBeNull();
    expect(q(e,'errores')).not.toBeNull();
    fallar();await click(e,'anterior');
    expect(q(e,'semana').value).toBe(SEMANA);
    expect(q(e,'errores')).not.toBeNull();
    expect(celda(e,1).value).toBe('1');
    expect(q(e,'total').textContent).toBe('1 h');
    expect(q(e,'estado').textContent).toBe('Sin cambios pendientes.');
    expect(q(e,'guardar').disabled).toBe(true);
    expect(LightningConfirm.open).toHaveBeenCalledTimes(1);
    expect(guardarSemana).not.toHaveBeenCalled();
});

test.each(['actualizar','siguiente','descartar'])('cancelar %s conserva texto, borrador y total',async(accion)=>{
    const e=await montar();await editar(e,1,'2,00');await click(e,accion);
    expect(LightningConfirm.open).toHaveBeenCalledTimes(1);
    expect(leerSemana).toHaveBeenCalledTimes(1);
    expect(q(e,'semana').value).toBe(SEMANA);
    expect(celda(e,1).value).toBe('2,00');
    expect(q(e,'total').textContent).toBe('2 h');
    expect(q(e,'estado').textContent).toContain('1 celdas con cambios pendientes');
    expect(q(e,'guardar').disabled).toBe(false);
    expect(q(e,'descartar').disabled).toBe(false);
    expect(guardarSemana).not.toHaveBeenCalled();
});

test('adoptar estado actual sustituye presentación solo tras aceptar',async()=>{
    const e=await montar();await editar(e,1,'2,00');
    guardarSemana.mockResolvedValueOnce(mal('REVISION_DESACTUALIZADA'));await click(e,'guardar');
    leerSemana.mockResolvedValueOnce(bien(estado({revision:'2',entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:90}]})));
    await click(e,'consultar');await click(e,'aceptar');
    expect(celda(e,1).value).toBe('2,00');expect(q(e,'total').textContent).toBe('2 h');
    LightningConfirm.open.mockResolvedValueOnce(true);await click(e,'aceptar');
    expect(celda(e,1).value).toBe('1,5');expect(q(e,'total').textContent).toBe('1,5 h');
    expect(q(e,'guardar').disabled).toBe(true);expect(q(e,'descartar').disabled).toBe(true);
    expect(guardarSemana).toHaveBeenCalledTimes(1);
});
