================
Especificaciones
================

Formulario de cliente
---------------------
* Cada cliente tiene que haber registrado sus datos personales antes de poner generar el movimiento.
* Al generar la declaración jurada del cliente se debe generar, a la vez, el movimiento dentro del sistema.

Movimientos
-----------
* Cada movimiento que supere los 10 000$ deben ser convertidos a operaciones.
* Si hay un conjunto de movimiento que tiene a la misma persona como beneficiario o quien solicita la el movimiento, dicho movimiento debe ser convertido a operación. Esto durante un mes.
* En los casos anteriores, se debe hacer la conversión de moneda de ser necesario.
* Después de un mes, el registro de movimientos será borrado.

Registro de Operaciones
-----------------------
* Después de un mes, el registro de operaciones será borrado, depués de pasar los registros existentes al historial de operaciones.

.. figure:: _static/model_dot.svg
   :alt: Modelo de Dominio (Detallado)
   :width: 100%