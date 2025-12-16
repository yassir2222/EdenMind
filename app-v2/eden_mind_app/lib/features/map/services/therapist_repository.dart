import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:eden_mind_app/features/map/models/therapist.dart';

class TherapistRepository {
  // Nominatim Search API
  // https://nominatim.org/release-docs/develop/api/Search/

  Future<List<Therapist>> searchTherapists(double lat, double lon) async {
    // Try multiple search terms to maximize coverage
    final searchTerms = [
      'psychologue',
      'psychiatre',
      'psychothérapeute',
      'mental health',
      'medecin', // Fallback to doctors if specialised terms fail
    ];

    List<Therapist> allResults = [];
    final double range = 0.2; // roughly 20km
    final String viewbox =
        "${lon - range},${lat + range},${lon + range},${lat - range}";

    // Use a Set to avoid duplicates based on ID
    final Set<String> foundIds = {};

    for (String term in searchTerms) {
      if (allResults.length >= 20) break; // Stop if we have enough result

      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(term)}'
          '&format=json'
          '&viewbox=$viewbox'
          '&bounded=1'
          '&limit=10',
        );

        final response = await http.get(
          uri,
          headers: {'User-Agent': 'EdenMindApp/1.0', 'Accept-Language': 'fr'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          for (var item in data) {
            // Create therapist object
            final therapist = _mapToTherapist(item);

            // Check if we already have this one
            if (!foundIds.contains(therapist.id)) {
              allResults.add(therapist);
              foundIds.add(therapist.id);
            }
          }
        }
      } catch (e) {
        print('Error searching for $term: $e');
      }
    }

    // Sort by distance
    if (allResults.isNotEmpty) {
      final distance = Distance();
      allResults.sort((a, b) {
        final distA = distance.as(
          LengthUnit.Meter,
          LatLng(lat, lon),
          a.location,
        );
        final distB = distance.as(
          LengthUnit.Meter,
          LatLng(lat, lon),
          b.location,
        );
        return distA.compareTo(distB);
      });
    }

    return allResults;
  }

  Therapist _mapToTherapist(Map<String, dynamic> json) {
    // Nominatim returns: lat, lon, display_name, etc.
    // We have to mock some details (image, rating) as Nominatim is just a geocoder.

    final double lat = double.parse(json['lat']);
    final double lon = double.parse(json['lon']);
    final String name =
        (json['name'] != null && json['name'].toString().isNotEmpty)
        ? json['name']
        : "Cabinet de Santé"; // Generic name fallback

    final String address = json['display_name'] ?? "Unknown Address";

    // Randomize some UI elements for the "demo" feel since API doesn't have them
    return Therapist(
      id: json['place_id'].toString(),
      name: name,
      specialty: "Spécialiste", // Generic fallback
      rating:
          4.0 +
          (json['place_id'].toString().length % 5) / 10, // Pseudo-random rating
      reviewCount: 5 + (json['place_id'].toString().length % 30),
      address: address,
      imageUrl:
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300&h=300", // Placeholder
      location: LatLng(lat, lon),
      phoneNumber: "+33 1 23 45 67 89",
      description: "Cabinet situé à ${address.split(',').first}.",
      price: 60,
    );
  }
}
