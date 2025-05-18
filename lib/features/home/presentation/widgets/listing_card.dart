import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          SizedBox(
            height: 180,
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
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '${listing.price.toString()} TL',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // Type label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: listing.type == 'sell'
                            ? Colors.blue[100]
                            : Colors.green[100],
                      ),
                      child: Text(
                        listing.type == 'sell' ? 'Satılık' : 'Kiralık',
                        style: TextStyle(
                          color: listing.type == 'sell'
                              ? Colors.blue[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.location}, ${listing.neighborhood}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Property features
                Row(
                  children: [
                    Icon(
                      Icons.square_foot,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.squareMeters} m²',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.roomCount} oda',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
