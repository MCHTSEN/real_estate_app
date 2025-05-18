import 'package:intl/intl.dart';

extension StringExtensions on String {
  String get formattedPrice {
    return '${_formatPrice(int.parse(this))}₺';
  }
}

String _formatPrice(int price) {
  final formatter = NumberFormat('#,###', 'tr_TR');
  return formatter.format(price);
}