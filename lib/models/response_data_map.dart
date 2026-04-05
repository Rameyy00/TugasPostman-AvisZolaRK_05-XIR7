class ResponseDataMap { 
  bool status; 
  String message; 
  Map? data; 
  ResponseDataMap({required this.status, required this.message, this.data}); 

  bool get success => status;
} 