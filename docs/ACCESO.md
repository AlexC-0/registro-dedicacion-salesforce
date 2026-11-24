# Acceso e identidades

## Matriz funcional

| Recurso | Miembro | Coordinación | Identidad fuera del ámbito |
|---|---|---|---|
| Catálogo de proyectos | Lectura | Lectura | Según permisos de catálogo; no implica acceso a dedicación ajena |
| Semana propia | Lectura y guardado autorizado | Solo si además tiene función de miembro | Solo su propia semana si es miembro |
| Dedicación de miembros del ámbito | Sin acceso adicional | Lectura | Sin acceso |
| Dedicación fuera del ámbito | Sin acceso | Sin acceso | Sin acceso adicional |
| Revisión, claves y propiedad | Sin edición directa | Sin edición directa | Sin edición directa |
| Administración del catálogo | No incluida | No incluida | No incluida |

La cuenta técnica de instalación se distingue de las funciones anteriores. No se conceden Author Apex, Modify All Data ni permisos administrativos generales a participantes o coordinación.

## Diseño pendiente de implementación

Las cabeceras tendrán acceso privado y las líneas dependerán de su cabecera. La lectura de coordinación requiere una compartición acotada. Se propone un ámbito explícito de miembros y un grupo de coordinación asociado, sin conceder edición por jerarquía de roles.

La pertenencia concreta al ámbito y los mecanismos de compartición deben quedar definidos antes de desplegar seguridad. El catálogo de proyectos no define implícitamente ese ámbito. La autorización se comprobará también en Apex, junto con acceso a objetos, campos y registros.

## Verificación del destino

En una organización identificada exclusivamente para P07 se comprobarán edición, identidad, licencias totales y usadas, y usuarios disponibles. Se requieren identidades diferenciadas para miembro, coordinación y una persona fuera del ámbito; ninguna se da por disponible en esta entrega.

Las licencias deben permitir los objetos personalizados, la interfaz y las funciones de informe previstas. Un inventario de licencias no acredita permisos efectivos. No se desactivarán usuarios de otros proyectos para obtener capacidad.

Las pruebas cubrirán interfaz y rutas de acceso habilitadas con cada identidad. Los resultados de administrador y las consultas de acceso son evidencia técnica parcial, no sustitutos de esas sesiones.
