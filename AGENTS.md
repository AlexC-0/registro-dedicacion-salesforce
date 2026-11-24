# P07 — Registro semanal de dedicación

## Contexto

Proyecto independiente de demostración con datos ficticios. Consultar README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md antes de trabajar; consultar docs/MODELO_DATOS.md y docs/ACCESO.md antes de modificar modelo o permisos.

Conservar cambios existentes y comprobar raíz, rama, remotos y estado Git antes de editar. No utilizar repositorios, organizaciones, datos ni configuraciones de otros proyectos como destino o material de implementación.

## Desarrollo

Mantener minutos enteros, semanas de lunes a domingo, unicidad canónica, límite diario agregado, guardado atómico y control de revisión. Las invariantes deben estar protegidas en servidor en todas las rutas de escritura expuestas. No confiar en usuario, propietario, claves, revisiones nuevas o permisos suministrados por el cliente.

La coordinación consulta dentro de su ámbito y no edita dedicación ajena. No sustituir comprobaciones por función con pruebas de administrador. Preservar el borrador ante validaciones, errores y conflictos.

No añadir Flow, Batch Apex, integraciones, programación ni dependencias sin una necesidad funcional concreta. No utilizar producción ni datos reales.

## Entorno y comprobaciones

Toda operación remota debe utilizar un destino expresamente identificado para P07 y especificarlo en el comando. Un alias por sí solo no acredita la identidad ni la exclusividad de una organización. No modificar herramientas globales ni reutilizar usuarios de otros trabajos.

Distinguir revisión estática, conversión local, compilación en Salesforce, despliegue, pruebas Apex, pruebas LWC y comprobación funcional. Registrar resultados realmente obtenidos y conservar fallos relevantes sin presentarlos como éxitos. No publicar secretos, tokens, archivos de autenticación ni enlaces reutilizables de acceso.

## Documentación

Castellano técnico, directo y neutral. Documentar comportamiento, decisiones, comprobaciones y limitaciones. No incluir relatos de conversaciones, atribuciones de elaboración, autorreferencias, firmas ni coautorías automáticas. Conservar licencias y créditos legales de terceros. No copiar encargos operativos al repositorio.

Los títulos de commit propuestos siguen el formato `tipo: descripción`, sin ámbitos entre paréntesis.
