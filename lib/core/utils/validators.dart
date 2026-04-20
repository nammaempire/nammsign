class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number is required';
    if (value.length != 10)            return 'Enter a valid 10-digit number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6)             return 'Enter the 6-digit OTP';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? aadhar(String? value) {
    if (value == null || value.isEmpty) return 'Aadhar number is required';
    final clean = value.replaceAll(' ', '').replaceAll('-', '');
    if (clean.length != 12)            return 'Aadhar must be 12 digits';
    if (!RegExp(r'^\d{12}$').hasMatch(clean)) return 'Enter a valid Aadhar number';
    return null;
  }

  static String? gst(String? value) {
    if (value == null || value.isEmpty) return 'GST number is required';
    final pattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!pattern.hasMatch(value.toUpperCase())) {
      return 'Enter a valid 15-digit GST number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
