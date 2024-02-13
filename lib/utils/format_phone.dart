String formatPhone(String phone) {
  if (phone.isEmpty) return '';

  String areaCode = phone.substring(0, 3);
  String middlePart = phone.substring(3, 6);
  String lastPart = phone.substring(6, 10);

  return '($areaCode) $middlePart-$lastPart';
}
