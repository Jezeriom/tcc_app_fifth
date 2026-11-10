$ErrorActionPreference = 'Stop'
$file = 'docs/Informe_Final_Actividad_TCC.docx'
$batchPath = Join-Path $env:TEMP 'tcc_report_batch.json'
$commands = [System.Collections.Generic.List[object]]::new()
$images = [System.Collections.Generic.List[object]]::new()
$paragraphNumber = 0
$tableNumber = 0

function Add-Paragraph {
  param([string]$Text, [string]$Style = 'Normal', [string]$Size = '12pt', [string]$Align = 'justify', [string]$Color = '000000', [string]$Font = 'Times New Roman', [string]$SpaceBefore = '0pt', [string]$SpaceAfter = '6pt', [string]$PageBreak = 'false', [string]$ListStyle = '', [switch]$NoIndent, [bool]$Bold = $false, [bool]$Italic = $false, [bool]$KeepNext = $false)
  $script:paragraphNumber++
  $effectiveSpaceAfter = if (-not $NoIndent -and $Align -eq 'justify' -and $Style -notmatch '^Heading') { '6pt' } else { $SpaceAfter }
  $props = @{ text = $Text; style = $Style; size = '12pt'; align = $Align; color = '000000'; font = 'Times New Roman'; spaceBefore = $SpaceBefore; spaceAfter = $effectiveSpaceAfter; lineSpacing = '1.5x'; lineRule = 'auto' }
  if (-not $NoIndent -and $Align -eq 'justify' -and -not $ListStyle -and $Style -notmatch '^Heading' -and $Font -ne 'Consolas') { $props.firstLineIndent = '850' }
  if ($Bold) { $props.bold = 'true' }
  if ($Italic) { $props.italic = 'true' }
  if ($KeepNext) { $props.keepNext = 'true' }
  if ($PageBreak -eq 'true') { $props.pageBreakBefore = 'true' }
  if ($ListStyle) { $props.listStyle = $ListStyle }
  $script:commands.Add(@{ command = 'add'; parent = '/body'; type = 'paragraph'; props = $props })
}

function Add-Heading {
  param([string]$Text, [int]$Level = 1, [bool]$PageBreak = $false)
  $style = if ($Level -eq 1) { 'Heading1' } else { 'Heading2' }
  $align = if ($Level -eq 1) { 'center' } else { 'left' }
  $spaceBefore = if ($Level -eq 1) { '14pt' } else { '11pt' }
  $spaceAfter = if ($Level -eq 1) { '7pt' } else { '5pt' }
  Add-Paragraph -Text $Text -Style $style -Align $align -SpaceBefore $spaceBefore -SpaceAfter $spaceAfter -PageBreak $PageBreak -NoIndent -Bold $true -KeepNext $true
}

function Add-Table {
  param([string[]]$Headers, [string[][]]$Rows, [string]$Caption)
  $script:tableNumber++
  Add-Paragraph -Text 'Tabla' -Style 'Normal' -Align 'left' -SpaceBefore '6pt' -SpaceAfter '0pt' -NoIndent -Bold $true
  Add-Paragraph -Text $Caption -Style 'Normal' -Align 'left' -SpaceBefore '0pt' -SpaceAfter '6pt' -NoIndent -Italic $true
  $nRows = $Rows.Count + 1
  $nCols = $Headers.Count
  $script:commands.Add(@{ command = 'add'; parent = '/body'; type = 'table'; props = @{ rows = "$nRows"; cols = "$nCols"; width = '100%'; style = 'none'; caption = $Caption; padding = '90'; 'border.all' = 'none' } })
  $tablePath = "/body/tbl[$script:tableNumber]"
  $headerProps = @{ header = 'true' }
  for ($c = 0; $c -lt $nCols; $c++) { $headerProps["c$($c+1)"] = $Headers[$c] }
  $script:commands.Add(@{ command = 'set'; path = "$tablePath/tr[1]"; props = $headerProps })
  for ($r = 0; $r -lt $Rows.Count; $r++) {
    $rowProps = @{}
    for ($c = 0; $c -lt $nCols; $c++) { $rowProps["c$($c+1)"] = $Rows[$r][$c] }
    $script:commands.Add(@{ command = 'set'; path = "$tablePath/tr[$($r+2)]"; props = $rowProps })
  }
  for ($r = 1; $r -le $nRows; $r++) {
    for ($c = 1; $c -le $nCols; $c++) {
      $cellPath = "$tablePath/tr[$r]/tc[$c]"
      $cellProps = @{ font = 'Times New Roman'; size = '12pt'; color = '000000' }
      if ($r -eq 1) { $cellProps.bold = 'true'; $cellProps['border.top'] = 'single;1pt;000000'; $cellProps['border.bottom'] = 'single;1pt;000000' }
      if ($r -eq $nRows) { $cellProps['border.bottom'] = 'single;1pt;000000' }
      $script:commands.Add(@{ command = 'set'; path = $cellPath; props = $cellProps })
      $script:commands.Add(@{ command = 'set'; path = "$cellPath/p[1]"; props = @{ align = 'left'; firstLineIndent = '0'; lineSpacing = '1.5x'; lineRule = 'auto'; spaceBefore = '0pt'; spaceAfter = '0pt' } })
    }
  }
}

function Add-Image {
  param([string]$Path, [string]$Alt, [string]$Caption)
  $captionParts = $Caption -split '\.', 2
  $figureLabel = $captionParts[0] -replace '\s+\d+$', ''
  Add-Paragraph -Text $figureLabel -Style 'Normal' -Align 'left' -SpaceBefore '0pt' -SpaceAfter '0pt' -NoIndent -Bold $true -KeepNext $true
  if ($captionParts.Count -gt 1) { Add-Paragraph -Text $captionParts[1].Trim() -Style 'Normal' -Align 'left' -SpaceBefore '0pt' -SpaceAfter '0pt' -NoIndent -Italic $true -KeepNext $true }
  Add-Paragraph -Text '' -Style 'Normal' -Align 'center' -SpaceBefore '0pt' -SpaceAfter '0pt' -NoIndent -KeepNext $true
  Add-Paragraph -Text 'Nota. Captura propia de la aplicación Inventario, realizada en emulator-5554 (Android 17).' -Style 'Normal' -Align 'left' -SpaceBefore '0pt' -SpaceAfter '6pt' -NoIndent -Italic $true
  $script:images.Add(@{ src = $Path; alt = $Alt; caption = $Caption })
}

if (Test-Path -LiteralPath $file) { officecli close $file 2>$null; Remove-Item -LiteralPath $file -Force }
officecli create $file
officecli open $file
$commands.Add(@{ command = 'set'; path = '/section[1]'; props = @{ pageWidth = '21cm'; pageHeight = '29.7cm'; marginTop = '2.54cm'; marginBottom = '2.54cm'; marginLeft = '2.54cm'; marginRight = '2.54cm'; marginHeader = '1.25cm'; marginFooter = '1.25cm'; 'docGrid.linePitch' = '360' } })

# Portada con la composición del documento institucional de referencia.
Add-Paragraph -Text 'ACTIVIDAD DE APRENDIZAJE' -Style 'Normal' -Align 'center' -SpaceBefore '36pt' -SpaceAfter '30pt' -NoIndent -Bold $true
Add-Paragraph -Text 'INFORME TÉCNICO DE ENTREGA' -Style 'Normal' -Align 'center' -SpaceAfter '12pt' -NoIndent -Bold $true
Add-Paragraph -Text 'Diseño e implementación de la aplicación móvil Inventario' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent -Bold $true
Add-Paragraph -Text 'Gestión local de existencias y movimientos sin conexión' -Style 'Normal' -Align 'center' -SpaceAfter '30pt' -NoIndent
Add-Paragraph -Text 'ASIGNATURA:' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent -Bold $true
Add-Paragraph -Text 'DESARROLLO DE APLICACIONES MÓVILES' -Style 'Normal' -Align 'center' -SpaceAfter '30pt' -NoIndent
Add-Paragraph -Text 'CIPA:' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent -Bold $true
Add-Paragraph -Text 'JEZER MARTINEZ PEREZ' -Style 'Normal' -Align 'center' -SpaceAfter '0pt' -NoIndent
Add-Paragraph -Text 'MARIANA CAMILA OLMOS PEREZ' -Style 'Normal' -Align 'center' -SpaceAfter '0pt' -NoIndent
Add-Paragraph -Text 'JESUS DAVID GUERRERO RADA' -Style 'Normal' -Align 'center' -SpaceAfter '18pt' -NoIndent
Add-Paragraph -Text 'TUTOR:' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent -Bold $true
Add-Paragraph -Text 'EVELIN BARCO LLERENA' -Style 'Normal' -Align 'center' -SpaceAfter '24pt' -NoIndent
Add-Paragraph -Text 'INGENIERÍA EN SOFTWARE' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent
Add-Paragraph -Text 'V SEMESTRE' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent
Add-Paragraph -Text 'ACTIVIDAD TCC' -Style 'Normal' -Align 'center' -SpaceAfter '6pt' -NoIndent
Add-Paragraph -Text '28 de octubre de 2026' -Style 'Normal' -Align 'center' -SpaceAfter '0pt' -NoIndent

# Informe
Add-Heading -Text '1. Introducción y contexto de negocio' -Level 1 -PageBreak $true
Add-Paragraph -Text 'Los comercios pequeños necesitan conocer qué productos tienen disponibles, cuánto capital representa el inventario y qué referencias requieren reposición. Cuando el control depende de apuntes dispersos o de una conexión permanente a servicios externos, registrar una entrada o una salida puede retrasarse y los saldos pierden confiabilidad.'
Add-Paragraph -Text 'Inventario permite administrar productos y movimientos desde el dispositivo. SQLite conserva los datos localmente, por lo que las tareas principales de consulta y registro funcionan sin conexión a Internet. El alcance de esta entrega es individual y local: no contempla sincronización entre dispositivos, cuentas de usuario ni una consola administrativa remota.'
Add-Paragraph -Text 'La aplicación presenta un resumen de indicadores, un catálogo con búsqueda y filtros, formularios de productos, detalle con movimientos y un historial filtrable. Cada entrada o salida modifica el saldo y queda registrada en una transacción de base de datos.'

Add-Heading -Text '2. Objetivos alcanzados' -Level 1
foreach ($item in @(
  'Construir una aplicación móvil para registrar, consultar, editar y eliminar productos de inventario.',
  'Calcular unidades disponibles, valorización del stock y productos en nivel crítico.',
  'Registrar entradas y salidas con motivo, fecha, validación de cantidades y protección frente a saldos negativos.',
  'Consultar movimientos por producto, tipo y período desde una base SQLite local.',
  'Separar interfaz, gestión de estado, acceso al repositorio y persistencia para facilitar mantenimiento.',
  'Verificar serialización, agregados y transacciones mediante seis pruebas automatizadas y revisar la aplicación en emulador Android.'
)) { Add-Paragraph -Text $item -ListStyle 'bullet' }

Add-Heading -Text '3. Fases de desarrollo (1 a 5)' -Level 1
Add-Heading -Text 'Fase 1 · Dependencias, recursos y tema' -Level 2
Add-Paragraph -Text 'Se configuraron Flutter, sqflite, path, Provider e intl; se incorporaron recursos de marca e iconos de launcher y se definió una paleta visual basada en Material 3.'
Add-Heading -Text 'Fase 2 · Modelos y persistencia SQLite' -Level 2
Add-Paragraph -Text 'Se implementaron ProductModel, MovementModel e InventorySummaryModel, junto con DatabaseHelper como acceso único a la base local. El esquema aplica restricciones CHECK, unicidad del SKU, claves foráneas e índices. Las operaciones de movimiento y las correcciones del saldo se agrupan en transacciones.'
Add-Heading -Text 'Fase 3 · Repositorio y estado reactivo' -Level 2
Add-Paragraph -Text 'IInventoryRepository define el contrato de acceso; InventoryRepository lo conecta con DatabaseHelper. InventoryProvider, basado en ChangeNotifier, carga productos, categorías, resumen e historial y aplica los filtros y mutaciones solicitados por la interfaz.'
Add-Heading -Text 'Fase 4 · Dashboard y catálogo' -Level 2
Add-Paragraph -Text 'Se implementaron las vistas de resumen con KPIs, alertas y accesos rápidos; el catálogo incorpora búsqueda por nombre, SKU o descripción, chips por categoría, filtro de stock bajo e indicadores de disponibilidad.'
Add-Heading -Text 'Fase 5 · Formularios, detalle, movimientos e historial' -Level 2
Add-Paragraph -Text 'Se construyeron los formularios con validación, la ficha del producto, el diálogo de entrada/salida con cálculo previo del saldo y el historial con filtros por tipo y fecha. La interfaz presenta también los movimientos recientes por producto. El pulido visual incorporó transiciones Hero entre tarjeta y detalle, snackbars de confirmación o error, badges semánticos de stock y un banner ejecutivo con saludo, fecha y contexto del inventario.'

Add-Heading -Text '4. Arquitectura técnica' -Level 1
Add-Paragraph -Text 'La solución emplea una separación por capas inspirada en Clean Architecture. No incorpora una capa independiente de casos de uso o dominio: el modelo actual se compone de vistas, proveedor de estado, contratos/repositorios, modelos de datos y un helper de persistencia. La dirección de las llamadas evita que las vistas consulten directamente SQLite.'
Add-Table -Caption 'Responsabilidades por capa' -Headers @('Capa', 'Componentes', 'Responsabilidad') -Rows @(
  @('Presentación', 'lib/views/', 'Dashboard, catálogo, formulario, detalle, diálogo e historial.'),
  @('Estado', 'lib/providers/inventory_provider.dart', 'Estado reactivo, filtros, carga y coordinación de operaciones.'),
  @('Repositorio', 'lib/repositories/', 'Contrato y adaptación de las operaciones solicitadas por el proveedor.'),
  @('Persistencia', 'lib/core/database/database_helper.dart', 'Conexión SQLite, esquema, consultas y transacciones.'),
  @('Modelos', 'lib/models/', 'Representación y serialización de productos, movimientos y resumen.')
)
Add-Paragraph -Text 'Flujo principal: Vista ? InventoryProvider ? IInventoryRepository / InventoryRepository ? DatabaseHelper ? SQLite local.' -Style 'Normal' -Size '10pt' -Font 'Consolas' -Color '0F4C5C' -SpaceBefore '6pt' -SpaceAfter '9pt'
Add-Paragraph -Text 'Provider expone cambios a la interfaz mediante ChangeNotifier. El repositorio mantiene desacoplada la presentación de la base; DatabaseHelper centraliza validaciones, consultas parametrizadas y operaciones que actualizan stock y bitácora dentro de una transacción.'

Add-Heading -Text '5. Modelo de datos, DDL y relación entidad–relación' -Level 1
Add-Paragraph -Text 'La base inventario_tcc.db contiene dos entidades. productos almacena la identidad y el saldo actual de cada artículo; movimientos mantiene la bitácora de entradas y salidas. Una fila de productos puede relacionarse con cero o varias filas de movimientos. La eliminación del producto elimina sus movimientos asociados mediante ON DELETE CASCADE.'
Add-Paragraph -Text 'Relación: PRODUCTOS (1) -----------< (N) MOVIMIENTOS' -Style 'Normal' -Size '12pt' -Align 'center' -Font 'Consolas' -Color '0F766E' -SpaceBefore '5pt' -SpaceAfter '7pt'
Add-Table -Caption 'Entidades y claves' -Headers @('Entidad', 'Clave primaria', 'Campos relevantes', 'Relación / regla') -Rows @(
  @('productos', 'id', 'nombre, descripcion, categoria, cantidad, precio, fechaIngreso, stockMinimo, codigoSku', 'codigoSku único; cantidad, precio y stockMinimo no negativos.'),
  @('movimientos', 'idMovimiento', 'idProducto, tipo, cantidad, motivo, fecha', 'idProducto referencia productos.id; cascada al eliminar. tipo ? {ENTRADA, SALIDA}; cantidad > 0.')
)
Add-Paragraph -Text 'DDL implementado en DatabaseHelper:' -Style 'Normal' -Size '10pt' -Color '344B50' -SpaceBefore '8pt' -SpaceAfter '3pt'
$ddl = @'
CREATE TABLE productos (
id INTEGER PRIMARY KEY AUTOINCREMENT,
nombre TEXT NOT NULL,
descripcion TEXT NOT NULL DEFAULT '',
categoria TEXT NOT NULL,
cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
precio REAL NOT NULL CHECK (precio >= 0),
fechaIngreso TEXT NOT NULL,
stockMinimo INTEGER NOT NULL DEFAULT 0 CHECK (stockMinimo >= 0),
codigoSku TEXT NOT NULL UNIQUE
);
CREATE TABLE movimientos (
idMovimiento INTEGER PRIMARY KEY AUTOINCREMENT,
idProducto INTEGER NOT NULL,
tipo TEXT NOT NULL CHECK (tipo IN ('ENTRADA', 'SALIDA')),
cantidad INTEGER NOT NULL CHECK (cantidad > 0),
motivo TEXT NOT NULL DEFAULT '',
fecha TEXT NOT NULL,
FOREIGN KEY (idProducto) REFERENCES productos(id) ON DELETE CASCADE
);
CREATE INDEX idx_productos_nombre ON productos(nombre COLLATE NOCASE);
CREATE INDEX idx_productos_categoria ON productos(categoria COLLATE NOCASE);
CREATE INDEX idx_productos_stock ON productos(cantidad, stockMinimo);
CREATE INDEX idx_movimientos_producto_fecha ON movimientos(idProducto, fecha DESC);
CREATE INDEX idx_movimientos_tipo_fecha ON movimientos(tipo, fecha DESC);
'@
Add-Paragraph -Text $ddl.Trim() -Style 'Normal' -Size '8.5pt' -Font 'Consolas' -Color '263238' -SpaceAfter '9pt'
Add-Paragraph -Text 'La apertura configura PRAGMA foreign_keys = ON. El índice de stock apoya la detección de niveles críticos; los índices de movimientos ayudan a recuperar el historial por producto/fecha y tipo/fecha.' -Style 'Normal' -Size '10pt' -Color '52636A'

Add-Heading -Text '6. Pruebas automatizadas y validación Android' -Level 1
Add-Paragraph -Text 'Se ejecutó flutter test en Windows con sqflite_common_ffi, de modo que las pruebas de transacción ejercitan SQLite real sin depender del plugin Android. Resultado final: 6 pruebas aprobadas de 6 ejecutadas (100 %).' 
Add-Table -Caption 'Ejecución unitaria' -Headers @('#', 'Caso cubierto', 'Resultado') -Rows @(
  @('1', 'ProductModel: serialización/restauración de campos y copyWith.', 'APROBADA'),
  @('2', 'MovementModel: ida y vuelta, tipo SALIDA y rechazo de tipo inválido.', 'APROBADA'),
  @('3', 'InventorySummaryModel: valores agregados ausentes se inicializan en cero.', 'APROBADA'),
  @('4', 'SQLite: cuenta de productos, unidades, valorización y stock crítico.', 'APROBADA'),
  @('5', 'Transacciones: entrada/salida; reversión al exceder stock; edición y eliminación revierten saldo.', 'APROBADA'),
  @('6', 'Validación: cantidad cero y producto inexistente producen error y no registran movimientos.', 'APROBADA')
)
Add-Paragraph -Text 'Validación Android: app compilada e instalada mediante flutter run -d emulator-5554 --debug en el emulador sdk gphone16k x86 64 (Android 17 / API 37, 1344 × 2992 px). Se recorrieron Dashboard, catálogo con filtros, formulario, detalle, ambos modos del diálogo e historial. Después de las correcciones de QA no se observaron nuevos errores de Flutter ni cierres inesperados durante esta revisión.'

Add-Heading -Text '7. Evidencias visuales de ejecución' -Level 1
Add-Paragraph -Text 'Las nueve capturas adjuntas corresponden a la ejecución en emulator-5554 (Android 17 / API 37, 1344 × 2992 px). Muestran datos locales de demostración: teclado mecánico, categoría Periféricos, SKU TEC-001 y saldo final de 8 unidades después de la carga inicial y dos movimientos adicionales de prueba. La identidad visible en la interfaz es Inventario.' -Style 'Normal' -Size '10pt' -Color '52636A' -SpaceAfter '9pt'
Add-Heading -Text '7.1 Dashboard y KPIs' -Level 2
Add-Image -Path 'docs/screenshots/dashboard_kpis.png' -Alt 'Dashboard de Inventario con indicadores de productos, unidades, valorización y stock crítico.' -Caption 'Figura 1. Resumen del inventario con KPIs calculados desde SQLite.'
Add-Heading -Text '7.2 Catálogo y chips de categoría' -Level 2
Add-Image -Path 'docs/screenshots/catalogo_chips.png' -Alt 'Catálogo de productos con chips Todas, Periféricos y Stock bajo, y tarjeta del producto de demostración.' -Caption 'Figura 2. Catálogo, filtro por categoría y tarjeta con saldo disponible.'
Add-Heading -Text '7.3 Formulario de nuevo producto' -Level 2
Add-Image -Path 'docs/screenshots/formulario_nuevo_producto.png' -Alt 'Formulario para crear un producto con nombre, descripción, categoría, SKU, cantidad, stock mínimo y precio.' -Caption 'Figura 3. Formulario de alta con campos requeridos y validación de entrada.'
Add-Heading -Text '7.4 Modal de entrada' -Level 2
Add-Image -Path 'docs/screenshots/modal_entrada_salida.png' -Alt 'Diálogo de movimiento con Entrada seleccionada, cantidad, motivo y nuevo stock estimado.' -Caption 'Figura 4. Registro de entrada y cálculo anticipado del nuevo saldo.'
Add-Heading -Text '7.5 Modal de salida' -Level 2
Add-Image -Path 'docs/screenshots/modal_salida.png' -Alt 'Diálogo de movimiento con Salida seleccionada y vista del nuevo stock estimado.' -Caption 'Figura 5. Registro de salida y verificación del saldo resultante.'
Add-Heading -Text '7.6 Historial de movimientos' -Level 2
Add-Image -Path 'docs/screenshots/historial_movimientos.png' -Alt 'Historial con filtros Todas, Entradas y Salidas, balance neto y movimiento inicial.' -Caption 'Figura 6. Historial filtrable con balance del período.'

Add-Heading -Text '7.7 Detalle del producto y transición Hero' -Level 2
Add-Image -Path 'docs/screenshots/detalle_producto_hero.png' -Alt 'Detalle del producto de demostración, su badge y sus datos de existencia; se comparte el elemento Hero con la tarjeta del catálogo.' -Caption 'Figura 7. Detalle con indicador de stock; la transición Hero conecta el icono con la tarjeta de origen.'
Add-Heading -Text '7.8 Confirmación de movimientos con snackbar' -Level 2
Add-Image -Path 'docs/screenshots/snackbar_movimiento.png' -Alt 'Snackbar verde que confirma el registro exitoso de un movimiento de inventario en la app Inventario.' -Caption 'Figura 8. Confirmación inmediata del registro con snackbar contextual.'
Add-Image -Path 'docs/screenshots/snackbar_salida.png' -Alt 'Catálogo con saldo de 8 unidades restaurado y snackbar de confirmación de una salida.' -Caption 'Figura 9. Salida registrada y saldo sincronizado en la tarjeta del catálogo.'

Add-Heading -Text '8. Hallazgos de QA y optimizaciones' -Level 1
Add-Heading -Text 'Incidencias corregidas' -Level 2
Add-Paragraph -Text 'Locale de fechas sin inicializar: el historial construía DateFormat para español antes de registrar los datos locales, produciendo LocaleDataException al abrir la pantalla. Se inicializó el binding de Flutter y initializeDateFormatting("es") antes de runApp en lib/main.dart.'
Add-Paragraph -Text 'Tarjeta del catálogo con altura no acotada: ProductCard usaba Spacer dentro de una Column montada en ListView. La lista no impone una altura finita a cada tarjeta y el flex generaba errores de layout, ocultando el producto. Se sustituyó Spacer por SizedBox(height: 14), que conserva la separación sin requerir espacio flexible.'
Add-Heading -Text 'Rendimiento y límites de la validación' -Level 2
Add-Paragraph -Text 'Durante el primer arranque en modo debug, el emulador reportó cuadros omitidos mientras compilaba y perfilaba la aplicación (186 y luego 72 frames en las fases iniciales de apertura). Tras estabilizarse, las interacciones revisadas no generaron errores repetidos. Esta revisión es funcional y visual; no constituye un benchmark de rendimiento en dispositivo físico ni una medición de producción.'
Add-Paragraph -Text 'La persistencia offline está verificada en el dispositivo y en SQLite de prueba. La sincronización entre dispositivos, el respaldo externo y el control de acceso quedan fuera del alcance de esta entrega y deben diseñarse antes de usar el sistema en un escenario multiusuario.'
Add-Paragraph -Text 'La ejecución de flutter analyze no reportó errores ni advertencias; presentó dos infos de estilo por mantener los literales de enum ENTRADA y SALIDA en mayúsculas, acorde con los valores almacenados y el contrato de datos actual.'

Add-Heading -Text '9. Conclusiones técnicas' -Level 1
Add-Paragraph -Text 'La actividad implementó una aplicación funcional para el control local de productos y movimientos. El uso de SQLite ofrece disponibilidad sin conexión y transacciones que mantienen el saldo y la bitácora consistentes; las restricciones de esquema complementan las validaciones ejecutadas por la aplicación.'
Add-Paragraph -Text 'La separación entre vistas, Provider, repositorio y acceso a datos facilita la evolución de la solución y permitió detectar y corregir fallos de inicialización regional y layout durante QA. Las seis pruebas automatizadas cubren modelos, indicadores y reglas críticas de inventario, y la validación visual confirma la navegación por las pantallas solicitadas.'
Add-Paragraph -Text 'Como siguientes incrementos técnicos se recomienda incorporar pruebas de widgets para formularios y navegación, mediciones de rendimiento en modo release sobre un dispositivo físico, y una estrategia explícita de exportación/respaldo y sincronización si el negocio requiere acceso concurrente desde varios equipos.'
Add-Paragraph -Text 'Resultado de entrega: aplicación Android instalada y revisada en emulador, seis pruebas unitarias aprobadas y evidencia visual incorporada en este informe.' -Style 'Normal' -Size '12pt' -Color '0F766E' -SpaceBefore '12pt' -SpaceAfter '4pt'
Add-Heading -Text 'Artefactos entregados' -Level 2
foreach ($item in @(
  'Informe final: docs/Informe_Final_Actividad_TCC.docx.',
  'Pruebas automatizadas: test/models_and_transactions_test.dart.',
  'Capturas de ejecución (nueve): docs/screenshots/.'
)) { Add-Paragraph -Text $item -ListStyle 'bullet' }

# Numeración APA en encabezado superior derecho, incluida la portada como en el documento de referencia.
$commands.Add(@{ command = 'add'; parent = '/'; type = 'header'; props = @{ type = 'default'; field = 'page'; align = 'right'; size = '12pt'; color = '000000'; font = 'Times New Roman' } })

$json = ConvertTo-Json -InputObject @($commands) -Depth 20 -Compress
[System.IO.File]::WriteAllText($batchPath, $json, [System.Text.UTF8Encoding]::new($false))
officecli batch $file --input $batchPath --stop-on-error
if ($LASTEXITCODE -ne 0) { throw "OfficeCLI batch failed with exit code $LASTEXITCODE" }

# SEQ fields keep APA figure/table labels correctly numbered when content moves.
$sequenceSpecs = @(
  @{ label = 'Tabla'; field = 'Table'; count = $tableNumber },
  @{ label = 'Figura'; field = 'Figure'; count = $images.Count }
)
foreach ($spec in $sequenceSpecs) {
  $labelQuery = officecli query $file "paragraph[text=`"$($spec.label)`"]" --json | ConvertFrom-Json
  if ($labelQuery.data.matches -ne $spec.count) { throw "Expected $($spec.count) paragraphs labeled '$($spec.label)'; found $($labelQuery.data.matches)" }
  for ($i = 1; $i -le $spec.count; $i++) {
    $sourceText = "$($spec.label) $i"
    $labelPath = $labelQuery.data.results[$i - 1].path
    officecli set $file $labelPath --prop "text=$($spec.label) " --prop 'font=Times New Roman' --prop 'size=12pt' --prop 'color=000000' --prop 'bold=true'
    if ($LASTEXITCODE -ne 0) { throw "Could not prepare sequence label '$sourceText'" }
    officecli add $file $labelPath --type field --prop fieldType=seq --prop "id=$($spec.field)" --prop 'font=Times New Roman' --prop 'size=12pt' --prop 'color=000000' --prop 'bold=true'
    if ($LASTEXITCODE -ne 0) { throw "Could not add sequence field '$sourceText'" }
  }
}
officecli set $file / --prop recalcFields=seq
if ($LASTEXITCODE -ne 0) { throw 'Could not recalculate figure and table sequence fields' }

$emptyQuery = officecli query $file 'p:empty' --json | ConvertFrom-Json
$emptyParagraphs = @($emptyQuery.data.results)
if ($emptyParagraphs.Count -ne $images.Count) { throw "Expected $($images.Count) image placeholders; found $($emptyParagraphs.Count) empty paragraphs" }
for ($i = 0; $i -lt $images.Count; $i++) {
  $imagePath = $emptyParagraphs[$i].path
  officecli add $file $imagePath --type picture --prop "src=$($images[$i].src)" --prop 'width=7.5cm' --prop "alt=$($images[$i].alt)"
  if ($LASTEXITCODE -ne 0) { throw "Could not embed image $($images[$i].src)" }
}
officecli close $file
Remove-Item -LiteralPath $batchPath -Force
