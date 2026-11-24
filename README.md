# P07 — Registro semanal de dedicación a proyectos en Salesforce

Aplicación de demostración para registrar dedicación propia por proyecto y día en una cuadrícula semanal de lunes a domingo. Utiliza exclusivamente proyectos y registros ficticios.

## Estado

Fase 2A completada: servicio Apex de lectura y guardado propio, protección de escrituras y 18 pruebas aisladas superadas. Paquete validado, desplegado y contrastado en la Developer Edition compartida con P06; cobertura del servicio 97,87 %. P06 conservado dentro del alcance revisado. Grupos vacíos, permisos sin asignar y cero datos persistentes P07. [STATUS.md](docs/STATUS.md) recoge resultados y límites. LWC, informe, sesiones ordinarias y concurrencia real permanecen pendientes; V1 no está cerrada.

## Alcance V1

- Cuadrícula LWC con borrador local y guardado conjunto mediante Apex.
- Horas decimales en incrementos exactos de 0,25; persistencia en minutos enteros.
- Validación en servidor, unicidad y protección frente a pantallas desactualizadas.
- Consulta de coordinación limitada a su ámbito e informe operativo.
- Permisos proporcionados y comprobaciones automatizadas y funcionales.

No incluye nóminas, facturación, control horario con validez laboral, aprobaciones, cierres, capacidad prevista, cronómetros, fichajes, integraciones, procesos programados, funcionamiento sin conexión, producción ni datos reales.

## Estructura

| Ruta | Contenido |
|---|---|
| `force-app/main/default` | Modelo, acceso, servicio Apex, triggers y pruebas aisladas |
| `manifest/fase-1a.xml` | Selección explícita del modelo y acceso de fase 1A |
| `manifest/fase-2a.xml` | Servicio, triggers, permisos de operación y pruebas de fase 2A |
| `sfdx-project.json` | Proyecto DX; API 65.0 |
| `docs/PROJECT_BRIEF.md` | Objetivos, reglas y límites |
| `docs/MODELO_DATOS.md` | Modelo exacto y separación de restricciones declarativas y de servidor |
| `docs/ARQUITECTURA.md` | Guardado, concurrencia y decisiones de implementación |
| `docs/ACCESO.md` | Matriz de acceso e identidades de prueba |
| `docs/ACEPTACION.md` | Criterios y evidencia pendiente |
| `docs/ENVIRONMENT.md` | Herramientas y destino compartido verificado |
| `docs/STATUS.md` | Estado y siguientes entregas |
| `docs/INSTALACION.md` | Destino, validación remota, instalación y jerarquía |

## Preparación

El repositorio es independiente y el destino de desarrollo se comparte con P06. Las operaciones usan un alias explícito cuya identidad se verifica con un registro privado. El repositorio no contiene credenciales, usuarios reales ni datos importados de otras organizaciones.

La base no necesita paquetes npm. Las dependencias de pruebas LWC se seleccionarán y fijarán junto con su lockfile al implementar la interfaz. API 65.0 y los metadatos declarativos se contrastaron en fase 1B; la aplicación completa y sus dependencias futuras requieren sus propias comprobaciones.
