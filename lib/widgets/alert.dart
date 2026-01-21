import 'package:flutter/material.dart';

class AlertMessage {
  showAlert(BuildContext context, String message, bool status) {
    // Definisi Warna & Ikon berdasarkan status
    final Color backgroundColor = status 
        ? const Color(0xFFE8F5E9) // Hijau muda (Sukses)
        : const Color(0xFFFFEBEE); // Merah muda (Gagal)
    
    final Color accentColor = status 
        ? const Color(0xFF2E7D32) // Hijau tua
        : const Color(0xFFC62828); // Merah tua

    final IconData iconData = status 
        ? Icons.check_circle_outline_rounded 
        : Icons.error_outline_rounded;

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent, // Transparan karena kita pakai Container
      elevation: 0,
      behavior: SnackBarBehavior.floating, // Membuat SnackBar melayang
      margin: const EdgeInsets.all(15),    // Jarak dari pinggir layar
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: accentColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status ? "Success" : "Error",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: Icon(Icons.close, color: accentColor.withOpacity(0.6), size: 20),
              constraints: const BoxConstraints(), // Menghilangkan padding default
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );

    // Hapus SnackBar yang sedang tampil (jika ada) sebelum menampilkan yang baru
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}