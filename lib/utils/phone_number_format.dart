String formatPhoneNumber(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.length < 10) {
    return '';
  }
  String areaCode = phoneNumber.substring(0, 3);
  String middlePart = phoneNumber.substring(3, 6);
  String lastPart = phoneNumber.substring(6, 10);

  return '($areaCode) $middlePart-$lastPart';
}
