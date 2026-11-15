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

def set_table_styling(table, top=100, bottom=100, left=140, right=140):
    tblPr = table._tbl.tblPr
    # Ensure tblLook is removed and re-appended at the very end to satisfy OpenXML schema sequence
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

def create_cue_document():
    doc = Document()
    
    # Page setup - Letter, 1 inch margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        
        # Header
        header = section.header
        hp = header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun = hp.add_run("Cronograma Audiovisual y Pautas de Demostración · TCC Apps")
        hrun.font.name = "Times New Roman"
        hrun.font.size = Pt(9)
        hrun.font.color.rgb = RGBColor(100, 116, 139)

    # Style definitions
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Times New Roman'
    normal_style.font.size = Pt(11)
    normal_style.paragraph_format.line_spacing = 1.3
    normal_style.paragraph_format.space_after = Pt(6)

    # =========================================================================
    # PORTADA INSTITUCIONAL
    # =========================================================================
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(18)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run("UNIVERSIDAD DE CARTAGENA\nFACULTAD DE INGENIERÍA")
    r.bold = True
    r.font.size = Pt(13)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(24)
    r = p.add_run("PROGRAMA DE INGENIERÍA DE SOFTWARE — V SEMESTRE")
    r.bold = True
    r.font.size = Pt(11)
    r.font.color.rgb = RGBColor(71, 85, 105)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(12)
    r = p.add_run("GUÍA TÉCNICA Y CRONOGRAMA AUDIOVISUAL DE DEFENSA\n«SISTEMA DE GESTIÓN DE INVENTARIOS OFFLINE»")
    r.bold = True
    r.font.size = Pt(15)
    r.font.color.rgb = RGBColor(15, 23, 42)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(28)
    r = p.add_run("Planificación Segundo a Segundo de Transición de Diapositivas, Demostración en Vivo de la App y Pautas de Oratoria para Video o Sustentación Presencial")
    r.italic = True
    r.font.size = Pt(11)
    r.font.color.rgb = RGBColor(100, 116, 139)

    # Metadata Table
    table_meta = doc.add_table(rows=5, cols=2)
    table_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_styling(table_meta, top=80, bottom=80, left=120, right=120)

    meta_data = [
        ("Asignatura:", "Desarrollo de Aplicaciones Móviles"),
        ("Docente Tutor:", "Elkin José Navarro Osorio"),
        ("Equipo CIPA:", "Jezer Martínez Pérez · Mariana Camila Olmos Pérez · Jesús David Guerrero Rada"),
        ("Duración Total:", "9 Minutos Exactos (3:00 min equitativos por expositor)"),
        ("Repositorio Oficial:", "https://github.com/Jezeriom/tcc_app_fifth.git (Rama main)")
    ]

    for i, (k, v) in enumerate(meta_data):
        row = table_meta.rows[i]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = Inches(2.2)
        c1.width = Inches(4.3)
        
        p0 = c0.paragraphs[0]
        p0.paragraph_format.space_after = Pt(2)
        r0 = p0.add_run(k)
        r0.bold = True
        r0.font.size = Pt(10.5)
        
        p1 = c1.paragraphs[0]
        p1.paragraph_format.space_after = Pt(2)
        r1 = p1.add_run(v)
        r1.font.size = Pt(10.5)

        set_cell_background(c0, "F1F5F9")
        set_cell_background(c1, "FFFFFF")

    doc.add_page_break()

    # =========================================================================
    # SECCIÓN 1: DISTRIBUCIÓN EQUITATIVA Y ESTRUCTURA GLOBAL
    # =========================================================================
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("1. Estructura y Distribución Equitativa de la Sustentación")
    r.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = RGBColor(15, 23, 42)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(10)
    p.add_run("Para garantizar una participación 100% equilibrada tanto en tiempo en pantalla como en densidad conceptual y técnica, la sustentación se divide en tres bloques secuenciales de exactamente tres (3) minutos por expositor. Esta estructura responde con precisión a los 9 minutos estipulados en la guía oficial del proyecto:")

    # Table of Distribution
    tbl_dist = doc.add_table(rows=4, cols=4)
    tbl_dist.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_styling(tbl_dist, top=80, bottom=80, left=100, right=100)
    headers = ["Expositor / CIPA", "Intervalo", "Bloque Temático y Responsabilidad", "Soporte Visual Principal"]
    col_widths = [Inches(1.8), Inches(1.1), Inches(2.3), Inches(1.8)]

    for j, h in enumerate(headers):
        cell = tbl_dist.rows[0].cells[j]
        cell.width = col_widths[j]
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(255, 255, 255)
        set_cell_background(cell, "0F172A")

    dist_rows = [
        ("Persona 1:\nJezer Martínez Pérez", "00:00 - 03:00\n(3:00 min)", "Fundamentación de Negocio, Objetivos, Stack Tecnológico Flutter y Capa Base Reactiva.", "Diapositivas 1, 2 y 3\n(Portada, Objetivos, Stack)"),
        ("Persona 2:\nMariana Camila Olmos Pérez", "03:00 - 06:00\n(3:00 min)", "Arquitectura en 5 Capas, Modelo Relacional SQLite DDL, Reglas de Integridad y Recorrido UI.", "Diapositivas 4 y 5\nCapturas Figuras 1, 2, 3, 4, 5, 7"),
        ("Persona 3:\nJesús David Guerrero Rada", "06:00 - 09:00\n(3:00 min)", "Batería de Pruebas Unitarias 6/6, Validación Android API 37, Incidencias QA, Conclusiones y Cierre.", "Diapositivas 6, 7 y 8\nFiguras 6, 8, 9 y Terminal Tests")
    ]

    for i, row_data in enumerate(dist_rows):
        row = tbl_dist.rows[i+1]
        for j, text in enumerate(row_data):
            cell = row.cells[j]
            cell.width = col_widths[j]
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(9.5)
            if j == 1:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                r.bold = True
            set_cell_background(cell, "F8FAFC" if i % 2 == 0 else "FFFFFF")

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # =========================================================================
    # SECCIÓN 2: CRONOGRAMA AUDIOVISUAL SEGUNDO A SEGUNDO
    # =========================================================================
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("2. Cronograma Maestro Segundo a Segundo: Transiciones y Pautas en Pantalla")
    r.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = RGBColor(15, 23, 42)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(10)
    p.add_run("La siguiente tabla detalla con exactitud matemática el momento en que se debe cambiar de diapositiva, cuándo conmutar a la aplicación móvil en vivo o emulador, y las pautas que el expositor debe verbalizar:")

    cue_data = [
        ("00:00 - 00:45", "Jezer Martínez", "Diapositiva 1:\nPortada Institucional", "CÁMARA + DIAPOSITIVA:\nExpositor en plano medio o recuadro superior derecho. Diapositiva 1 en el centro.", "Saludo formal al docente Elkin Navarro. Presentación del CIPA y justificación de la necesidad offline-first para pequeños comercios locales."),
        ("00:45 - 01:35", "Jezer Martínez", "Diapositiva 2:\n6 Objetivos Clave", "TRANSICIÓN DIAPOSITIVA 2:\nPantalla compartida completa. Resaltar viñetas de los objetivos conforme se mencionan.", "Explicar los 6 objetivos: CRUD productos, motor analítico local, módulo estricto de movimientos, trazabilidad, arquitectura limpia y suite de tests."),
        ("01:35 - 02:40", "Jezer Martínez", "Diapositiva 3:\nFases 1 a 3 (Stack)", "TRANSICIÓN DIAPOSITIVA 3:\nMostrar diagrama de modelos y logos de Flutter, sqflite y Provider.", "Detallar la selección de Flutter, sqflite, path e intl. Explicar los modelos inmutables, el patrón Singleton en DatabaseHelper y el estado con ChangeNotifier."),
        ("02:40 - 03:00", "Jezer Martínez", "Diapositiva 3 → Cámara", "RETORNO A CÁMARA:\nPlano medio de Jezer. Pase visual y verbal fluido a Mariana Camila Olmos.", "Cierre del bloque de fundamentación y pase protocolario a Mariana para el detalle de arquitectura y base de datos."),
        ("03:00 - 03:50", "Mariana Olmos", "Diapositiva 4:\nArquitectura 5 Capas", "TRANSICIÓN DIAPOSITIVA 4:\nDiagrama de Clean Architecture simplificada y tabla de responsabilidades.", "Saludo cordial al tutor. Explicación del flujo desacoplado: Vistas -> Provider -> Repositorio -> DatabaseHelper -> Modelos. Aislamiento total de la UI."),
        ("03:50 - 04:45", "Mariana Olmos", "Diapositiva 5:\nModelo Relacional DDL", "TRANSICIÓN DIAPOSITIVA 5:\nDiagrama E-R y fragmento de código DDL (CREATE TABLE e índices).", "Presentar las tablas 'productos' y 'movimientos', PRAGMA foreign_keys = ON, ON DELETE CASCADE, CHECK en cantidades/precios e índices de aceleración."),
        ("04:45 - 05:45", "Mariana Olmos", "APP EN VIVO / Capturas\n(Figuras 1, 2, 3, 4, 7)", "CAMBIO A APP EN VIVO O CAPTURAS:\nRecorrido rápido por Dashboard (KPIs), Catálogo (chips y búsqueda), Detalle (Hero) y modales.", "Demostrar cómo la arquitectura se traduce en experiencia: KPIs financieros en vivo, buscador instantáneo, semáforo de stock y cálculo de saldo en modales."),
        ("05:45 - 06:00", "Mariana Olmos", "Cámara de Mariana", "RETORNO A CÁMARA:\nPlano medio de Mariana. Pase verbal a Jesús David Guerrero.", "Conclusión de la capa funcional y pase cordial a Jesús David para la auditoría técnica de pruebas y cierre."),
        ("06:00 - 06:55", "Jesús Guerrero", "Diapositiva 6:\nPruebas Unitarias 6/6", "TRANSICIÓN DIAPOSITIVA 6:\nTabla de casos de prueba y captura de terminal con 6/6 tests en verde.", "Saludo protocolario. Explicación de la suite automatizada con sqflite_common_ffi en memoria RAM. Cobertura de modelos, CRUD, transacciones ACID y rollback."),
        ("06:55 - 07:50", "Jesús Guerrero", "Diapositiva 7:\nValidación Android y QA", "TRANSICIÓN DIAPOSITIVA 7:\nEspecificaciones del emulador (API 37) y antes/después de los dos bugs.", "Detallar la ejecución en emulador Android 17. Explicar la corrección del LocaleDataException en main.dart y la corrección del layout crash Spacer en ProductCard."),
        ("07:50 - 08:45", "Jesús Guerrero", "Diapositiva 8:\nConclusiones y Futuro", "TRANSICIÓN DIAPOSITIVA 8:\nResumen de artefactos oficiales (Word APA, GitHub, Tests) y trabajo futuro.", "Certificar el cumplimiento de especificaciones. Presentar los artefactos oficiales y proyectar visión futura: exportación Excel/PDF y sincronización remota."),
        ("08:45 - 09:00", "Jesús Guerrero +\nEquipo CIPA", "Diapositiva 9:\nAgradecimientos", "PLANO CONJUNTO / MOSAICO:\nCámara con los tres integrantes (Jezer, Mariana, Jesús). Diapositiva 9 de fondo.", "Agradecimiento sincero al docente Elkin José Navarro Osorio por su acompañamiento académico. Apertura formal a la sesión de preguntas.")
    ]

    tbl_master = doc.add_table(rows=len(cue_data)+1, cols=5)
    tbl_master.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_styling(tbl_master, top=60, bottom=60, left=70, right=70)
    m_headers = ["Tiempo", "Expositor", "Soporte Visual", "Acción en Pantalla / Escena", "Pauta de Discurso y Foco Técnico"]
    m_widths = [Inches(0.9), Inches(1.1), Inches(1.3), Inches(1.7), Inches(2.0)]

    for j, h in enumerate(m_headers):
        cell = tbl_master.rows[0].cells[j]
        cell.width = m_widths[j]
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(9)
        r.font.color.rgb = RGBColor(255, 255, 255)
        set_cell_background(cell, "0F172A")

    for i, row_data in enumerate(cue_data):
        row = tbl_master.rows[i+1]
        for j, text in enumerate(row_data):
            cell = row.cells[j]
            cell.width = m_widths[j]
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(8.5)
            if j == 0:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                r.bold = True
            elif j == 1:
                r.bold = True
            elif j == 3 and "APP EN VIVO" in text:
                r.bold = True
                set_cell_background(cell, "FEF3C7")
            else:
                set_cell_background(cell, "F8FAFC" if i % 2 == 0 else "FFFFFF")

    doc.add_page_break()

    # =========================================================================
    # SECCIÓN 3: PROTOCOLO DE DEMOSTRACIÓN EN VIVO DE LA APP
    # =========================================================================
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("3. Protocolo Operativo para la Demostración en Vivo de la Aplicación")
    r.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = RGBColor(15, 23, 42)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.add_run("Para optimizar el tiempo durante la sección interactiva (minuto 04:45 a 05:45 para Mariana, o en la sesión de preguntas del docente), se debe seguir este flujo operativo paso a paso:")

    steps = [
        ("Paso 1: Apertura y Lectura del Dashboard Ejecutivo", 
         "Iniciar la app (mediante 'iniciar_servidor.bat' opción 1 para web o en emulador Android). Señalar las tarjetas KPI: 'Observen que tenemos 12 productos únicos, 380 unidades físicas y una valorización total calculada en $1.850.000 COP, con 2 productos alertados en stock crítico'."),
        
        ("Paso 2: Navegación al Catálogo y Filtrado Reactivo", 
         "Pulsar en la pestaña 'Inventario'. Teclear en el buscador 'Arroz' o 'Aceite' para evidenciar el filtrado instantáneo en milisegundos. Pulsar el chip de categoría 'Abarrotes' y luego el chip 'Stock Bajo' para mostrar cómo se aísla el inventario en riesgo sin recargar la pantalla."),
        
        ("Paso 3: Transición Hero al Detalle de Producto", 
         "Hacer clic sobre una tarjeta de producto. Destacar la animación fluida Hero que expande la información, revelando el código SKU único, fecha de registro y la bitácora específica de ese producto."),
        
        ("Paso 4: Ejecución de Movimiento de ENTRADA (Validación en Vivo)", 
         "Pulsar el botón 'Registrar Entrada'. Digitar cantidad '20' y motivo 'Reposición de proveedor'. Señalar en pantalla cómo el modal proyecta en texto verde el 'Nuevo Stock Estimado: 45 unidades' ANTES de presionar Guardar. Al confirmar, mostrar el SnackBar informativo verde."),
        
        ("Paso 5: Comprobación de Reactividad Inmediata en Dashboard e Historial", 
         "Regresar al Dashboard: las unidades totales habrán aumentado en 20 y la valorización financiera se habrá recalculado automáticamente. Luego ir a la pestaña 'Historial': el nuevo movimiento aparece en la cima de la lista con su hora exacta."),
        
        ("Paso 6: Prueba de Bloqueo de Stock Negativo (Protección Transaccional)", 
         "Intentar registrar una Salida con cantidad '999'. Mostrar cómo el modal alerta en rojo y el sistema rechaza la transacción, demostrando la inviolabilidad de las reglas de negocio.")
    ]

    for title, desc in steps:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"• {title}: ")
        r.bold = True
        r.font.size = Pt(10.5)
        r.font.color.rgb = RGBColor(16, 185, 129)
        
        p = doc.add_paragraph()
        p.paragraph_format.left_indent = Inches(0.25)
        p.paragraph_format.space_after = Pt(8)
        r = p.add_run(desc)
        r.font.size = Pt(10)

    # =========================================================================
    # SECCIÓN 4: PAUTAS TÉCNICAS DE PRODUCCIÓN Y RECOMENDACIONES OBS
    # =========================================================================
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("4. Especificaciones Técnicas de Grabación y Producción Audiovisual")
    r.bold = True
    r.font.size = Pt(13)
    r.font.color.rgb = RGBColor(15, 23, 42)

    obs_specs = [
        ("Software Recomendado", "OBS Studio (versión 30 o superior) configurado a 1080p (1920x1080) a 60 fps."),
        ("Escena A (Cámara Principal)", "Plano medio del expositor a 1080p con buena iluminación frontal. Usada en minutos 00:00-00:45, 02:40-03:00, 05:45-06:00 y despedida 08:45-09:00."),
        ("Escena B (Presentación / App)", "Captura de ventana al 80% del encuadre (PowerPoint o Emulador/Navegador) con la cámara web del expositor en Picture-in-Picture (recuadro circular o rectangular en esquina superior derecha)."),
        ("Control Estricto de Tiempo", "Cada expositor debe situar un cronómetro visible en pantalla secundaria o móvil fijado en 2 minutos con 50 segundos para regular el ritmo y garantizar el corte exacto en 3:00 minutos."),
        ("Audio Profesional", "Micrófono de solapa (Lavalier) o auricular con micrófono estático. Hablar en un entorno sin eco ni ruido de fondo.")
    ]

    tbl_obs = doc.add_table(rows=len(obs_specs)+1, cols=2)
    tbl_obs.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_styling(tbl_obs, top=60, bottom=60, left=80, right=80)
    tbl_obs.rows[0].cells[0].width = Inches(2.3)
    tbl_obs.rows[0].cells[1].width = Inches(4.2)
    
    p0 = tbl_obs.rows[0].cells[0].paragraphs[0]
    p0.add_run("Parámetro Técnico").bold = True
    p0.runs[0].font.color.rgb = RGBColor(255, 255, 255)
    set_cell_background(tbl_obs.rows[0].cells[0], "0F172A")

    p1 = tbl_obs.rows[0].cells[1].paragraphs[0]
    p1.add_run("Configuración y Recomendación").bold = True
    p1.runs[0].font.color.rgb = RGBColor(255, 255, 255)
    set_cell_background(tbl_obs.rows[0].cells[1], "0F172A")

    for i, (k, v) in enumerate(obs_specs):
        row = tbl_obs.rows[i+1]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = Inches(2.3)
        c1.width = Inches(4.2)
        
        p = c0.paragraphs[0]
        r = p.add_run(k)
        r.bold = True
        r.font.size = Pt(9.5)
        
        p = c1.paragraphs[0]
        r = p.add_run(v)
        r.font.size = Pt(9.5)

        set_cell_background(c0, "F1F5F9")
        set_cell_background(c1, "FFFFFF" if i % 2 == 0 else "F8FAFC")

    doc.add_paragraph().paragraph_format.space_after = Pt(16)

    # Concluding signature paragraph
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p.paragraph_format.space_before = Pt(24)
    r = p.add_run("Documento elaborado para la sustentación del CIPA · Asignatura Desarrollo de Apps\nFacultad de Ingeniería · Universidad de Cartagena")
    r.italic = True
    r.font.size = Pt(9.5)
    r.font.color.rgb = RGBColor(148, 163, 184)

    output_path = r"C:\Users\user\Downloads\tcc_app\docs\Cronograma_Audiovisual_Presentacion.docx"
    doc.save(output_path)
    print(f"Documento Word creado exitosamente en: {output_path}")

if __name__ == "__main__":
    create_cue_document()
