String determineAppBarTitle(String? status, bool serviceFound) {
  if (serviceFound) return "Servicio encontrado";

  switch (status) {
    case 'inactive':
      return 'Inactivo';
    case 'available':
      return 'Esperando servicios...';
    default:
      return 'Cargando...';
  }
}
