# P07 — Registro semanal de dedicación a proyectos en Salesforce

Aplicación de demostración para registrar dedicación propia por proyecto y día en una cuadrícula semanal de lunes a domingo. Utiliza exclusivamente proyectos y registros ficticios.

## Estado

Fase 1A preparada localmente el 24/11/2026: tres objetos, doce campos, nueve validaciones, total semanal y base de acceso de solo lectura mediante grupos y reglas estándar. La base inicial ya está publicada; el estado de las comprobaciones de esta entrega figura en [STATUS.md](docs/STATUS.md). No hay organización P07 vinculada, compilación remota, despliegue ni validación funcional. El servicio de guardado y la cuadrícula LWC siguen pendientes.

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
| `force-app/main/default` | Modelo declarativo, grupos, permisos de lectura y reglas de compartición |
| `manifest/fase-1a.xml` | Selección explícita del modelo y acceso de fase 1A |
| `sfdx-project.json` | Proyecto DX; API 65.0 provisional |
| `docs/PROJECT_BRIEF.md` | Objetivos, reglas y límites |
| `docs/MODELO_DATOS.md` | Modelo exacto y separación de restricciones declarativas y de servidor |
| `docs/ARQUITECTURA.md` | Guardado, concurrencia y decisiones de implementación |
| `docs/ACCESO.md` | Matriz de acceso e identidades de prueba |
| `docs/ACEPTACION.md` | Criterios y evidencia pendiente |
| `docs/ENVIRONMENT.md` | Herramientas observadas y destino pendiente |
| `docs/STATUS.md` | Estado y siguientes entregas |

## Preparación

El repositorio es independiente de los proyectos anteriores. No contiene credenciales, alias de destino, usuarios ni datos importados de otras organizaciones.

La base no necesita paquetes npm. Las dependencias de pruebas LWC se seleccionarán y fijarán junto con su lockfile al implementar la interfaz. La versión API se contrastará con el destino P07 antes del primer despliegue; su presencia en la configuración no acredita compatibilidad remota.
