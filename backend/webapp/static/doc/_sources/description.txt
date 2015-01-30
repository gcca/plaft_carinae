============================
Descripción de la Aplicación
============================

Recabar información de las operaciones que realizan las agencias de aduanas, sus clientes y trabajadores.

Usuarios
--------
Principal (Oficial de cumplimiento)
   Puede agregar nuevos usuarios y asignar permisos.

Subordinados (A cargo de módulos específicos)
   Tienen permisos para ciertos módulos.



Modelo de negocio
-----------------
User
   Base para entidades con acceso a la aplicación.

CustomsBrokerUser
   Usuarios asociados a una agencia de aduanas.

CustomsBroker
   Datos de la agencia de aduanas.

Movement
   Movimiento que es registrado al generar la declaración jurada.
   Previa validación, puede ser convertida en una entidad de tipo *Operation*.

Operation
   Operación que será analizada por el oficial de cumplimiento.

Customer
   Clientes de las agencias de aduanas. (Lista única y compartida.)

.. inheritance-diagram:: domain.model
   :parts: 1



Esquema de usuarios
-------------------
Existe un usuario *administrador* que puede trabajar con todos los módulos.
Dicho usuario puede creaer nuevos usuarios y asignarle accesos por módulos.

.. inheritance-diagram:: domain.model.CustomsBrokerUser
   :parts: 1



Mapa del proceso
----------------
.. figure:: _static/process.svg
   :alt: Mapa del proceso
   :width: 100%

.. figure:: _static/process2.svg
   :alt: Mapa del proceso 2
   :width: 100%

.. figure:: _static/process3.svg
   :alt: Mapa del proceso 3
   :width: 100%



Casos de uso
============

Solicitud del clientes
   El cliente ingresa al formulario (/customer-form) en el cual hace uso de su RUC o DNI para buscar sus datos. Si existe, sus datos aparecen completando los campos en el formulario, de lo contrario, los campos deben ser ingresados.
   Existe una sección de *movimiento* donde el cliente registra datos como: el monto, referencias del cliente, la agencia de aduana a la cual va dirigida la declaración jurada, entre otros.
   Internamente, la aplicación genera un nuevo movimiento y los analiza para convertirlo en operación, si es pertinente.

Dashboard del oficial de cumplimiento
   La pantalla principal del oficial de cumplimiento está orientada a mostrar la lista de las operaciones. Las clasifica: en proceso y terminado. Además hay un link hacia las opciones de edición

Checklist de señales de alerta
   En la lista de la operaciones, cada operación tiene un link hacia un pantalla divida en dos partes: la lista de las señales de alerta y los datos requeridos para el análisis.

Registro de empleados
   Previo al uso del software, la agencia de aduanas debe registrar a sus empledos; principalmente, a los despachadores. Cada despachador es asociado a alguna operación que se registre.

Opciones por operación
   En la lista de operaciones cada operación debe tener un esquema similar a:

   =========== ================= ========= ========= ========= ==========
   Orden (#)   Cliente           <Alertas> <Tipo>    <Estado>  <Opciones>
   =========== ================= ========= ========= ========= ==========
   123         Nestlé            <Button>  <Select>  <Select>  <Button>
   =========== ================= ========= ========= ========= ==========

      Alertas
         Botón como link hacia el checklist.
      Tipo
         Registro, inusual, sospechosa.
      Estado
         En proceso o pasar terminado.
      Opciones
         Dropdown para opciones como: reportar a la UIF,
         editar datos, entre otros.


.. note:: **Diferencia entre operación inusual y sospechosa**

   - Es inusual cuando la operación está fuera de lo límites *normales* de dinero y solicitudes de servicio.
   - Es sospechosa cuando, además de ser inusual, el oficial de cumplimiento considera que la operación puede producir lavado de activos. Por lo cual dicha operación es reportada como sospechosa a la UIF.



.. figure:: _static/customer-form.png
   :alt: Customer Form
   :width: 100%

----

.. figure:: _static/dashboard.png
   :alt: Customer Form
   :width: 100%

----



Flujo de información
--------------------

.. figure:: _static/flujo-de-informacion.svg
   :alt: Info Flow
   :width: 100%



Modelo de dominio
-----------------
Esquema inicial de las relaciones entre entidades.

.. figure:: _static/model.svg
   :alt: Domain Model
   :width: 100%
