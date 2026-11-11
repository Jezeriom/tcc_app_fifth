# GUION DE SUSTENTACIÓN Y EXPOSICIÓN ACADÉMICA - ACTIVIDAD TCC
## Sistema de Gestión de Inventarios Offline en Flutter ("Inventario / StockMaster")

**Institución:** Universidad de Cartagena / Facultad de Ingeniería  
**Programa:** Ingeniería de Software – Semestre V  
**Asignatura:** Desarrollo de Aplicaciones Móviles  
**Docente Tutor:** Elkin José Navarro Osorio  
**CIPA:** Jezer Martínez Pérez | Mariana Camila Olmos Pérez | Jesús David Guerrero Rada  
**Tiempo Total Estimado:** 12 a 15 minutos (4 a 5 minutos por persona + ronda de preguntas)

---

## 🎯 ESTRUCTURA GENERAL DE LA EXPOSICIÓN

| Integrante | Rol en la Sustentación | Ejes Temáticos Principales | Fases del TCC Cubiertas | Tiempo |
| :--- | :--- | :--- | :--- | :---: |
| **Persona 1** *(Ej. Jezer Martínez Pérez)* | **Líder de Producto & Arquitecto UI/UX** | Introducción, Problemática del Comercio Local, Arquitectura por Capas (Provider/MVVM), Identidad Material Design 3, Dashboard de KPIs y Catálogo con Filtros. | **Fase 1 y Fase 3 (Presentación)** | 4 - 5 min |
| **Persona 2** *(Ej. Mariana Camila Olmos Pérez)* | **Ingeniera de Datos & Lógica de Negocio** | Persistencia Local SQLite, Esquema Relacional DDL, Integridad Referencial (`PRAGMA foreign_keys`), Transacciones ACID indivisibles y Soporte Híbrido Móvil/Web. | **Fase 2 y Reglas de Negocio** | 4 - 5 min |
| **Persona 3** *(Ej. Jesús David Guerrero Rada)* | **Ingeniero de Calidad (QA), Analítica y Cierre** | Historial de Movimientos y Auditoría, Valorización Financiera del Inventario, Suite de Pruebas Unitarias 6/6 (100% de éxito), Demostración Práctica en Vivo y Conclusiones. | **Fase 4, Fase 5 y Demo Técnica** | 4 - 5 min |

---

## 📋 GUION DETALLADO POR EXPOSITOR

```
========================================================================================
PERSONA 1: CONTEXTO, ARQUITECTURA DEL SOFTWARE Y EXPERIENCIA DE USUARIO (UI/UX)
========================================================================================
```
* **Tiempo asignado:** 00:00 a 04:30 (4:30 min)
* **Objetivo:** Captar la atención del docente, contextualizar la necesidad real de los comerciantes, exponer la arquitectura de software elegida y mostrar la interfaz visual de entrada.

### 1. Saludo Institucional e Introducción (01:00 min)
* **Qué decir:**
  > *"Muy buenos días / tardes, profesor Elkin José Navarro Osorio y compañeros. A nombre de nuestro CIPA, conformado por Mariana Camila Olmos, Jesús David Guerrero y mi persona Jezer Martínez, nos complace presentar la sustentación de nuestro Trabajo Colaborativo Contextualizado para la asignatura de Desarrollo de Aplicaciones Móviles."*
  >
  > *"El proyecto que desarrollamos es una solución móvil integral para la **Gestión de Inventarios en pequeños y medianos comercios**, concebida bajo una filosofía estricta de **Offline-First**. En el comercio real, muchas bodegas, minimercados o almacenes operan en sótanos, zonas rurales o lugares donde la conexión a internet es intermitente o inexistente. Nuestra meta fue dotar a estos negocios de una herramienta ágil, confiable y segura que no dependa de servidores remotos para su operativa diaria."*

### 2. Arquitectura de Software Limpia y Modular (01:30 min)
* **Qué decir:**
  > *"Para garantizar que la aplicación sea escalable, testeable y mantenible a lo largo del tiempo, implementamos una **Arquitectura en Capas desacopladas** basada en el patrón Provider / MVVM simplificado:*
  > 
  > *1. **Capa de Datos:** Encapsula la base de datos local SQLite y las interfaces de conexión (`DatabaseHelper`).*  
  > *2. **Capa de Dominio y Repositorio:** Define el contrato `IInventoryRepository`, aislando la lógica de negocio de los detalles de almacenamiento.*  
  > *3. **Capa de Estado Reactivo:** Implementada con `ChangeNotifier` de Provider (`InventoryProvider`), que propaga de manera atómica y en milisegundos cualquier cambio en los productos o movimientos a la interfaz.*  
  > *4. **Capa de Presentación:** Vistas y widgets modulares construidos en Flutter."*

### 3. Diseño Visual UI/UX en Material Design 3 (01:30 min)
* **Qué decir y Qué mostrar en pantalla:**
  * *Acción:* Mostrar el **Dashboard** en el emulador o en diapositiva (Figura 1 del informe).
  * *Discurso:*
  > *"En el apartado visual, seguimos las pautas de **Material Design 3**. Evitamos interfaces sobrecargadas o colores chillones que fatigan la vista tras horas de trabajo. Optamos por una paleta corporativa sobria: azul pizarra profundo (`Deep Indigo`) y verde esmeralda (`Emerald`), complementados con superficies semánticas claras.*
  >
  > *El usuario es recibido por un **Dashboard Ejecutivo** que calcula en vivo cuatro indicadores clave (KPIs): Total de productos únicos, Total de unidades físicas en almacén, Valor total estimado del inventario y Alerta inmediata de productos en nivel crítico.*
  >
  > *Asimismo, en la pestaña de **Catálogo**, el empleado dispone de una barra de búsqueda reactiva instantánea, filtros dinámicos por chips de categorías y un semáforo visual de stock con 4 estados: Verde para stock óptimo, Amarillo para moderado, Rojo para crítico y Gris para agotado."*

### 4. Transición hacia Persona 2 (00:30 min)
* **Qué decir:**
  > *"Toda esta experiencia interactiva carecería de valor si no contara con un motor de persistencia robusto y seguro que prevenga la pérdida de información. Para explicar la estructura de base de datos SQLite y las transacciones ACID, cedo la palabra a mi compañera Mariana Camila."*

---

```
========================================================================================
PERSONA 2: PERSISTENCIA LOCAL SQLITE, MODELO RELACIONAL Y TRANSACCIONES ACID
========================================================================================
```
* **Tiempo asignado:** 04:30 a 09:00 (4:30 min)
* **Objetivo:** Demostrar el dominio técnico en bases de datos relacionales locales, integridad referencial, transacciones atómicas y compatibilidad multiplataforma.

### 1. Diseño del Esquema Relacional DDL (01:15 min)
* **Qué decir y Qué mostrar en pantalla:**
  * *Acción:* Mostrar el diagrama relacional o esquema DDL (Fase 2 del informe).
  * *Discurso:*
  > *"Muchas gracias, Jezer. Profesor Elkin, entrando en el núcleo de persistencia de datos (Fase 2), la aplicación utiliza una base de datos relacional local motorizada por **SQLite** a través del paquete `sqflite`.*
  >
  > *Diseñamos un esquema compuesto por dos tablas fuertemente vinculadas:*
  > 
  > *1. **Tabla `productos`:** Almacena los atributos fundamentales del artículo: `id` autoincremental, `nombre`, `descripcion`, `categoria`, `cantidad` actual, `precio_unitario`, `stock_minimo`, `codigo_sku` y la `fecha_ingreso`.*
  > *2. **Tabla `movimientos`:** Actúa como el libro diario contable o 'kardex', guardando cada flujo de stock con `id_movimiento`, `id_producto`, `tipo` (restringido por CHECK a ENTRADA o SALIDA), `cantidad`, `motivo` y la marca de tiempo `fecha`."*

### 2. Integridad Referencial e Indexación (01:15 min)
* **Qué decir:**
  > *"En el desarrollo móvil con SQLite es un error común olvidar que las llaves foráneas vienen desactivadas por defecto. En nuestro `DatabaseHelper`, nos aseguramos de ejecutar al abrir la conexión:*
  > 
  > ```sql
  > PRAGMA foreign_keys = ON;
  > ```
  > 
  > *Definimos la llave foránea `id_producto` con la cláusula `ON DELETE CASCADE`. Esto significa que si un administrador decide eliminar un producto obsoleto, la base de datos elimina automáticamente su histórico de movimientos asociado, garantizando que nunca queden registros huérfanos.*
  > 
  > *Adicionalmente, creamos un índice sobre `idx_movimientos_producto`, lo que acelera drásticamente las consultas de auditoría cuando el catálogo crece a cientos o miles de movimientos."*

### 3. Transacciones ACID e Indivisibilidad de Operaciones (01:30 min)
* **Qué decir:**
  * *Acción:* Mostrar en diapositiva o mencionar el método `registerMovement` del código.
  * *Discurso:*
  > *"El requerimiento técnico más crítico del proyecto era garantizar la coherencia absoluta entre el stock registrado y el historial de movimientos. Si un usuario registra una salida de 10 unidades, no podemos permitir que se inserte el movimiento y que luego ocurra un fallo antes de descontar las unidades del producto.*
  >
  > *Para resolver esto, implementamos el principio de **Transaccionalidad ACID** mediante el método `db.transaction()`:*
  > 
  > *1. **Validación previa:** Verificamos que el producto exista y que, si es una salida, el stock actual sea suficiente (impidiendo stock negativo).*  
  > *2. **Inserción del movimiento:** Se registra en la tabla `movimientos`.*  
  > *3. **Actualización atómica:** Se ejecuta el `UPDATE` restando o sumando la cantidad exacta en la tabla `productos`.*  
  > 
  > *Si cualquier instrucción falla en el proceso, la transacción ejecuta un **Rollback automático**, dejando la base de datos exactamente en su estado previo consistente."*

### 4. Soporte Multiplataforma (Móvil y Web) y Transición a Persona 3 (00:30 min)
* **Qué decir:**
  > *"Por último, logramos que esta misma base de datos funcione no solo en Android, sino también en navegadores Web gracias a `sqflite_common_ffi_web`, abstrayendo la inicialización en el `main.dart`.*
  >
  > *Para exponer la pantalla de historial, la valorización financiera del inventario, la suite de pruebas unitarias automatizadas y la demostración en vivo, cedo la palabra a mi compañero Jesús David."*

---

```
========================================================================================
PERSONA 3: HISTORIAL ANALÍTICO, SUITE DE PRUEBAS UNITARIAS (QA), DEMO EN VIVO Y CIERRE
========================================================================================
```
* **Tiempo asignado:** 09:00 a 13:30 (4:30 min)
* **Objetivo:** Mostrar la trazabilidad contable, la metodología rigurosa de pruebas que valida el código, realizar la demostración operativa en vivo y cerrar la sustentación formal.

### 1. Historial de Movimientos, Trazabilidad y KPIs Financieros (01:15 min)
* **Qué decir y Qué mostrar en pantalla:**
  * *Acción:* Mostrar la pestaña de **Historial** en el emulador (Figura 8 del informe).
  * *Discurso:*
  > *"Muchas gracias, Mariana. Profesor Elkin, completando las Fases 3 y 4 de la guía, la aplicación provee un módulo de **Historial de Movimientos** que funciona como una bitácora de auditoría completa.*
  >
  > *Cada movimiento se visualiza con iconografía diferenciada: verde con flecha ascendente para 'Entrada' y naranja con flecha descendente para 'Salida'. El usuario puede filtrar por tipo de operación o rangos de fecha, y en la cabecera se proyecta el **Balance Neto**, permitiendo saber cuántas unidades ingresaron y salieron en el período.*
  >
  > *Además, en el modelo analítico `InventorySummaryModel`, calculamos la **Valorización Total del Inventario**, que es la suma del producto entre el precio unitario y la cantidad de cada artículo en existencia, brindando a la gerencia una cifra financiera real de su capital inmovilizado."*

### 2. Aseguramiento de la Calidad y Pruebas Unitarias Automatizadas (01:15 min)
* **Qué decir y Qué mostrar en pantalla:**
  * *Acción:* Mostrar la tabla de pruebas o la terminal con `flutter test` aprobado (Fase 5 del informe).
  * *Discurso:*
  > *"En la Fase 5 (Optimización y Pruebas), aplicamos ingeniería de calidad mediante pruebas automatizadas con el framework oficial de Flutter sobre una instancia SQLite en memoria con FFI.*
  >
  > *Desarrollamos una batería de **6 pruebas unitarias integrales** que validan:*
  > *1. Serialización y deserialización bidireccional de los modelos `ProductModel` y `MovementModel`.*  
  > *2. Operaciones CRUD completas de inserción y consulta en base de datos.*  
  > *3. Ejecución indivisible de transacciones ACID para entradas de inventario.*  
  > *4. Validación estricta y bloqueo de transacciones cuando una salida excede el stock.*  
  > *5. Integridad referencial y eliminación en cascada de movimientos vinculados.*  
  > *6. Cálculo exacto del resumen financiero y filtrado dinámico por categorías.*
  >
  > *El resultado fue contundente: **6 de 6 pruebas aprobadas con el 100% de éxito**, certificando que la lógica no presenta fugas de datos ni inconsistencias."*

### 3. Demostración Práctica en Vivo (01:30 min)
* **Qué hacer y decir:**
  * *Paso A:* Abrir la app (en emulador o web con `iniciar_servidor.bat`).
  * *Paso B:* *"Miren el Dashboard: actualmente tenemos X unidades y un valor de $Y."*
  * *Paso C:* Ir al catálogo y registrar un movimiento: *"Vamos a registrar una Entrada de 20 unidades del producto 'Arroz Diana' por motivo de 'Compra a proveedor'."*
  * *Paso D:* Mostrar cómo el badge cambia de estado inmediatamente y cómo el Dashboard recalcula el total de unidades y la valorización financiera al instante sin recargar la pantalla.
  * *Paso E:* Ir al Historial y mostrar el nuevo registro en la bitácora con su fecha, hora y motivo.

### 4. Conclusiones y Cierre Académico (00:30 min)
* **Qué decir:**
  > *"Como conclusión, esta experiencia nos permitió fusionar los fundamentos teóricos de la asignatura con un producto de software real y profesional:*
  > 
  > *1. Comprobamos la viabilidad y velocidad de las bases de datos relacionales locales para aplicaciones que no pueden depender de internet.*  
  > *2. Comprobamos la eficacia de los patrones de gestión de estado reactivo para ofrecer interfaces fluidas a 60 fps.*  
  > *3. El proyecto se encuentra debidamente documentado bajo normas APA 7ª edición y versionado en GitHub con integración multiplataforma.*
  >
  > *Agradecemos su atención y quedamos a su entera disposición para cualquier pregunta o retroalimentación."*

---

## 💡 PREGUNTAS TÍPICAS DEL EVALUADOR Y RESPUESTAS PREPARADAS

| Posible Pregunta del Docente Tutor | Quién Responde | Argumento Técnico Recomendado |
| :--- | :--- | :--- |
| **"¿Por qué decidieron usar SQLite en lugar de SharedPreferences o Hive?"** | **Persona 2** | *"SharedPreferences está concebido para guardar datos primitivos simples de configuración (llave-valor) y no soporta consultas complejas. Aunque Hive es rápido, carece de un motor relacional formal. SQLite nos garantiza integridad referencial con claves foráneas, soporte de sentencias SQL relacionales y transacciones ACID nativas para evitar pérdidas contables."* |
| **"¿Qué ocurre si el usuario apaga el teléfono o se cierra la app mientras se registra un movimiento?"** | **Persona 2** | *"Gracias a la transacción atómica `db.transaction()`, SQLite utiliza un diario de reversión (rollback journal / WAL). Si la app se cierra antes del commit, la base de datos se restaura a su estado original, asegurando que ni el stock ni los movimientos queden a medio camino."* |
| **"¿Cómo manejan la reactividad en la interfaz para que el Dashboard se actualice sin recargar la pantalla?"** | **Persona 1** | *"Utilizamos el patrón Provider mediante la clase `InventoryProvider` que extiende `ChangeNotifier`. Cuando una operación en el repositorio finaliza, se llama a `notifyListeners()`. Los widgets envueltos en `Consumer<InventoryProvider>` escuchan ese evento y se reconstruyen de forma selectiva y eficiente."* |
| **"¿Cómo comprobaron que no hay errores en el cálculo financiero o en salidas inválidas?"** | **Persona 3** | *"A través de nuestra suite automatizada de pruebas unitarias en `test/models_and_transactions_test.dart`. Levantamos una base de datos en memoria y sometimos las funciones a pruebas de estrés, como intentar retirar más stock del existente y verificar que lance la excepción esperada y no altere la base."* |

---

## ⏱️ RECOMENDACIONES DE ORATORIA Y LOGÍSTICA PARA EL CIPA

1. **Reparto de mandos:** Mientras un integrante expone, otro del equipo puede encargarse de manipular la app en el emulador o presentar las diapositivas para que el expositor mantenga el contacto visual con el docente.
2. **Uso de nombres técnicos:** Usar siempre los términos de la materia: *"persistencia relacional"*, *"transacción ACID"*, *"integridad referencial"*, *"patrón provider"*, *"gestión de estado"*, *"pruebas unitarias automatizadas"*.
3. **Puntualidad en los tiempos:** Practicar previamente con cronómetro en mano para asegurar que cada expositor utilice exactamente entre 4 y 4:30 minutos, completando los 13 a 14 minutos en total.
