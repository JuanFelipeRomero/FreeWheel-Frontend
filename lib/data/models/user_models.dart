// User registration model
class UserRegistration {
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String password;
  final String organizacionCodigo;

  UserRegistration({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.password,
    required this.organizacionCodigo,
  });

  // Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'password': password,
      'organizacionCodigo': organizacionCodigo,
    };
  }
}

// User registration response
class UserRegistrationResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? userData;

  UserRegistrationResponse({
    required this.success,
    this.message,
    this.userData,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      success: json['success'] ?? true,
      message: json['message'],
      userData: json['data'],
    );
  }

  factory UserRegistrationResponse.error(String errorMessage) {
    return UserRegistrationResponse(success: false, message: errorMessage);
  }
}
