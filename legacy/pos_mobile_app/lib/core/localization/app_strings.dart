/// Textos centralizados de la aplicacion en Espanol para Panaderia y Cafeteria Artesanal.
class AppStrings {
  // General & App Name
  static const appTitle = 'Panaderia Artesanal POS';
  static const bakeryName = 'Panaderia & Horno Artesanal';
  static const branchDowntown = 'Sucursal Centro (Horno Principal)';
  static const terminalReg01 = 'Terminal Caja 01';

  // Roles
  static const roleCashier = 'Cajero/a';
  static const roleBaker = 'Maestro/a Panadero/a';
  static const roleManager = 'Gerente de Sucursal';
  static const roleAdmin = 'Administrador General';

  // Login & Turnos
  static const selectStaff = 'Seleccionar Personal';
  static const morningRegister = 'Caja Turno Matutino';
  static const deckOvenShift = 'Horno de Piso y Produccion';
  static const storeManagement = 'Administracion y Cierres';
  static const enterPinPrompt = 'Ingresa tu PIN de 4 digitos';
  static const verifyingPin = 'Verificando PIN...';
  static const pinIncorrect = 'PIN incorrecto. Intenta con 1234';
  static const staffLogin = 'Acceso de Personal';
  static const keyboardSupported = 'Soporte de teclado numerico fisico y tactil';

  // Navegacion & Acciones
  static const logOut = 'Cerrar Sesion';
  static const confirmLogout = 'Confirmar Cierre de Sesion';
  static const logoutPrompt = 'Seguro que deseas cerrar tu sesion actual y volver al acceso con PIN?';
  static const itemsStaySafe = 'Los articulos del carrito permaneceran guardados de forma segura en la caja.';
  static const cancel = 'Cancelar';
  static const accept = 'Aceptar';
  static const close = 'Cerrar';
  static const save = 'Guardar';
  static const delete = 'Eliminar';
  static const clear = 'Limpiar';

  // POS / Caja Principal
  static const orderNumber = 'Orden #';
  static const takeout = 'Para Llevar';
  static const dineIn = 'Comedor / Mesa';
  static const searchPlaceholder = 'Buscar por nombre o codigo SKU...';
  static const allCategories = 'Todos';
  static const catBreads = 'Panes';
  static const catViennoiserie = 'Bolleria y Hojaldres';
  static const catCakes = 'Pasteleria y Tartas';
  static const catBeverages = 'Bebidas y Cafe';

  // Carrito & Ticket
  static const currentOrder = 'Ticket Actual';
  static const emptyCartTitle = 'Ticket Vacio';
  static const emptyCartSubtitle = 'Toca cualquier producto del catalogo para agregarlo a la orden.';
  static const subtotal = 'Subtotal';
  static const taxVat = 'IVA (8%)';
  static const discount = 'Descuento';
  static const total = 'Total';
  static const applyDiscount = 'Aplicar Descuento';
  static const discountCode = 'Codigo o % de Descuento';

  // Ordenes en Espera (Held / Parked Tickets)
  static const holdOrder = 'Pausar Orden';
  static const heldOrders = 'Ordenes en Espera';
  static const noHeldOrders = 'No hay ordenes en espera.';
  static const holdOrderPrompt = 'Ingresa una referencia para pausar esta orden (ej. Cliente con prisa, Mesa 2):';
  static const referenceName = 'Nombre / Referencia de la orden';
  static const resumeOrder = 'Recuperar Orden';
  static const orderParkedSuccess = 'Orden guardada en espera correctamente.';
  static const orderResumedSuccess = 'Orden recuperada en el ticket de venta.';

  // Cobro & Pagos
  static const payment = 'Cobro';
  static const exactCash = 'Exacto';
  static const tenderCash = 'Cobrar en Efectivo';
  static const cashReceived = 'Efectivo Recibido';
  static const changeDue = 'Cambio a Devolver';
  static const saleCompleted = 'Venta Realizada con Exito!';
  static const newSale = 'Nueva Venta';
  static const printReceipt = 'Imprimir Ticket';
  static const digitalReceipt = 'Recibo Digital';
  static const shareReceipt = 'Compartir Ticket';
  static const thanksForVisiting = 'Gracias por su preferencia!';

  // Panaderia / Cocina
  static const bakerConsoleTitle = 'Consola de Produccion y Hornadas';
  static const selectProductToBake = 'Selecciona el producto a hornear';
  static const batchUnits = 'Unidades por Hornada';
  static const halfTray = 'Media Charola (6)';
  static const fullTray = 'Charola Completa (12)';
  static const doubleTray = 'Doble Charola (24)';
  static const fullOven = 'Horno Completo (48)';
  static const recordBatch = 'Confirmar Entrada a Vitrina';
  static const batchRecordedSuccess = 'Hornada registrada en inventario correctamente';
  static const bakerNotes = 'Notas del Panadero (Opcional)';

  // Arqueo & Cierre de Caja (Gerente)
  static const reconciliationTitle = 'Arqueo y Cierre de Caja';
  static const openingFloat = 'Fondo de Caja Inicial';
  static const expectedCash = 'Ventas Esperadas en Efectivo';
  static const expectedCard = 'Ventas Esperadas con Tarjeta';
  static const drawerCount = 'Conteo Fisico en Caja';
  static const cashVariance = 'Diferencia / Variacion';
  static const balancedDrawer = 'Caja Cuadrada';
  static const drawerSurplus = 'Sobrante en Caja';
  static const drawerDeficit = 'Faltante en Caja';
  static const lockAndCloseDrawer = 'Cerrar Turno e Imprimir Corte Z';
  static const printZReport = 'Imprimir Reporte Z';

  // Responsive / Dispositivos
  static const viewCart = 'Ver Ticket';
  static const backToCatalog = 'Volver al Catalogo';
}
