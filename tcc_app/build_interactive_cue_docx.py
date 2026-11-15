import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:val="clear" w:color="auto" w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_table_styling(table, top=90, bottom=90, left=120, right=120):
    tblPr = table._tbl.tblPr
    tblLook = tblPr.find(qn('w:tblLook'))
    if tblLook is not None:
        tblPr.remove(tblLook)

    borders = parse_xml(f'''
        <w:tblBorders {nsdecls("w")}>
            <w:top w:val="single" w:sz="4" w:space="0" w:color="CBD5E1"/>
            <w:left w:val="none"/>
            <w:bottom w:val="single" w:sz="6" w:space="0" w:color="94A3B8"/>
            <w:right w:val="none"/>
            <w:insideH w:val="single" w:sz="4" w:space="0" w:color="E2E8F0"/>
            <w:insideV w:val="none"/>
        </w:tblBorders>
    ''')
    tblPr.append(borders)

    tblCellMar = parse_xml(f'''
        <w:tblCellMar {nsdecls("w")}>
            <w:top w:w="{top}" w:type="dxa"/>
            <w:left w:w="{left}" w:type="dxa"/>
            <w:bottom w:w="{bottom}" w:type="dxa"/>
            <w:right w:w="{right}" w:type="dxa"/>
        </w:tblCellMar>
    ''')
    tblPr.append(tblCellMar)

    if tblLook is not None:
        tblPr.append(tblLook)

def create_interactive_guide_docx():
    doc = Document()

    # Page Margins 1 inch
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)

        # Header
        hp = section.header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun = hp.add_run("Guía Audiovisual Minuto a Minuto · Demostración en Pantalla TCC")
        hrun.font.name = "Times New Roman"
        hrun.font.size = Pt(9)
        hrun.font.color.rgb = RGBColor(100, 116, 139)

    # Style
    normal = doc.styles['Normal']
    normal.font.name = 'Times New Roman'
    normal.font.size = Pt(11)
    normal.paragraph_format.line_spacing = 1.25
    normal.paragraph_format.space_after = Pt(5)

    # =========================================================================
    # PORTADA Y ENCABEZADO
    # =========================================================================
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run("UNIVERSIDAD DE CARTAGENA · FACULTAD DE INGENIERÍA\nPROGRAMA DE INGENIERÍA DE SOFTWARE — V SEMESTRE")
    r.bold = True
    r.font.size = Pt(11)
    r.font.color.rgb = RGBColor(71, 85, 105)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(8)
    r = p.add_run("GUÍA DE RODAJE Y PAUTA AUDIOVISUAL MINUTO A MINUTO\nQUÉ MOSTRAR EN PANTALLA: CÓDIGO, TERMINAL Y DEMOSTRACIÓN EN VIVO")
    r.bold = True
    r.font.size = Pt(14)
    r.font.color.rgb = RGBColor(15, 23, 42)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(18)
    r = p.add_run("Manual Director para Sustentación Dinámica de la App «Inventario» (9 Minutos Totales · 3 Minutos por Expositor)\nAsignatura: Desarrollo de Aplicaciones Móviles · Docente Tutor: Elkin José Navarro Osorio\nCIPA: Jezer Martínez Pérez · Mariana Camila Olmos Pérez · Jesús David Guerrero Rada")
    r.italic = True
    r.font.size = Pt(10)
    r.font.color.rgb = RGBColor(100, 116, 139)

    # Introductory notice
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(10)
    r = p.add_run("Objetivo del Documento: ")
    r.bold = True
    p.add_run("Esta guía elimina la monotonía de una presentación estática. Indica segundo a segundo qué ventana tener abierta, qué archivo de código fuente resaltar en el editor (VS Code o Android Studio), qué funciones y líneas enfocar con el cursor, qué botones pulsar en la aplicación en vivo y qué comandos ejecutar en la terminal para cautivar la atención del docente evaluador con una defensa 100% técnica e interactiva.")

    # =========================================================================
    # TABLA RESUMEN GENERAL DE RECURSOS EN PANTALLA
    # =========================================================================
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run("Resumen de Recursos de Pantalla Necesarios Durante la Grabación:")
    r.bold = True
    r.font.size = Pt(11.5)

    t_res = doc.add_table(rows=5, cols=3)
    t_res.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_styling(t_res)

    res_headers = ["Ventana / Programa", "Ruta / Archivo Específico a Cargar", "Propósito en la Exposición"]
    res_w = [Inches(1.8), Inches(2.6), Inches(2.1)]
    for j, h in enumerate(res_headers):
        cell = t_res.rows[0].cells[j]
        cell.width = res_w[j]
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(255, 255, 255)
        set_cell_background(cell, "0F172A")

    res_rows = [
        ("Editor de Código\n(VS Code / Android Studio)", "• lib/models/product_model.dart\n• lib/core/database/database_helper.dart\n• lib/repositories/inventory_repository.dart\n• lib/providers/inventory_provider.dart\n• test/models_and_transactions_test.dart\n• lib/main.dart", "Mostrar la arquitectura limpia, las transacciones ACID con db.transaction(), llaves foráneas y modelos tipificados."),
        ("App en Ejecución\n(Emulador o Chrome Web)", "Lanzada con 'iniciar_servidor.bat' (opción 1 Web) o en emulador Android sdk gphone16k (API 37)", "Demostrar en vivo los KPIs del Dashboard, buscador reactivo, semáforo de stock, modal de entrada con pre-cálculo y alerta de stock negativo."),
        ("Terminal / Consola\n(PowerShell / Bash)", "Ubicada en la raíz del proyecto: C:\\Users\\user\\Downloads\\tcc_app", "Ejecutar en vivo: 'flutter test test/models_and_transactions_test.dart' (6/6 pass) y 'flutter analyze' (0 issues)."),
        ("Navegador Web\n(GitHub & Repositorio)", "URL: https://github.com/Jezeriom/tcc_app_fifth.git", "Mostrar el README.md profesional con badges, arquitectura, diagramas y la estructura del repositorio.")
    ]

    for i, row_data in enumerate(res_rows):
        row = t_res.rows[i+1]
        for j, text in enumerate(row_data):
            cell = row.cells[j]
            cell.width = res_w[j]
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(9)
            if j == 0:
                r.bold = True
            set_cell_background(cell, "F8FAFC" if i % 2 == 0 else "FFFFFF")

    doc.add_page_break()

    # =========================================================================
    # GUÍA MINUTO A MINUTO (BLOQUE POR BLOQUE)
    # =========================================================================
    
    minutes_data = [
        # ---------------------------------------------------------------------
        # PERSONA 1: JEZER MARTÍNEZ (00:00 - 03:00)
        # ---------------------------------------------------------------------
        {
            "minute_title": "MINUTO 1 (00:00 - 01:00) · APERTURA Y PROBLEMÁTICA DE NEGOCIO",
            "speaker": "PERSONA 1: JEZER MARTÍNEZ PÉREZ",
            "time_range": "00:00 a 01:00 (60 segundos)",
            "on_screen": "Cámara Web en Primer Plano (00:00 - 00:25)  →  Conmutar a la App Móvil en Ejecución (00:25 - 00:50)  →  Editor VS Code mostrando pubspec.yaml (00:50 - 01:00)",
            "screen_actions": [
                "00:00 - 00:25: Jezer en cámara principal. Contacto visual directo. Saludo protocolario al profesor Elkin José Navarro Osorio y presentación del CIPA.",
                "00:25 - 00:50: Conmutar a la pantalla de la App en el móvil o navegador. Mostrar el Dashboard: deslizar suavemente para mostrar que la app responde con total fluidez sin internet. Explicar el problema de los tenderos y bodegueros con internet inestable.",
                "00:50 - 01:00: Cambiar a VS Code. Abrir 'pubspec.yaml'. Resaltar con el cursor las líneas de dependencias: sqflite, provider, intl, path y flutter_launcher_icons."
            ],
            "dialogue_cues": "«Muy buenos días profesor Elkin Navarro y compañeros. Mi nombre es Jezer Martínez y junto a Mariana Olmos y Jesús Guerrero presentamos nuestra solución: Inventario Offline-First. Observen la app en pantalla: no requiere wifi ni datos móviles. En pubspec.yaml pueden ver las tecnologías clave: sqflite para el motor relacional y provider para el estado reactivo.»"
        },
        {
            "minute_title": "MINUTO 2 (01:00 - 02:00) · MODELOS DE DATOS Y CAPA REACTIVA",
            "speaker": "PERSONA 1: JEZER MARTÍNEZ PÉREZ",
            "time_range": "01:00 a 02:00 (60 segundos)",
            "on_screen": "Editor VS Code: lib/models/product_model.dart  →  lib/models/movement_model.dart  →  App Móvil: Catálogo con Buscador",
            "screen_actions": [
                "01:00 - 01:25: En VS Code, abrir 'lib/models/product_model.dart'. Seleccionar con el mouse los atributos inmutables (id, nombre, categoria, cantidad, precio, stockMinimo, codigoSku) y el método 'toMap()' y 'fromMap()'.",
                "01:25 - 01:45: Abrir 'lib/models/movement_model.dart'. Mostrar el enum 'MovementType { ENTRADA, SALIDA }' y la validación de fecha.",
                "01:45 - 02:00: Conmutar a la App. Ir a la pestaña 'Inventario'. Teclear en el buscador 'Arroz' o 'Aceite': mostrar cómo la lista se filtra instantáneamente gracias al debounce reactivo."
            ],
            "dialogue_cues": "«Diseñamos modelos fuertemente tipificados e inmutables. En ProductModel cada atributo está blindado y se serializa bidireccionalmente entre objetos Dart y mapas SQLite. Y en la interfaz, como ven, la búsqueda filtra las referencias en milisegundos sin latencia.»"
        },
        {
            "minute_title": "MINUTO 3 (02:00 - 03:00) · DATABASEHELPER SINGLETON Y CIERRE BLOQUE 1",
            "speaker": "PERSONA 1: JEZER MARTÍNEZ PÉREZ",
            "time_range": "02:00 a 03:00 (60 segundos)",
            "on_screen": "Editor VS Code: lib/core/database/database_helper.dart  →  Retorno a Cámara Web",
            "screen_actions": [
                "02:00 - 02:25: En VS Code, abrir 'lib/core/database/database_helper.dart'. Resaltar la línea del constructor privado 'DatabaseHelper._();' (patrón Singleton).",
                "02:25 - 02:45: Bajar en el código a la función '_onCreate' y '_onConfigure'. Resaltar explícitamente: 'PRAGMA foreign_keys = ON;' y la cláusula 'ON DELETE CASCADE' de la tabla movimientos.",
                "02:45 - 03:00: Retornar a la cámara de Jezer. Pase de palabra visual y cordial a Mariana Camila Olmos."
            ],
            "dialogue_cues": "«Para evitar aperturas múltiples de la base de datos, DatabaseHelper opera como Singleton. Activamos estrictamente PRAGMA foreign_keys = ON y borrado en cascada para no dejar datos huérfanos. Doy paso a mi compañera Mariana Camila para detallar la arquitectura y las transacciones ACID.»"
        },

        # ---------------------------------------------------------------------
        # PERSONA 2: MARIANA CAMILA OLMOS (03:00 - 06:00)
        # ---------------------------------------------------------------------
        {
            "minute_title": "MINUTO 4 (03:00 - 04:00) · ARQUITECTURA EN 5 CAPAS Y REPOSITORIO",
            "speaker": "PERSONA 2: MARIANA CAMILA OLMOS PÉREZ",
            "time_range": "03:00 a 04:00 (60 segundos)",
            "on_screen": "Cámara de Mariana (03:00 - 03:15)  →  Editor VS Code: Árbol de Carpetas + lib/repositories/i_inventory_repository.dart + lib/providers/inventory_provider.dart",
            "screen_actions": [
                "03:00 - 03:15: Mariana en cámara. Saludo cordial al profesor Elkin Navarro. Presentación de su eje temático.",
                "03:15 - 03:40: Mostrar en VS Code el árbol de carpetas de 'lib/': señalar cómo están separadas las 5 capas: views, providers, repositories, core/database y models. Abrir 'lib/repositories/i_inventory_repository.dart' mostrando la interfaz limpia.",
                "03:40 - 04:00: Abrir 'lib/providers/inventory_provider.dart'. Señalar la línea 'class InventoryProvider extends ChangeNotifier' y el método 'notifyListeners();', explicando cómo la vista escucha cambios sin conocer SQL."
            ],
            "dialogue_cues": "«Muchas gracias, Jezer. Profesor Elkin, nuestra arquitectura separa responsabilidades en cinco capas independientes. Usamos el contrato IInventoryRepository para desacoplar la interfaz del motor de persistencia, e InventoryProvider para emitir notificaciones reactivas a 60 fps.»"
        },
        {
            "minute_title": "MINUTO 5 (04:00 - 05:00) · TRANSACCIONES ACID INDIVISIBLES EN CÓDIGO",
            "speaker": "PERSONA 2: MARIANA CAMILA OLMOS PÉREZ",
            "time_range": "04:00 a 05:00 (60 segundos)",
            "on_screen": "Editor VS Code: lib/core/database/database_helper.dart (Método registerMovement)",
            "screen_actions": [
                "04:00 - 04:20: Abrir 'lib/core/database/database_helper.dart' y situarse en 'Future<void> registerMovement(...)'.",
                "04:20 - 04:40: Resaltar con el cursor la línea 'await db.transaction((txn) async { ... })'. Explicar que agrupa el INSERT de movimientos y el UPDATE de productos en una única unidad atómica.",
                "04:40 - 05:00: Resaltar las líneas de validación: 'if (movement.tipo == MovementType.salida && product.cantidad < movement.cantidad) throw Exception(...);'. Explicar que si falta saldo, SQLite ejecuta un Rollback automático inmediato."
            ],
            "dialogue_cues": "«Aquí reside el corazón de la integridad del negocio: el método registerMovement opera bajo una transacción ACID indivisible. Si un empleado registra una salida que supera el stock físico, la transacción dispara una excepción y SQLite revierte todo con un rollback automático, garantizando cero descuadres contables.»"
        },
        {
            "minute_title": "MINUTO 6 (05:00 - 06:00) · RECORRIDO INTERACTIVO EN LA APP (DEMO UX/UI)",
            "speaker": "PERSONA 2: MARIANA CAMILA OLMOS PÉREZ",
            "time_range": "05:00 a 06:00 (60 segundos)",
            "on_screen": "App Móvil en Primer Plano (Catálogo → Detalle con Hero → Modal de Entrada → Historial)",
            "screen_actions": [
                "05:00 - 05:15: En la App, mostrar el Catálogo. Tocar el chip de categoría 'Lácteos' y luego el chip 'Stock Bajo': señalar cómo el semáforo rojo resalta los productos en peligro de agotarse.",
                "05:15 - 05:30: Tocar una tarjeta de producto: destacar la animación Hero que viaja suavemente hacia la pantalla de Detalle, mostrando el SKU único y el badge de estado.",
                "05:30 - 05:45: Pulsar el botón 'Registrar Entrada'. Digitar cantidad '20' y motivo 'Compra a distribuidor'. Señalar en vivo el texto verde que dice 'Nuevo stock estimado: 45 unidades'. Pulsar 'Guardar' y mostrar el SnackBar verde de éxito.",
                "05:45 - 06:00: Conmutar a la cámara de Mariana. Sonrisa y pase de palabra a Jesús David Guerrero."
            ],
            "dialogue_cues": "«En la interfaz, observen la fluidez de Material 3: chips dinámicos, semaforización de stock y transiciones Hero. En el modal de movimiento, la app calcula el saldo futuro en vivo antes de guardar. Cedo la palabra a Jesús David para mostrar las pruebas unitarias y la validación en emulador.»"
        },

        # ---------------------------------------------------------------------
        # PERSONA 3: JESÚS DAVID GUERRERO (06:00 - 09:00)
        # ---------------------------------------------------------------------
        {
            "minute_title": "MINUTO 7 (06:00 - 07:00) · BATERÍA DE PRUEBAS UNITARIAS 6/6 EN TERMINAL",
            "speaker": "PERSONA 3: JESÚS DAVID GUERRERO RADA",
            "time_range": "06:00 a 07:00 (60 segundos)",
            "on_screen": "Cámara de Jesús (06:00 - 06:15)  →  Editor VS Code: test/models_and_transactions_test.dart  →  Terminal Ejecutando 'flutter test'",
            "screen_actions": [
                "06:00 - 06:15: Jesús en cámara. Saludo protocolario al profesor Elkin Navarro. Planteamiento de la estrategia de aseguramiento de calidad (QA).",
                "06:15 - 06:35: En VS Code, abrir 'test/models_and_transactions_test.dart'. Mostrar que utiliza 'sqflite_common_ffi' para levantar SQLite real en memoria RAM, cubriendo 6 tests (modelos, CRUD, transacciones ACID, bloqueo de salidas excesivas, borrado en cascada y resumen financiero).",
                "06:35 - 07:00: Abrir la terminal y teclear en vivo: 'flutter test test/models_and_transactions_test.dart'. Dejar que la terminal imprima en verde: '00:01 +6: All tests passed!'. Resaltar el 100% de éxito."
            ],
            "dialogue_cues": "«Muchas gracias, Mariana. Profesor Elkin, para garantizar que la app sea infalible construimos una suite automatizada de pruebas unitarias sobre SQLite en memoria. Ejecutamos el comando flutter test en vivo... y como pueden apreciar en la terminal: 6 de 6 pruebas aprobadas con cero fallos, certificando modelos, transacciones y cascadas.»"
        },
        {
            "minute_title": "MINUTO 8 (07:00 - 08:00) · VALIDACIÓN EN ANDROID 17 Y RESOLUCIÓN DE BUGS QA",
            "speaker": "PERSONA 3: JESÚS DAVID GUERRERO RADA",
            "time_range": "07:00 a 08:00 (60 segundos)",
            "on_screen": "Emulador Android API 37 + VS Code en Pantalla Dividida (lib/main.dart y product_card.dart)",
            "screen_actions": [
                "07:00 - 07:20: Mostrar la app corriendo en el emulador oficial Android 17 (API 37). Mostrar la barra superior del emulador con la resolución de 1344 x 2992 px y fluidez a 60 fps.",
                "07:20 - 07:40: En VS Code, abrir 'lib/main.dart' y resaltar la línea 'await initializeDateFormatting('es', null);'. Explicar cómo resolvió el bug 'LocaleDataException' en el formateo de fechas del historial.",
                "07:40 - 08:00: Abrir 'lib/views/inventory/widgets/product_card.dart' y resaltar 'SizedBox(height: 14);'. Explicar cómo sustituyó el widget 'Spacer' que causaba el layout crash de caja infinita. Ejecutar 'flutter analyze' en la terminal mostrando 'No issues found!'."
            ],
            "dialogue_cues": "«Validamos la app en un emulador Android con API 37. Durante el proceso de QA corregimos dos incidencias críticas: precargamos la localización regional en español para evitar el LocaleDataException, y reemplazamos un Spacer por un SizedBox en ProductCard para erradicar un error de layout. Flutter analyze reporta cero advertencias.»"
        },
        {
            "minute_title": "MINUTO 9 (08:00 - 09:00) · GITHUB, ARTEFACTOS APA Y DESPEDIDA EN EQUIPO",
            "speaker": "PERSONA 3: JESÚS DAVID GUERRERO RADA + EQUIPO CIPA",
            "time_range": "08:00 a 09:00 (60 segundos)",
            "on_screen": "Navegador Web en Repositorio GitHub  →  Documento Word APA en Pantalla  →  Cámara Conjunta de los 3 Integrantes",
            "screen_actions": [
                "08:00 - 08:25: Mostrar en Chrome el repositorio oficial: https://github.com/Jezeriom/tcc_app_fifth.git. Hacer scroll por el README.md mostrando los diagramas de arquitectura, comandos CLI y la carpeta 'tcc_app/'.",
                "08:25 - 08:45: Mostrar brevemente el informe Word oficial 'Informe_Final_Actividad_TCC.docx' con su portada formal APA y su índice con puntos guía.",
                "08:45 - 09:00: Conmutar a la cámara con los tres integrantes (Jezer, Mariana y Jesús). Agradecimiento sincero al docente Elkin José Navarro Osorio y despedida final con entusiasmo."
            ],
            "dialogue_cues": "«Como artefactos entregamos el repositorio GitHub público tcc_app_fifth completamente versionado, y el informe final en formato Word bajo estrictas normas APA 7ª edición. Agradecemos profundamente al docente Elkin José Navarro Osorio por su guía durante este quinto semestre. ¡Quedamos atentos a sus preguntas y muchas gracias!»"
        }
    ]

    for item in minutes_data:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(item["minute_title"])
        r.bold = True
        r.font.size = Pt(12)
        r.font.color.rgb = RGBColor(16, 185, 129)

        # Meta Table for each minute
        t_min = doc.add_table(rows=3, cols=2)
        t_min.alignment = WD_TABLE_ALIGNMENT.CENTER
        set_table_styling(t_min, top=50, bottom=50, left=80, right=80)
        t_min.rows[0].cells[0].width = Inches(1.8)
        t_min.rows[0].cells[1].width = Inches(4.7)
        t_min.rows[1].cells[0].width = Inches(1.8)
        t_min.rows[1].cells[1].width = Inches(4.7)
        t_min.rows[2].cells[0].width = Inches(1.8)
        t_min.rows[2].cells[1].width = Inches(4.7)

        # Row 0: Speaker & Time
        c0 = t_min.rows[0].cells[0]
        c1 = t_min.rows[0].cells[1]
        c0.paragraphs[0].add_run("Expositor y Tiempo:").bold = True
        c0.paragraphs[0].runs[0].font.size = Pt(9.5)
        c1.paragraphs[0].add_run(f'{item["speaker"]}  |  {item["time_range"]}')
        c1.paragraphs[0].runs[0].font.size = Pt(9.5)
        c1.paragraphs[0].runs[0].bold = True
        set_cell_background(c0, "F1F5F9")
        set_cell_background(c1, "F8FAFC")

        # Row 1: What to display
        c0 = t_min.rows[1].cells[0]
        c1 = t_min.rows[1].cells[1]
        c0.paragraphs[0].add_run("Pantallas / Ventanas:").bold = True
        c0.paragraphs[0].runs[0].font.size = Pt(9.5)
        c1.paragraphs[0].add_run(item["on_screen"])
        c1.paragraphs[0].runs[0].font.size = Pt(9)
        c1.paragraphs[0].runs[0].font.color.rgb = RGBColor(15, 23, 42)
        set_cell_background(c0, "F1F5F9")
        set_cell_background(c1, "FFFFFF")

        # Row 2: Speech cue
        c0 = t_min.rows[2].cells[0]
        c1 = t_min.rows[2].cells[1]
        c0.paragraphs[0].add_run("Pauta de Discurso:").bold = True
        c0.paragraphs[0].runs[0].font.size = Pt(9.5)
        c1.paragraphs[0].add_run(item["dialogue_cues"])
        c1.paragraphs[0].runs[0].font.size = Pt(9)
        c1.paragraphs[0].runs[0].italic = True
        set_cell_background(c0, "F1F5F9")
        set_cell_background(c1, "F8FAFC")

        # Detailed step bullets
        p_act = doc.add_paragraph()
        p_act.paragraph_format.space_before = Pt(6)
        p_act.paragraph_format.space_after = Pt(2)
        r_act = p_act.add_run("Acciones Específicas de Navegación e Interacción en Pantalla:")
        r_act.bold = True
        r_act.font.size = Pt(10)
        r_act.font.color.rgb = RGBColor(30, 41, 59)

        for act in item["screen_actions"]:
            p_bullet = doc.add_paragraph()
            p_bullet.paragraph_format.left_indent = Inches(0.2)
            p_bullet.paragraph_format.space_after = Pt(3)
            r_b = p_bullet.add_run(f"• {act}")
            r_b.font.size = Pt(9.5)

    # Concluding signature
    doc.add_paragraph().paragraph_format.space_after = Pt(14)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p.paragraph_format.space_before = Pt(16)
    r = p.add_run("Documento Director elaborado para la grabación de video y sustentación del CIPA\nAsignatura Desarrollo de Apps · Tutor: Elkin José Navarro Osorio\nFacultad de Ingeniería · Universidad de Cartagena")
    r.italic = True
    r.font.size = Pt(9)
    r.font.color.rgb = RGBColor(148, 163, 184)

    output_path = r"C:\Users\user\Downloads\tcc_app\docs\Guia_Grabacion_Minuto_a_Minuto_Video.docx"
    doc.save(output_path)
    print(f"Guía interactiva creada exitosamente en: {output_path}")

if __name__ == "__main__":
    create_interactive_guide_docx()
