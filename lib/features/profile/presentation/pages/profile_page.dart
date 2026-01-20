// FILE: lib/features/profile/presentation/pages/profile_page.dart
import 'dart:io';
import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/navigation/app_router.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/core/utils/doctor_phone_helper.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:coloncare/features/health_check/presentation/widgets/health_check_settings_widget.dart';
import 'package:coloncare/features/profile/presentation/widgets/doctor_phone_dialog.dart';
import 'package:coloncare/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _doctorPhoneNumber;
  bool _isLoadingPhone = false;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDoctorPhone();
  }

  Future<void> _loadDoctorPhone() async {
    print('🔍 Loading doctor phone number...');
    setState(() => _isLoadingPhone = true);

    try {
      _doctorPhoneNumber = await DoctorPhoneHelper.getDoctorPhoneNumber();
      print('📱 Loaded doctor phone: $_doctorPhoneNumber');
    } catch (e) {
      print('❌ Error loading doctor phone: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPhone = false);
      }
    }
  }

  Future<void> _saveDoctorPhone(String phone) async {
    print('💾 Saving doctor phone: $phone');
    setState(() => _isLoadingPhone = true);

    try {
      final saved = await DoctorPhoneHelper.saveDoctorPhone(phone);
      if (saved) {
        setState(() {
          _doctorPhoneNumber = phone;
        });
        print('✅ Doctor phone saved successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor phone number saved!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error saving doctor phone: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPhone = false);
      }
    }
  }

  Future<void> _showAddEditDoctorPhoneDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => DoctorPhoneDialog(
        initialPhone: _doctorPhoneNumber,
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _saveDoctorPhone(result);
    }
  }

  Future<void> _callDoctor() async {
    if (_doctorPhoneNumber == null || _doctorPhoneNumber!.isEmpty) {
      await _showAddEditDoctorPhoneDialog();
      return;
    }

    final phone = _doctorPhoneNumber!;
    final sanitizedNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneUrl = Uri.parse('tel:$sanitizedNumber');

    final shouldCall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Doctor'),
        content: Text('Do you want to call $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Call'),
          ),
        ],
      ),
    );

    if (shouldCall == true) {
      try {
        if (await canLaunchUrl(phoneUrl)) {
          await launchUrl(phoneUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! Authenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Please log in to view profile',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.login,
                          (route) => false,
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
        }

        _currentUser = state.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: const Icon(Icons.person_3_outlined),
          ),
          body: _buildProfileContent(context, state.user),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadDoctorPhone();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            FadeInAnimation(
              child: _buildProfileHeader(context, user),
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            FadeInAnimation(
              duration: const Duration(milliseconds: 100),
              child: _buildPersonalInfoSection(context, user),
            ),
            const SizedBox(height: 24),

            // Doctor Information Section
            FadeInAnimation(
              duration: const Duration(milliseconds: 200),
              child: _buildDoctorInfoSection(context),
            ),
            const SizedBox(height: 24),

            // Health Check Settings Section
            FadeInAnimation(
              duration: const Duration(milliseconds: 300),
              child: _buildHealthCheckSettings(context),
            ),
            const SizedBox(height: 24),

            // Account Info Section
            FadeInAnimation(
              duration: const Duration(milliseconds: 400),
              child: _buildAccountInfoSection(context),
            ),
            const SizedBox(height: 24),

            // Logout Warning Section
            _buildLogoutWarning(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blueAccent.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: SvgPicture.network(
                  user.avatarUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Patient',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Full Name',
            value: user.fullName,
            icon: Icons.person,
            onCopy: () => _copyToClipboard(user.fullName, 'Full Name'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Email Address',
            value: user.email,
            icon: Icons.email,
            onCopy: () => _copyToClipboard(user.email, 'Email Address'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'User ID',
            value: user.uid,
            icon: Icons.fingerprint,
            onCopy: () => _copyToClipboard(user.uid, 'User ID'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoSection(BuildContext context) {
    final hasPhone = _doctorPhoneNumber != null && _doctorPhoneNumber!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: Colors.yellow.shade700),
              const SizedBox(width: 10),
              const Text(
                'Doctor Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingPhone)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (!hasPhone)
            Column(
              children: [
                const Text(
                  'No doctor phone number added yet.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Doctor Phone Number'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showAddEditDoctorPhoneDialog,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  label: 'Doctor Phone Number',
                  value: _doctorPhoneNumber!,
                  icon: Icons.phone,
                  color: Colors.green,
                  onCopy: () => _copyToClipboard(_doctorPhoneNumber!, 'Doctor Phone Number'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Phone'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _showAddEditDoctorPhoneDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call Doctor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _callDoctor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHealthCheckSettings(BuildContext context) {

    return SizedBox(height: 0,);
    // return Container(
    //   padding: const EdgeInsets.all(20),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(16),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.05),
    //         blurRadius: 10,
    //         offset: const Offset(0, 4),
    //       ),
    //     ],
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         children: [
    //           const Icon(Icons.health_and_safety, color: Colors.teal),
    //           const SizedBox(width: 10),
    //           const Text(
    //             'Health Check Settings',
    //             style: TextStyle(
    //               fontSize: 18,
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 16),
    //       SizedBox(
    //         width: double.infinity,
    //         child: ElevatedButton.icon(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => Scaffold(
    //                   appBar: AppBar(title: Text('Health Check Settings')),
    //                   body: HealthCheckSettingsWidget(),
    //                 ),
    //               ),
    //             );
    //           },
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: Colors.teal,
    //             foregroundColor: Colors.white,
    //             padding: const EdgeInsets.symmetric(vertical: 12),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(12),
    //             ),
    //           ),
    //           icon: const Icon(Icons.settings),
    //           label: const Text('Configure Health Check Questions'),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildAccountInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile Information'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Logging out may cause you to miss important health notifications.",
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color color = Colors.blue,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade400),
              onPressed: onCopy,
              tooltip: 'Copy to clipboard',
            ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: _currentUser,
        onSave: (fullName, email, doctorPhone) {
          // Note: Profile update logic would go here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile update functionality would be implemented here'),
              backgroundColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}