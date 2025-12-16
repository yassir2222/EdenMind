import 'package:latlong2/latlong.dart';

class Therapist {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final LatLng location;
  final String address;
  final String phoneNumber;
  final String description;
  final double price;
  final bool isAvailable;

  Therapist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.address,
    required this.phoneNumber,
    this.description = '',
    this.price = 0.0,
    this.isAvailable = true,
  });
}

// Mock Data
final List<Therapist> mockTherapists = [
  Therapist(
    id: '1',
    name: 'Dr. Sarah Smith',
    specialty: 'Clinical Psychologist',
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah+Smith',
    rating: 4.9,
    reviewCount: 124,
    location: const LatLng(51.509865, -0.118092), // Near London Eye
    address: '123 Wellness Way, London',
    phoneNumber: '+44 20 7946 0123',
  ),
  Therapist(
    id: '2',
    name: 'Dr. John Doe',
    specialty: 'Cognitive Behavioral Therapist',
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=John+Doe',
    rating: 4.8,
    reviewCount: 98,
    location: const LatLng(51.503399, -0.119519), // Near Westminster Bridge
    address: '45 Mindful St, London',
    phoneNumber: '+44 20 7946 0456',
  ),
  Therapist(
    id: '3',
    name: 'Emily Davis',
    specialty: 'Marriage & Family Therapist',
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Emily+Davis',
    rating: 4.7,
    reviewCount: 56,
    location: const LatLng(51.5145, -0.1426), // Near Oxford Circus
    address: '78 Serenity Lane, London',
    phoneNumber: '+44 20 7946 0789',
  ),
  Therapist(
    id: '4',
    name: 'Michael Brown',
    specialty: 'Pastoral Counselor',
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Michael+Brown',
    rating: 4.9,
    reviewCount: 210,
    location: const LatLng(51.4995, -0.1248), // Near Big Ben
    address: '10 Peace Place, London',
    phoneNumber: '+44 20 7946 0999',
  ),
  Therapist(
    id: '5',
    name: 'Dr. Lisa Wilson',
    specialty: 'Child Psychologist',
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Lisa+Wilson',
    rating: 5.0,
    reviewCount: 67,
    location: const LatLng(51.5074, -0.1278), // Central London
    address: '22 Happy Ave, London',
    phoneNumber: '+44 20 7946 0222',
  ),
];
