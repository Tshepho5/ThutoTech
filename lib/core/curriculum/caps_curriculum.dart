class CapsCurriculum {
  static const List<String> officialLanguages = [
    'English',
    'Sepedi (Sesotho sa Leboa)',
    'isiZulu',
    'isiXhosa',
    'Afrikaans',
    'Setswana',
    'Sesotho',
    'Xitsonga',
    'siSwati',
    'Tshivenda',
    'isiNdebele',
  ];

  static const List<String> fetStreams = [
    'Science Stream (STEM)',
    'Commerce Stream (Business & Accounting)',
    'Tourism & Hospitality Stream',
  ];

  /// Returns compulsory CAPS subjects for Senior Phase (Grade 8 & 9)
  static List<String> getSeniorPhaseSubjects(String homeLanguage, String fal) {
    return [
      '$homeLanguage (Home Language)',
      '$fal (First Additional Language)',
      'Mathematics',
      'Natural Sciences',
      'Social Sciences (History & Geography)',
      'Technology',
      'Economic and Management Sciences (EMS)',
      'Life Orientation',
      'Creative Arts',
    ];
  }

  /// Returns compulsory CAPS subjects for FET Phase (Grade 10, 11, 12) based on selected stream
  static List<String> getFetPhaseSubjects({
    required String homeLanguage,
    required String fal,
    required String stream,
    String? elective,
  }) {
    final base = [
      '$homeLanguage (Home Language)',
      '$fal (First Additional Language)',
      'Life Orientation',
    ];

    if (stream.contains('Science')) {
      return [
        ...base,
        'Mathematics (Pure)',
        'Physical Sciences',
        'Life Sciences (Biology)',
        elective ?? 'Geography / Information Technology',
      ];
    } else if (stream.contains('Commerce')) {
      return [
        ...base,
        'Accounting',
        'Business Studies',
        'Economics',
        'Mathematical Literacy / Pure Mathematics',
      ];
    } else {
      // Tourism & Services
      return [
        ...base,
        'Tourism Studies',
        'Hospitality / Consumer Studies',
        'Business Studies',
        'Mathematical Literacy',
      ];
    }
  }
}
