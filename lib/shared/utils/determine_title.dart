String determineAppBarTitle(
    String? status, bool serviceFound, bool serviceAccepted, int timeLeft) {
  if (serviceFound && timeLeft > 0) return "Servicio encontrado";
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
