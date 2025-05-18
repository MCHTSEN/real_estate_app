import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:real_estate_app/core/extensions/string_extensions.dart';
import 'package:real_estate_app/core/theme/custom_colors.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';
import 'package:intl/intl.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: SizedBox(
        height: 360,
        child: Stack(
          children: [
            _buildImageSection(),
            _buildInfoSection(context),
            _buildTypeLabel(),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'tr_TR');
    return formatter.format(price);
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: listing.imageUrls.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: listing.imageUrls[0],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
            )
          : Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.home,
                size: 50,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Positioned(
      top: 165,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildTitleAndLocationRow(),
            _buildPriceAndActionRow(),
            _buildDetailRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndActionRow() {
    return Text(
      listing.price.toString().formattedPrice,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 26,
        color: CustomColors.primary,
      ),
    );
  }

  Widget _buildTitleAndLocationRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.villa_outlined,
            size: 30,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${listing.location}, ${listing.neighborhood}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
        ),
        const Spacer(),
        Container(
          decoration: const BoxDecoration(
            color: CustomColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_outward_sharp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow() {
    return Row(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildDetailItem(
          icon: Icons.square_foot,
          text: '${listing.squareMeters} m²',
        ),
        _buildDetailItem(
          icon: Icons.bed_outlined,
          text: '${listing.roomCount} oda',
        ),
        _buildDetailItem(
          icon: listing.type == 'sell' ? Icons.sell_outlined : Icons.timelapse,
          text: listing.type == 'sell' ? 'Satılık' : 'Kiralık',
        ),
      ],
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[800],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeLabel() {
    return Positioned(
      left: 15,
      top: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
          ),
          child: Text(
            listing.type == 'sell' ? 'Satılık' : 'Kiralık',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
