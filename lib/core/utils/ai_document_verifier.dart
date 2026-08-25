class DocumentComparisonField {
  final String fieldName;
  final String formValue;
  final String extractedValue;
  final bool isMatch;
  final double confidence;

  DocumentComparisonField({
    required this.fieldName,
    required this.formValue,
    required this.extractedValue,
    required this.isMatch,
    required this.confidence,
  });
}

class AiVerificationResult {
  final bool isAuthenticSaDocument;
  final bool isAllDetailsMatched;
  final double overallConfidence;
  final String documentType; // "SA Smart ID Card" or "SA Green Barcoded ID Book"
  final List<DocumentComparisonField> comparisonFields;
  final String decision; // "ACCEPTED" or "REJECTED"
  final String message;

  AiVerificationResult({
    required this.isAuthenticSaDocument,
    required this.isAllDetailsMatched,
    required this.overallConfidence,
    required this.documentType,
    required this.comparisonFields,
    required this.decision,
    required this.message,
  });
}

class AiDocumentVerifier {
  /// Simulates Computer Vision & AI OCR cross-comparison between the uploaded SA ID document and form inputs
  static Future<AiVerificationResult> verifyDocument({
    required String formFullName,
    required String formSurname,
    required String formIdNumber,
    required String? formGender,
    required String fileName,
    bool simulateMismatch = false,
  }) async {
    // Artificial AI processing delay for realistic inspection feel
    await Future.delayed(const Duration(milliseconds: 1600));

    final cleanFormId = formIdNumber.trim();
    final cleanFormName = formFullName.trim();
    final cleanFormSurname = formSurname.trim();

    // Check if valid 13-digit SA ID structure
    final is13Digits = RegExp(r'^[0-9]{13}$').hasMatch(cleanFormId);
    if (!is13Digits || simulateMismatch) {
      return AiVerificationResult(
        isAuthenticSaDocument: false,
        isAllDetailsMatched: false,
        overallConfidence: 34.2,
        documentType: 'Unknown / Non-Compliant Document',
        comparisonFields: [
          DocumentComparisonField(
            fieldName: 'National ID Number',
            formValue: cleanFormId,
            extractedValue: simulateMismatch ? '9901015000088' : 'INVALID_FORMAT',
            isMatch: false,
            confidence: 32.0,
          ),
          DocumentComparisonField(
            fieldName: 'Full Name',
            formValue: cleanFormName,
            extractedValue: cleanFormName,
            isMatch: true,
            confidence: 90.0,
          ),
        ],
        decision: 'REJECTED',
        message: 'AI Document Inspector could not verify the authenticity of the South African ID document or detected a checksum discrepancy.',
      );
    }

    // Extracted Values from Authentic SA Document
    final extractedName = cleanFormName.toUpperCase();
    final extractedSurname = cleanFormSurname.toUpperCase();
    final extractedId = cleanFormId;
    final extractedGender = (formGender ?? 'Male').toUpperCase();

    final fields = [
      DocumentComparisonField(
        fieldName: 'Full Name(s)',
        formValue: cleanFormName,
        extractedValue: extractedName,
        isMatch: true,
        confidence: 99.4,
      ),
      DocumentComparisonField(
        fieldName: 'Surname',
        formValue: cleanFormSurname,
        extractedValue: extractedSurname,
        isMatch: true,
        confidence: 99.8,
      ),
      DocumentComparisonField(
        fieldName: '13-Digit SA National ID',
        formValue: cleanFormId,
        extractedValue: extractedId,
        isMatch: true,
        confidence: 100.0,
      ),
      DocumentComparisonField(
        fieldName: 'Gender & Demographics',
        formValue: formGender ?? 'Auto-detected',
        extractedValue: extractedGender,
        isMatch: true,
        confidence: 98.6,
      ),
      DocumentComparisonField(
        fieldName: 'Republic of South Africa Security Markers',
        formValue: 'Verified',
        extractedValue: 'Coat of Arms & Watermark Validated',
        isMatch: true,
        confidence: 99.1,
      ),
    ];

    return AiVerificationResult(
      isAuthenticSaDocument: true,
      isAllDetailsMatched: true,
      overallConfidence: 99.4,
      documentType: 'Republic of South Africa Smart ID Card / Green Barcode Book',
      comparisonFields: fields,
      decision: 'ACCEPTED',
      message: 'AI Model successfully verified the document against Republic of South Africa standards. 100% field match with applicant inputs.',
    );
  }
}
