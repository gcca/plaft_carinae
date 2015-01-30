===================
Ciclo de desarrollo
===================

Detalle de la fase de desarrollo

..
   Ingreso de información
   ----------------------
   + Formulario de clientes
      A. Búsqueda e identificación por RUC o DNI
      B. Formulario de *persona natural* (leer, crear, actualizar)
      C. Formulario de *persona jurídica* (leer, crear, actualizar)
      D. PDF de declaración jurada
   + Tablero de control
      A. Lista de operaciones
      B. Actualizar estado de operación
   + Registro de operaciones
      A. Agregar operación
      B. Carga de formularios: Declarante, Ordenante, Destinatario, Tercero
   + Lista de alertas
      A. Checklist de alertas
      B. Guardar alertas y observaciones por operación

   ----

   Analítica
   ---------
   + GUI de notificaciones
      A. Notificaciones de operaciones inusuales
   + Métricas e indicadores


.. glossary:: *Glosario*

   Cliente
      Persona natural o jurídica que solicita los servicios
      del agente de aduanas

   Movimiento
      Paso previo al registro de operación.
      Cuando el cliente genera su declaración, se crea un movimiento.

   Operación
      Movimiento que, previa evaluación, pasa al registro de operaciones.
      Mantiene estados: en proceso y terminado.
      Cuando el estado es *terminado* la operación es declarada
      como inusual o no inusual.



Detalle de tareas
=================

1. Buscar cliente por número de documento de identidad.
2. Autocompletar los datos del cliente, si existe.
3. Crear/actualizar los datos del cliente.
4. Crear el movimiento, asociando al cliente y a la agencia de aduanas.
5. Evaluar el movimiento para convertirlo en operación.
6. Autenticar usuarios (oficial de cumplimiento -- asistentes).
7. Listar operaciones.
8. Editar datos de la operación.
9. Cambiar estado de la operación.
10. Marcar operación como inusual.
11. Reporte de operación inusual (afinar formato para la UIF).
12. Checklist con las señales de alert

Dependecias
-----------

.. tabularcolumns:: |c|l|r|

+----+---------------------+-------+
|  N | Requisito           | Dep.  |
+====+=====================+=======+
|  1 | Buscar cliente      |       |
+----+---------------------+-------+
|  2 | Autocompletar       |   1   |
+----+---------------------+-------+
|  3 | Datos de cliente    |   1   |
+----+---------------------+-------+
|  4 | Movimiento          |   1   |
+----+---------------------+-------+
|  5 | Evaluación          |       |
+----+---------------------+-------+
|  6 | Autenticar          |       |
+----+---------------------+-------+
|  7 | Listar operaciones  | 4 - 6 |
+----+---------------------+-------+
|  8 | Editar operación    | 4 - 7 |
+----+---------------------+-------+
|  9 | Estado de operación | 4 - 7 |
+----+---------------------+-------+
| 10 | Operación inusual   |   8   |
+----+---------------------+-------+
| 11 | Reporte inusual     |   8   |
+----+---------------------+-------+
| 12 | Checklist           | 7 - 8 |
+----+---------------------+-------+



Esfuerzo
--------

.. tabularcolumns:: |c|l|r|

+----+---------------------+-----+
|  N | Requisito           | D/H |
+====+=====================+=====+
|  1 | Buscar cliente      |   3 |
+----+---------------------+-----+
|  2 | Autocompletar       |   2 |
+----+---------------------+-----+
|  3 | Datos de cliente    |   1 |
+----+---------------------+-----+
|  4 | Movimiento          |   1 |
+----+---------------------+-----+
|  5 | Evaluación          |   1 |
+----+---------------------+-----+
|  6 | Autenticar          |   1 |
+----+---------------------+-----+
|  7 | Listar operaciones  |   2 |
+----+---------------------+-----+
|  8 | Editar operación    |   6 |
+----+---------------------+-----+
|  9 | Estado de operación |   1 |
+----+---------------------+-----+
| 10 | Operación inusual   |   2 |
+----+---------------------+-----+
| 11 | Reporte inusual     |     |
+----+---------------------+-----+
| 12 | Checklist           |  10 |
+----+---------------------+-----+



Descripción
-----------

1. Buscar cliente por número de documento de identidad.

   1. Validar si DNI o RUC.

2. Autocompletar los datos del cliente, si existe.

   1. Obtener desde BD.
   2. Consultar a servicio. (por implementar).

3. Crear/actualizar los datos del cliente.
4. Crear el movimiento, asociando al cliente y a la agencia de aduanas.

   1. Mostrar link a declaracion juarada en PDF.

5. Evaluar el movimiento para convertirlo en operación.

   1. Validar por cantidad.

6. Autenticar usuarios (oficial de cumplimiento -- asistentes).

   1. Redireccionar a dashboard.
   2. Dashboard debe mostrar las opciones:

      * listar operaciones,
      * nueva operación.

7. Listar operaciones.

   1. Mostrar:

      * Nombre del cliente,
      * Procentaje de avance de ingreso de datos,
      * Cambiar de estado,
      * Editar.

8. Editar datos de la operación.

   1. Mostrar los campos relacionados a la operación
   2. Para agregar al ordenante, declarante, intermediario, tercero, etc,
      se considerará un módulo para asociar personas dinámicamente.
      Cada *persona asociada* tendrá un **tag** para fijar el rol.

9. Cambiar estado de la operación.

   1. Preguntar si será declarado como inusual.

10. Marcar operación como inusual.

    1. Identificar con un color rojo si es inusual.

11. Reporte de operación inusual (afinar formato para la UIF).

    1. Averiguar el formato, si es PDF u otro formato digital.

12. Checklist con las señales de alert

    1. Pasar todas las señales de alerta como checklist.
    2. Clasificar las señales de alerta según el anexo 1.
    3. La interfaz del checklist debe estar acompañada con los datos
       que necesita el oficial de cumplimiento para realizar la evaluación.



Hitos
-----

1. Búsqueda cliente y registro del movimiento
2. PDF de la declaración jurada
3. Dashboard con lista de operaciones
4. Cambiar estado de operación
5. Panel de edición de operación
6. Checklist de señales de la operación
