import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import 'auth/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English', 'Español', 'Français', 'Deutsch', 'Italiano', 'Português', 'Русский', '中文', '日本語', 'हिन्दी'
  ];

  final List<String> _currencies = [
    '\$', '€', '£', '₹', '¥', '₽', 'kr'
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final updatedProfile = UserProfile(
        name: provider.userProfile.name,
        email: provider.userProfile.email,
        phone: provider.userProfile.phone,
        isLoggedIn: true,
        profileImagePath: image.path,
      );
      provider.updateUserProfile(updatedProfile);
    }
  }

  void _editProfile() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final nameController = TextEditingController(text: provider.userProfile.name);
    final emailController = TextEditingController(text: provider.userProfile.email);
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProfile = UserProfile(
                name: nameController.text,
                email: emailController.text,
                phone: provider.userProfile.phone,
                isLoggedIn: true,
                profileImagePath: provider.userProfile.profileImagePath,
              );
              provider.updateUserProfile(updatedProfile);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String? path) {
    if (path == null || path.isEmpty || path.contains('icon-236.png') || path.contains('Users.png')) {
      return const AssetImage('web/icons/icon-236.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('web/') || path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              return ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = lang;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final currency = _currencies[index];
              final isSelected = provider.currencySymbol == currency;
              return InkWell(
                onTap: () {
                  provider.setCurrency(currency);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    currency,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.userProfile;
    // final isDark = provider.themeMode == ThemeMode.dark; 
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1), 
                              offset: const Offset(-6, -6),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5), 
                              offset: const Offset(6, 6),
                              blurRadius: 12,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 4,
                          ),
                          image: DecorationImage(
                            image: _getProfileImage(profile.profileImagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Edit Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        offset: const Offset(-3, -3),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _editProfile,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Settings Section
          _buildSectionTitle(context, 'PREFERENCES'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                  title: 'Notifications',
                  trailing: Switch.adaptive(
                    value: _notificationsEnabled,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildSettingsTile(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  onTap: _showLanguageDialog,
                ),
                Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildSettingsTile(
                  context,
                  icon: Icons.attach_money,
                  title: 'Currency',
                  subtitle: provider.currencySymbol,
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  onTap: _showCurrencyDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          _buildSectionTitle(context, 'ACCOUNT'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: _buildSettingsTile(
              context,
              icon: Icons.logout_rounded,
              title: 'Log Out',
              iconColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.error,
              onTap: () {
                provider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)) 
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
