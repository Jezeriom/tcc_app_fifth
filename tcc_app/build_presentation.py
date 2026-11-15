import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_presentation():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6] # Blank layout

    # Color Palette (Tailwind Slate & Emerald)
    BG_COLOR = RGBColor(15, 23, 42)        # #0F172A Slate 900
    CARD_BG = RGBColor(30, 41, 59)         # #1E293B Slate 800
    CARD_BORDER = RGBColor(51, 65, 85)     # #334155 Slate 700
    ACCENT_GREEN = RGBColor(16, 185, 129)  # #10B981 Emerald 500
    ACCENT_LIGHT = RGBColor(52, 211, 153)  # #34D399 Emerald 400
    TEXT_WHITE = RGBColor(248, 250, 252)   # #F8FAFC Slate 50
    TEXT_MUTED = RGBColor(148, 163, 184)   # #94A3B8 Slate 400
    BADGE_BG = RGBColor(6, 78, 59)         # #064E3B Emerald 900
    BADGE_BORDER = RGBColor(16, 185, 129)  # #10B981

    def add_slide_base(title_text, subtitle_text, time_badge_text):
        slide = prs.slides.add_slide(blank_layout)
        
        # Background shape
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = BG_COLOR
        bg.line.fill.background()

        # Header Container
        header_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(9.0), Inches(1.0))
        tf = header_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
        
        p1 = tf.paragraphs[0]
        p1.text = title_text
        p1.font.size = Pt(24)
        p1.font.bold = True
        p1.font.color.rgb = TEXT_WHITE
        p1.font.name = "Arial"

        if subtitle_text:
            p2 = tf.add_paragraph()
            p2.text = subtitle_text
            p2.font.size = Pt(13)
            p2.font.color.rgb = ACCENT_LIGHT
            p2.font.name = "Arial"

        # Time & Speaker Badge
        if time_badge_text:
            badge = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(10.0), Inches(0.45), Inches(2.533), Inches(0.55))
            badge.fill.solid()
            badge.fill.fore_color.rgb = BADGE_BG
            badge.line.color.rgb = BADGE_BORDER
            badge.line.width = Pt(1)
            btf = badge.text_frame
            btf.vertical_anchor = MSO_ANCHOR.MIDDLE
            bp = btf.paragraphs[0]
            bp.alignment = PP_ALIGN.CENTER
            bp.text = time_badge_text
            bp.font.size = Pt(11)
            bp.font.bold = True
            bp.font.color.rgb = ACCENT_LIGHT
            bp.font.name = "Arial"

        # Horizontal accent bar
        bar = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.35), Inches(11.733), Inches(0.04))
        bar.fill.solid()
        bar.fill.fore_color.rgb = CARD_BORDER
        bar.line.fill.background()

        return slide

    def add_card(slide, left, top, width, height, title, content_lines, is_accent=False):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = CARD_BG
        card.line.color.rgb = ACCENT_GREEN if is_accent else CARD_BORDER
        card.line.width = Pt(1.5 if is_accent else 1)
        
        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.2)
        tf.margin_right = Inches(0.2)
        tf.margin_top = Inches(0.2)
        tf.margin_bottom = Inches(0.2)
        
        if title:
            p = tf.paragraphs[0]
            p.text = title
            p.font.size = Pt(14)
            p.font.bold = True
            p.font.color.rgb = ACCENT_LIGHT if is_accent else TEXT_WHITE
            p.font.name = "Arial"
            p.space_after = Pt(8)
            start_idx = 1
        else:
            start_idx = 0

        for i, line in enumerate(content_lines):
            p = tf.add_paragraph() if (title or i > 0) else tf.paragraphs[0]
            p.text = line
            p.font.size = Pt(11)
            p.font.color.rgb = TEXT_WHITE if line.startswith("•") or ":" in line else TEXT_MUTED
            p.font.name = "Arial"
            p.space_after = Pt(4)
        return card

    # =========================================================================
    # SLIDE 1: PORTADA INSTITUCIONAL
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    bg1 = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg1.fill.solid()
    bg1.fill.fore_color.rgb = BG_COLOR
    bg1.line.fill.background()

    # Main Card
    main_box = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.2), Inches(0.9), Inches(10.933), Inches(5.7))
    main_box.fill.solid()
    main_box.fill.fore_color.rgb = CARD_BG
    main_box.line.color.rgb = ACCENT_GREEN
    main_box.line.width = Pt(2)

    tb = s1.shapes.add_textbox(Inches(1.6), Inches(1.2), Inches(10.133), Inches(5.1))
    tf = tb.text_frame
    tf.word_wrap = True

    p = tf.paragraphs[0]
    p.text = "UNIVERSIDAD DE CARTAGENA · FACULTAD DE INGENIERÍA"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = ACCENT_LIGHT
    p.alignment = PP_ALIGN.CENTER

    p = tf.add_paragraph()
    p.text = "TRABAJO COLABORATIVO CONTEXTUALIZADO (TCC) — V SEMESTRE"
    p.font.size = Pt(12)
    p.font.color.rgb = TEXT_MUTED
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(16)

    p = tf.add_paragraph()
    p.text = "Aplicación Móvil «Inventario»"
    p.font.size = Pt(30)
    p.font.bold = True
    p.font.color.rgb = TEXT_WHITE
    p.alignment = PP_ALIGN.CENTER

    p = tf.add_paragraph()
    p.text = "Gestión Local de Existencias, Movimientos y Persistencia Relacional Offline con SQLite"
    p.font.size = Pt(15)
    p.font.color.rgb = ACCENT_LIGHT
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(24)

    # Info Grid inside slide 1
    p = tf.add_paragraph()
    p.text = "Asignatura: Desarrollo de Aplicaciones Móviles       |       Tutor Docente: Elkin José Navarro Osorio"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = TEXT_WHITE
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(14)

    p = tf.add_paragraph()
    p.text = "Equipo CIPA: Jezer Martínez Pérez   ·   Mariana Camila Olmos Pérez   ·   Jesús David Guerrero Rada"
    p.font.size = Pt(13)
    p.font.color.rgb = TEXT_WHITE
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(18)

    p = tf.add_paragraph()
    p.text = "Duración Total: 9 Minutos (3:00 min equitativos por expositor)   |   Repositorio: github.com/Jezeriom/tcc_app_fifth"
    p.font.size = Pt(11)
    p.font.color.rgb = TEXT_MUTED
    p.alignment = PP_ALIGN.CENTER

    # =========================================================================
    # SLIDE 2: OBJETIVOS TÉCNICOS Y DE NEGOCIO (PERSONA 1: JEZER)
    # =========================================================================
    s2 = add_slide_base("Objetivos Técnicos y de Negocio Alcanzados", 
                        "Respuesta integral a la problemática de gestión de inventario offline", 
                        "PERSONA 1 · 00:45 - 01:35")
    
    col_w = Inches(3.64)
    h = Inches(2.45)
    top1 = Inches(1.6)
    top2 = Inches(4.35)

    add_card(s2, Inches(0.8), top1, col_w, h, "1. Administración Integral CRUD", [
        "• Catálogo interactivo de productos.",
        "• Altas, consultas, edición y bajas.",
        "• Búsqueda instantánea y filtros dinámicos.",
        "• Actualización reactiva sin recargar pantalla."
    ])
    add_card(s2, Inches(4.84), top1, col_w, h, "2. Motor Analítico Local", [
        "• Cálculo dinámico de referencias activas.",
        "• Monitoreo de unidades físicas en almacén.",
        "• Valorización monetaria en tiempo real (COP).",
        "• Alerta inmediata de productos en stock crítico."
    ], is_accent=True)
    add_card(s2, Inches(8.88), top1, col_w, h, "3. Módulo Estricto de Movimientos", [
        "• Registro riguroso de entradas y salidas.",
        "• Pre-cálculo de saldo antes de confirmar.",
        "• Validación estricta contra stock negativo.",
        "• Captura obligatoria de motivo y fecha."
    ])

    add_card(s2, Inches(0.8), top2, col_w, h, "4. Trazabilidad y Auditoría", [
        "• Bitácora histórica con balance contable.",
        "• Filtrado combinado por tipo y período.",
        "• Balance neto de unidades ingresadas/egresadas.",
        "• Identificación visual por colores y flechas."
    ])
    add_card(s2, Inches(4.84), top2, col_w, h, "5. Arquitectura Desacoplada", [
        "• Estructura modular en capas (Clean/MVVM).",
        "• Contrato mediador IInventoryRepository.",
        "• Estado centralizado con Provider.",
        "• Aislamiento total entre vista y persistencia."
    ])
    add_card(s2, Inches(8.88), top2, col_w, h, "6. Calidad y Pruebas Unitarias", [
        "• Suite automatizada con sqflite_common_ffi.",
        "• 6/6 pruebas aprobadas con 100% de éxito.",
        "• Validación en Android 17 (API 37) a 60 fps.",
        "• Cero errores de compilación o renderizado."
    ], is_accent=True)

    # =========================================================================
    # SLIDE 3: FASES 1 A 3: STACK, PERSISTENCIA Y ESTADO REACTIVO (PERSONA 1: JEZER)
    # =========================================================================
    s3 = add_slide_base("Fases 1 a 3: Stack Tecnológico, Modelos y Reactividad", 
                        "Fundamentos de persistencia relacional local y gestión de estado reactivo", 
                        "PERSONA 1 · 01:35 - 02:40")

    add_card(s3, Inches(0.8), Inches(1.6), Inches(3.64), Inches(5.2), "Stack Tecnológico Oficial", [
        "Framework & Lenguaje:",
        "• Flutter 3.x + Dart con compilación AOT.",
        "• Renderizado fluido a 60 fps en móvil y web.",
        "",
        "Librerías Críticas (pubspec.yaml):",
        "• sqflite: Motor nativo SQLite para Android/iOS.",
        "• sqflite_common_ffi: Tests y ejecución en memoria.",
        "• provider: Estado reactivo con ChangeNotifier.",
        "• intl: Formateo monetario en COP y fechas 'es'.",
        "• path: Resolución robusta de rutas locales.",
        "",
        "Diseño Visual Material Design 3:",
        "• Paleta Deep Indigo (#1E293B) y Emerald (#059669).",
        "• Tipografía clara y contraste ergonómico."
    ])

    add_card(s3, Inches(4.84), Inches(1.6), Inches(3.64), Inches(5.2), "Capa de Datos y Modelos", [
        "Modelos Inmutables Tipificados:",
        "• ProductModel: Mapeo de id, nombre, categoria, cantidad, precio, stockMinimo, codigoSku.",
        "• MovementModel: Registro de transacciones tipo ENTRADA/SALIDA con motivo y timestamp.",
        "• InventorySummaryModel: Objeto de valor analítico que sintetiza los 4 KPIs del Dashboard.",
        "",
        "DatabaseHelper (Singleton):",
        "• Instancia única mediante DatabaseHelper._();",
        "• Apertura de base 'inventario_tcc.db'.",
        "• Ejecución de PRAGMA foreign_keys = ON;",
        "• Creación de índices sobre SKU y productos.",
        "• Soporte transaccional indivisible db.transaction()."
    ], is_accent=True)

    add_card(s3, Inches(8.88), Inches(1.6), Inches(3.64), Inches(5.2), "Repositorio y Estado Provider", [
        "Contrato IInventoryRepository:",
        "• Aísla la interfaz de la implementación.",
        "• Métodos CRUD: getProducts, insertProduct, updateProduct, deleteProduct.",
        "• Operaciones de negocio: registerMovement, getMovements, getInventorySummary.",
        "",
        "InventoryProvider (ChangeNotifier):",
        "• Orquestador reactivo de la UI.",
        "• Filtros en tiempo real por búsqueda y chips.",
        "• Notificación atómica con notifyListeners().",
        "• Redibujo selectivo en widgets Consumer.",
        "",
        "Garantía Offline-First:",
        "• Cero llamadas a servidores externos.",
        "• Autonomía operativa absoluta del comercio."
    ])

    # =========================================================================
    # SLIDE 4: ARQUITECTURA TÉCNICA EN 5 CAPAS (PERSONA 2: MARIANA)
    # =========================================================================
    s4 = add_slide_base("Arquitectura Técnica en 5 Capas y Responsabilidades", 
                        "Flujo unidireccional desacoplado inspirado en Clean Architecture", 
                        "PERSONA 2 · 03:00 - 03:50")

    add_card(s4, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.2), "Estructura por Capas y Flujo de Datos", [
        "1. Capa de Presentación (lib/views/):",
        "   Renderizado de widgets, vistas y captura de eventos táctiles. No conoce la base de datos.",
        "",
        "2. Capa de Estado Reactivo (lib/providers/):",
        "   InventoryProvider centraliza filtros, KPIs y coordina mutaciones emitiendo notificaciones.",
        "",
        "3. Capa de Dominio y Repositorio (lib/repositories/):",
        "   Contrato IInventoryRepository e implementación InventoryRepository como puente desacoplador.",
        "",
        "4. Capa de Persistencia Local (lib/core/database/):",
        "   DatabaseHelper ejecuta consultas SQL, DDL y transacciones ACID en SQLite.",
        "",
        "5. Capa de Modelos de Datos (lib/models/):",
        "   ProductModel y MovementModel garantizan serialización segura Map<String, dynamic> <-> Dart."
    ], is_accent=True)

    add_card(s4, Inches(6.8), Inches(1.6), Inches(5.733), Inches(5.2), "Beneficios de Ingeniería Aplicados", [
        "• Separación Estricta de Responsabilidades (SoC):",
        "  Cada capa tiene un único motivo para cambiar.",
        "",
        "• Alta Testabilidad en Aislamiento:",
        "  El repositorio y los modelos se prueban sin necesidad de levantar interfaz gráfica ni emuladores.",
        "",
        "• Facilidad de Mantenimiento y Escalabilidad:",
        "  Si en el futuro se incorpora sincronización remota o cambio de motor, la interfaz de usuario permanece intacta.",
        "",
        "• Tolerancia a Fallos y Prevención de Crashes:",
        "  Control exhaustivo de excepciones y validaciones de tipos en cada nivel de frontera.",
        "",
        "• Reactividad Selectiva a 60 FPS:",
        "  Los widgets sólo se reconstruyen cuando sus datos dependientes específicos sufren una mutación real."
    ])

    # =========================================================================
    # SLIDE 5: MODELO RELACIONAL SQLITE, DDL Y REGLAS (PERSONA 2: MARIANA)
    # =========================================================================
    s5 = add_slide_base("Modelo Relacional SQLite, Esquema DDL e Integridad", 
                        "Normalización relacional, restricciones CHECK y transacciones ACID", 
                        "PERSONA 2 · 03:50 - 04:45")

    add_card(s5, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.2), "Definición del Esquema DDL", [
        "Tabla 'productos':",
        "• id INTEGER PRIMARY KEY AUTOINCREMENT",
        "• nombre TEXT NOT NULL",
        "• descripcion TEXT",
        "• categoria TEXT NOT NULL",
        "• cantidad INTEGER NOT NULL CHECK(cantidad >= 0)",
        "• precio REAL NOT NULL CHECK(precio >= 0)",
        "• stockMinimo INTEGER NOT NULL CHECK(stockMinimo >= 0)",
        "• codigoSku TEXT UNIQUE NOT NULL",
        "• fechaIngreso TEXT NOT NULL",
        "",
        "Tabla 'movimientos' (Kardex):",
        "• idMovimiento INTEGER PRIMARY KEY AUTOINCREMENT",
        "• idProducto INTEGER NOT NULL",
        "• tipo TEXT NOT NULL CHECK(tipo IN ('ENTRADA', 'SALIDA'))",
        "• cantidad INTEGER NOT NULL CHECK(cantidad > 0)",
        "• motivo TEXT NOT NULL",
        "• fecha TEXT NOT NULL",
        "• FOREIGN KEY (idProducto) REFERENCES productos(id) ON DELETE CASCADE"
    ], is_accent=True)

    add_card(s5, Inches(6.8), Inches(1.6), Inches(5.733), Inches(5.2), "Reglas de Integridad y Transacciones ACID", [
        "1. Integridad Referencial Obligatoria:",
        "   PRAGMA foreign_keys = ON; activado explícitamente en el DatabaseHelper.",
        "",
        "2. Eliminación en Cascada (ON DELETE CASCADE):",
        "   Si se da de baja un producto, se depuran automáticamente todos sus movimientos históricos.",
        "",
        "3. Transaccionalidad Indivisible (db.transaction()):",
        "   El registro del movimiento y la actualización del balance de stock se ejecutan como una unidad atómica.",
        "   Si ocurre un corte de energía o fallo, SQLite efectúa un Rollback automático y previene descuadres.",
        "",
        "4. Optimización de Índices de Base de Datos:",
        "   CREATE INDEX idx_movimientos_producto ON movimientos(idProducto);",
        "   Consultas de historial resueltas en < 5 milisegundos."
    ])

    # =========================================================================
    # SLIDE 6: ESTRATEGIA DE PRUEBAS AUTOMATIZADAS 6/6 (PERSONA 3: JESÚS)
    # =========================================================================
    s6 = add_slide_base("Estrategia de Pruebas Automatizadas (100% Éxito)", 
                        "Verificación técnica de lógica de negocio y transacciones sobre SQLite FFI", 
                        "PERSONA 3 · 06:00 - 06:55")

    add_card(s6, Inches(0.8), Inches(1.6), Inches(6.8), Inches(5.2), "Batería de Pruebas Unitarias Ejecutadas", [
        "1. Test Modelos y Serialización: [APROBADO]",
        "   Conversión bidireccional Map/JSON y copyWith en ProductModel y MovementModel.",
        "",
        "2. Test CRUD y Persistencia Básica: [APROBADO]",
        "   Inserción, lectura, edición y eliminación de productos en base de datos en memoria.",
        "",
        "3. Test Transacción Atómica de ENTRADA: [APROBADO]",
        "   Comprobación de incremento exacto de stock y registro simultáneo en kardex.",
        "",
        "4. Test Bloqueo de Stock Negativo en SALIDA: [APROBADO]",
        "   Validación de rollback automático si una salida excede el inventario existente.",
        "",
        "5. Test Cascada de Llaves Foráneas: [APROBADO]",
        "   Comprobación de depuración de movimientos huérfanos al borrar un producto.",
        "",
        "6. Test Motor Analítico y Filtros: [APROBADO]",
        "   Validación del cálculo financiero total (precio x cantidad) y filtrado de categorías."
    ], is_accent=True)

    add_card(s6, Inches(8.0), Inches(1.6), Inches(4.533), Inches(5.2), "Certificación de Calidad", [
        "Framework de Pruebas:",
        "• flutter_test con motor nativo Dart.",
        "• sqflite_common_ffi en memoria RAM.",
        "",
        "Resultados Verificados:",
        "• 6 Casos de prueba ejecutados.",
        "• 6 Casos de prueba aprobados (100%).",
        "• 0 Regresiones en cálculos contables.",
        "• 0 Fugas de consistencia en transacciones.",
        "",
        "Tiempo de Ejecución:",
        "• < 1.8 segundos para la suite completa.",
        "",
        "Comando de Verificación:",
        "• flutter test test/models_and_transactions_test.dart"
    ])

    # =========================================================================
    # SLIDE 7: VALIDACIÓN ANDROID API 37 Y RESOLUCIÓN QA (PERSONA 3: JESÚS)
    # =========================================================================
    s7 = add_slide_base("Validación en Android 17 (API 37) y Resoluciones QA", 
                        "Ejecución en entorno real y depuración técnica de incidencias", 
                        "PERSONA 3 · 06:55 - 07:50")

    add_card(s7, Inches(0.8), Inches(1.6), Inches(4.8), Inches(5.2), "Entorno de Pruebas en Emulador", [
        "Especificaciones del Dispositivo:",
        "• Dispositivo: Android Emulator (emulator-5554)",
        "• Imagen de Sistema: sdk gphone16k x86_64",
        "• Versión de SO: Android 17 (API nivel 37)",
        "• Resolución de Pantalla: 1344 x 2992 px",
        "• Densidad: 480 dpi (Extra High Density)",
        "",
        "Validación de Rendimiento:",
        "• Tasa de refresco constante a 60 fps.",
        "• Cero bloqueos de hilo principal (UI Thread).",
        "• Consumo de memoria optimizado (< 85 MB).",
        "• Capturas oficiales generadas en docs/screenshots/."
    ])

    add_card(s7, Inches(6.0), Inches(1.6), Inches(6.533), Inches(5.2), "Incidencias Técnicas Identificadas y Subsanadas", [
        "Incidencia QA 1: Fallo de Localización Regional (LocaleDataException)",
        "• Diagnóstico: El formateo de fechas en español mediante DateFormat('dd/MM/yyyy', 'es') fallaba porque los datos locales no estaban precargados.",
        "• Solución Aplicada: En lib/main.dart se invocó WidgetsFlutterBinding.ensureInitialized() y se llamó a initializeDateFormatting('es', null) antes de instanciar runApp().",
        "",
        "Incidencia QA 2: Layout Crash en Tarjeta de Producto (Spacer en ListView)",
        "• Diagnóstico: Se utilizaba un Spacer dentro de una Column contenida en un ListView con scroll vertical infinito, provocando desbordamiento de caja (BoxConstraints).",
        "• Solución Aplicada: Se reemplazó el Spacer por un SizedBox(height: 14) de dimensión fija, eliminando la violación de restricciones sin alterar la estética.",
        "",
        "Auditoría Final de Código:",
        "• Ejecución de 'flutter analyze' obteniendo 0 errores y 0 advertencias."
    ], is_accent=True)

    # =========================================================================
    # SLIDE 8: CONCLUSIONES TÉCNICAS Y ENTREGABLES (PERSONA 3: JESÚS)
    # =========================================================================
    s8 = add_slide_base("Conclusiones Técnicas, Entregables y Trabajo Futuro", 
                        "Balance final del proyecto colaborativo y proyección tecnológica", 
                        "PERSONA 3 · 07:50 - 08:45")

    add_card(s8, Inches(0.8), Inches(1.6), Inches(5.6), Inches(5.2), "Artefactos Oficiales de Entrega", [
        "1. Informe Final TCC Formato APA 7 (.docx):",
        "   22 páginas completas, portada formal, tabla de contenido en página 2, desarrollo de Fases 1 a 5, pruebas 6/6, evidencias comentadas y catálogo modular en Apéndice A.",
        "",
        "2. Suite de Pruebas Unitarias Verificable:",
        "   Archivo test/models_and_transactions_test.dart con 100% de aprobación técnica.",
        "",
        "3. Repositorio Remoto Público en GitHub:",
        "   github.com/Jezeriom/tcc_app_fifth.git con código limpio, arquitectura desacoplada y README exhaustivo.",
        "",
        "4. Scripts de Ejecución Multiplataforma:",
        "   iniciar_servidor.bat e iniciar_app.bat para lanzamiento en Web (puerto 8080) o emulador Android."
    ], is_accent=True)

    add_card(s8, Inches(6.8), Inches(1.6), Inches(5.733), Inches(5.2), "Logros y Proyección de Trabajo Futuro", [
        "Logros Consolidados:",
        "• Cumplimiento al 100% de la guía académica TCC.",
        "• Persistencia relacional local sólida y rápida.",
        "• Experiencia de usuario Material Design 3 accesible.",
        "• Trabajo en equipo sinérgico y equitativo en el CIPA.",
        "",
        "Visión de Trabajo Futuro (Segunda Iteración):",
        "• Exportación de inventarios a hojas Excel (.xlsx) y generación de reportes en PDF descargables.",
        "• Integración de escáner de códigos de barra mediante la cámara del móvil (cámara / ZXing).",
        "• Protocolo de sincronización remota bidireccional (Cloud Firestore / REST) para comercios con múltiples puntos de venta."
    ])

    # =========================================================================
    # SLIDE 9: CIERRE Y AGRADECIMIENTOS EN EQUIPO
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    bg9 = s9.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg9.fill.solid()
    bg9.fill.fore_color.rgb = BG_COLOR
    bg9.line.fill.background()

    card9 = s9.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.5), Inches(1.2), Inches(10.333), Inches(5.1))
    card9.fill.solid()
    card9.fill.fore_color.rgb = CARD_BG
    card9.line.color.rgb = ACCENT_GREEN
    card9.line.width = Pt(2)

    tb9 = s9.shapes.add_textbox(Inches(1.8), Inches(1.6), Inches(9.733), Inches(4.3))
    tf9 = tb9.text_frame
    tf9.word_wrap = True

    p = tf9.paragraphs[0]
    p.text = "¡Muchas Gracias por su Atención!"
    p.font.size = Pt(32)
    p.font.bold = True
    p.font.color.rgb = TEXT_WHITE
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(20)

    p = tf9.add_paragraph()
    p.text = "Agradecimiento especial a nuestro docente tutor:"
    p.font.size = Pt(14)
    p.font.color.rgb = TEXT_MUTED
    p.alignment = PP_ALIGN.CENTER

    p = tf9.add_paragraph()
    p.text = "Profesor Elkin José Navarro Osorio"
    p.font.size = Pt(20)
    p.font.bold = True
    p.font.color.rgb = ACCENT_LIGHT
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(24)

    p = tf9.add_paragraph()
    p.text = "Equipo CIPA — V Semestre de Ingeniería de Software:"
    p.font.size = Pt(13)
    p.font.color.rgb = TEXT_MUTED
    p.alignment = PP_ALIGN.CENTER

    p = tf9.add_paragraph()
    p.text = "Jezer Martínez Pérez   |   Mariana Camila Olmos Pérez   |   Jesús David Guerrero Rada"
    p.font.size = Pt(15)
    p.font.bold = True
    p.font.color.rgb = TEXT_WHITE
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(24)

    p = tf9.add_paragraph()
    p.text = "Espacio Abierto para Preguntas Técnicas y Retroalimentación"
    p.font.size = Pt(13)
    p.font.color.rgb = ACCENT_LIGHT
    p.alignment = PP_ALIGN.CENTER

    output_path = r"C:\Users\user\Downloads\tcc_app\docs\Presentacion_TCC_Inventario.pptx"
    prs.save(output_path)
    print(f"Presentación creada exitosamente en: {output_path}")

if __name__ == "__main__":
    create_presentation()
