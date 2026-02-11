// models/response_data_list.dart
class ResponseDataList<T> {
  bool success;
  String message;
  List<T> data;

  ResponseDataList({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ResponseDataList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ResponseDataList<T>(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<T>.from(
              json['data'].map((item) => fromJsonT(item)),
            )
          : [],
    );
  }
}
