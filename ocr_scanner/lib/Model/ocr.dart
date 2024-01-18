class OcrModel {
  final String document_id;
  final String extractdata;

  OcrModel({required this.document_id, required this.extractdata});

  factory OcrModel.fromJson(Map<String, dynamic> json) => OcrModel(
      document_id: json['document_id'], extractdata: json['extractdata']);

  Map<String, dynamic> toJson() => {
        'documentId': document_id,
        'extractdata': extractdata,
      };
}
