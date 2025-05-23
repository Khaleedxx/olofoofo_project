/// Utility class for form validation
class Validators {
  /// Validates email format
  static String? validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates username
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    } else if (username.length < 3) {
      return 'Username must be at least 3 characters';
    } else if (username.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    return null;
  }

  /// Validates full name
  static String? validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Full name is required';
    } else if (fullName.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  /// Validates first or last name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    } else if (name.length < 2) {
      return 'Name must be at least 2 characters';
    } else if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and periods';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (phone.isEmpty) {
      return 'Phone number is required';
    } else if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates OTP code
  static String? validateOtp(String otp) {
    if (otp.isEmpty) {
      return 'OTP is required';
    } else if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return 'Enter a valid 6-digit OTP';
    }
    return null;
  }

  /// Validates URL
  static String? validateUrl(String url) {
    if (url.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(url)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  /// Validates date of birth
  static String? validateDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return null; // Date of birth is optional
    }

    final now = DateTime.now();
    final age = now.year -
        dateOfBirth.year -
        (now.month > dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day >= dateOfBirth.day)
            ? 0
            : 1);

    if (age < 13) {
      return 'You must be at least 13 years old';
    } else if (age > 120) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }
}
