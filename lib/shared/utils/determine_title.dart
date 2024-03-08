String determineAppBarTitle(
    String? status, bool serviceFound, bool serviceAccepted) {
  if (serviceFound) return "Servicio encontrado";
  if (serviceAccepted) return "En camino...";

  switch (status) {
    case 'inactive':
      return 'Inactivo';
    case 'available':
      return 'Esperando servicios...';
    default:
      return 'Cargando...';
  }
}
