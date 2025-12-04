import 'package:flutter/material.dart';
import 'package:mobile/features/profile/widgets/profile_info_card.dart';
import '../../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _authService.getProfile();
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _profileData == null
              ? Center(child: Text('Error loading profile'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromARGB(255, 235, 255, 229),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Username
                      Text(
                        _profileData!['username'] ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile Info Cards
                      ProfileInfoCard(field: 'Name', value: '${_profileData!['name'] ?? '-'} ${_profileData!['surname'] ?? '-'}'),
                      const SizedBox(height: 12),

                      ProfileInfoCard(field: 'Email', value: _profileData!['email'] ?? '-'),
                      const SizedBox(height: 12),
                      
                      ProfileInfoCard(field: 'Age', value: '${_profileData!['age'] ?? '-'} years'),
                      const SizedBox(height: 12),

                      ProfileInfoCard(field: 'Weight', value: '${_profileData!['weight'] ?? '-'} kg'),
                      const SizedBox(height: 12),
                      
                      ProfileInfoCard(field: 'Height', value: '${_profileData!['height'] ?? '-'} m'),
                    ],
                  ),
                ),
    );
  }
}