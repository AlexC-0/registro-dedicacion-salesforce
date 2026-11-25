# P07 — Registro semanal de dedicación a proyectos en Salesforce

Aplicación de demostración para registrar dedicación propia por proyecto y día en una cuadrícula semanal de lunes a domingo. Utiliza exclusivamente proyectos y registros ficticios.

## Estado

Fase 4: informe comprobado en sesiones de A, B y coordinación; recorrido básico de teclado realizado y corrección decimal desplegada, con 49 pruebas Jest satisfactorias. Se retiró el permiso de ejecución de informes de las tres identidades al constatar acceso a un informe público ajeno. El informe queda instalado sin habilitación funcional; la fase y V1 permanecen abiertas. [STATUS.md](docs/STATUS.md) recoge resultados y [INFORME.md](docs/INFORME.md), uso y límites.

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
| `force-app/main/default` | Modelo, acceso, Apex, triggers, cuadrícula LWC y pruebas |
| `manifest/fase-1a.xml` | Selección explícita del modelo y acceso de fase 1A |
| `manifest/fase-2a.xml` | Servicio, triggers, permisos de operación y pruebas de fase 2A |
| `manifest/fase-3a.xml` | Bundle LWC, sin reinstalar el backend |
| `manifest/fase-3b.xml` | Aplicación, página, pestañas, layouts, vistas y perfil P07 |
| `manifest/fase-4.xml` | Informe, carpeta, permiso de ejecución y navegación |
| `manifest/revision-fase-4.xml` | Corrección acotada del bundle LWC |
| `package.json`, `package-lock.json`, `jest.config.js` | Dependencias locales fijadas y pruebas Jest |
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

Para las pruebas locales: npm ci y npm run test:unit; npm run test:unit:coverage genera cobertura. Dependencia de desarrollo fijada: @salesforce/sfdx-lwc-jest 7.1.2, comprobada con Node 24.13.0. No hay dependencias de interfaz. [INSTALACION.md](docs/INSTALACION.md) detalla prerrequisitos, despliegue e incorporación del componente a una página P07; la fase 3B habilitó la página y las identidades descritas en [ACCESO.md](docs/ACCESO.md).
