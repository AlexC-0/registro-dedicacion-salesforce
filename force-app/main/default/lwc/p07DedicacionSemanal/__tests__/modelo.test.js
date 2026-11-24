import { fechaCivil, sumarDias, lunesDe, hoyEnZona, analizarHoras, interpretarRespuesta, proponer, peticion, limitesPeticion, clave } from '../modelo';
import { estado, bien, id, SEMANA } from './fixtures';

describe('Contrato y calendario', () => {
    test('calendario sin desplazamientos y semana en zona Salesforce', () => {
        expect(lunesDe('2026-01-01')).toBe('2025-12-29');
        expect(sumarDias('2025-12-29', 6)).toBe('2026-01-04');
        expect(sumarDias('2024-02-28', 1)).toBe('2024-02-29');
        expect(() => fechaCivil('2026-02-30')).toThrow();
        const instante = new Date('2026-11-23T00:30:00Z');
        expect(lunesDe(hoyEnZona(instante, 'America/Los_Angeles'))).toBe('2026-11-16');
        expect(lunesDe(hoyEnZona(instante, 'Europe/Madrid'))).toBe('2026-11-23');
    });
    test.each([['0,25',15,'0.25'],['1.50',90,'1.5'],['24',1440,'24'],['',0,''],['0',0,'0']])('normaliza %s sin redondear', (texto,minutos,horas) => expect(analizarHoras(texto)).toEqual({minutos,horas,error:null}));
    test.each(['0,001','0.10','1,000','1.000,25','-1','24,25','1e1','01','1,2.5','NaN'])('rechaza %s', (texto) => expect(analizarHoras(texto).error).toBeTruthy());
    test('respuesta coherente y revisión superior al entero seguro', () => {
        const s = estado({revision:'9007199254740993'});
        expect(interpretarRespuesta(bien(s), SEMANA).estado.revision).toBe('9007199254740993');
        for (const roto of [{...s,revision:9007199254740992},{...s,dias:[]},{...s,totalMinutos:61},{...s,entradas:[...s.entradas,...s.entradas]},{...s,proyectos:[]}]) expect(() => interpretarRespuesta(bien(roto),SEMANA)).toThrow();
        expect(() => interpretarRespuesta(s,SEMANA)).toThrow();
    });
    test('totales conservan omitidas e inactivas; inválidos no son exactos', () => {
        const s = estado({entradas:[{proyectoId:id(1),fecha:SEMANA,minutos:60},{proyectoId:id(2),fecha:SEMANA,minutos:120}],inactivos:[2]});
        expect(proponer(s,{[clave(id(1),SEMANA)]:'2'}).total).toBe(240);
        expect(proponer(s,{[clave(id(1),SEMANA)]:'0,001'}).total).toBeNull();
        expect(proponer(s,{[clave(id(2),SEMANA)]:''}).errores).toHaveLength(1);
        expect(proponer(s,{[clave(id(1),SEMANA)]:'24'}).errores[0].fecha).toBe(SEMANA);
    });
    test('envía solamente cambios explícitos y mantiene revisión textual', () => {
        const p = peticion(estado({revision:'9007199254740993'}),{[clave(id(1),SEMANA)]:''});
        expect(p.errores).toEqual([]);
        expect(p.valor).toEqual({semana:SEMANA,revisionEsperada:'9007199254740993',cambios:[{proyectoId:id(1),fecha:SEMANA,horas:''}]});
    });
    test('límites completos sin particionar: 140 celdas, 20 proyectos, 60000 caracteres', () => {
        const cambios=Array.from({length:140},(_,i)=>({proyectoId:id(i%20),fecha:'2026-11-16',horas:'0.25'}));
        const p={semana:SEMANA,revisionEsperada:'0',cambios};
        expect(limitesPeticion(p)).toEqual([]);
        expect(limitesPeticion({...p,cambios:[...cambios,cambios[0]]})[0].mensaje).toContain('140');
        expect(limitesPeticion({...p,cambios:Array.from({length:21},(_,i)=>({proyectoId:id(i),fecha:SEMANA,horas:'0.25'}))})[0].mensaje).toContain('20 proyectos');
        expect(limitesPeticion({...p,cambios:[{proyectoId:id(1),fecha:SEMANA,horas:'1'.repeat(60000)}]})[0].mensaje).toContain('tamaño');
    });
});
