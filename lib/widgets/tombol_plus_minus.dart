import 'package:flutter/material.dart';

class TombolPlusMinus extends StatelessWidget {
  final VoidCallback addQuantity;
  final VoidCallback deleteQuantity;
  final String text;

  const TombolPlusMinus({
    super.key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol Minus
        InkWell(
          onTap: deleteQuantity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Jumlah teks
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        // Tombol Plus
        InkWell(
          onTap: addQuantity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}