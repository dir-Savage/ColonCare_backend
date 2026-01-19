import 'package:coloncare/core/di/injector.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/auth/domain/entities/user_en.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:coloncare/features/health_check/presentation/widgets/health_check_settings_widget.dart';
import 'package:coloncare/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:coloncare/features/profile/presentation/pages/questions_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: const Icon(Icons.person_3_outlined),
        ),
        body: const _ProfilePageContent(),
      ),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ProfileError && state.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(const ProfileLoadRequested());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final user = state.user;
        if (user == null) {
          return const Center(
            child: Text('No user data available'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(const ProfileLoadRequested());
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
                  child: _buildDoctorInfoSection(context, user),
                ),
                const SizedBox(height: 24),

                FadeInAnimation(
                  duration: const Duration(milliseconds: 300),
                  child: _buildHealthCheckSettings(context, user),
                ),
                const SizedBox(height: 24),
                FadeInAnimation(
                  duration: const Duration(milliseconds: 400),
                  child: _buildAccountInfoSection(context, user),
                ),
                const SizedBox(height: 24),
                Container(
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
                          "Logging out , you may miss some important health notifications.",
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
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
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
            onCopy: () => _copyToClipboard(context, user.fullName, 'Full Name'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Email Address',
            value: user.email,
            icon: Icons.email,
            onCopy: () => _copyToClipboard(context, user.email, 'Email Address'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'User ID',
            value: user.uid,
            icon: Icons.fingerprint,
            onCopy: () => _copyToClipboard(context, user.uid, 'User ID'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoSection(BuildContext context, User user) {
    final hasDoctorPhone = user.doctorPhoneNumber != null &&
        user.doctorPhoneNumber!.isNotEmpty;

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
          if (!hasDoctorPhone)
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow.shade800, Colors.yellow.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.warning, size: 20, color: Colors.white),
                    label: const Text(
                      'Add Doctor Phone Number',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _showAddDoctorPhoneDialog(context, user),
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
                  value: user.doctorPhoneNumber!,
                  icon: Icons.phone,
                  color: Colors.green,
                  onCopy: () => _copyToClipboard(context, user.doctorPhoneNumber!, 'Doctor Phone Number'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Phone Number'),
                        onPressed: () => _showEditDoctorPhoneDialog(context, user),
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
                        ),
                        onPressed: () => _callDoctor(context, user.doctorPhoneNumber!),
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

  Widget _buildHealthCheckSettings(BuildContext context, User user) {
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
              const Icon(Icons.health_and_safety, color: Colors.teal),
              const SizedBox(width: 10),
              const Text(
                'Health Check Settings',
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuestionsSettingsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.healing_outlined, color: Colors.white, size: 20),
                ),
                label: const Text(
                  'Configure Health Check Questions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// UPDATE the profile page to include an edit button
// In _buildAccountInfoSection method, add:

  Widget _buildAccountInfoSection(BuildContext context, User user) {
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
          ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(context, user),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile Information'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
          IconButton(
            icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade400),
            onPressed: onCopy,
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddDoctorPhoneDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => _DoctorPhoneDialog(
        title: 'Add Doctor Phone Number',
        initialPhone: '',
        onSave: (phone) {
          context.read<ProfileBloc>().add(ProfileUpdateDoctorPhoneRequested(phone));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditDoctorPhoneDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => _DoctorPhoneDialog(
        title: 'Edit Doctor Phone Number',
        initialPhone: user.doctorPhoneNumber ?? '',
        onSave: (phone) {
          context.read<ProfileBloc>().add(ProfileUpdateDoctorPhoneRequested(phone));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(
        user: user,
        onSave: (fullName, email, doctorPhone) {
          // This should trigger the bloc event
          context.read<ProfileBloc>().add(ProfileUpdateRequested(
            fullName: fullName,
            email: email,
            doctorPhoneNumber: doctorPhone,
          ));
        },
      ),
    );
  }

  Future<void> _callDoctor(BuildContext context, String phoneNumber) async {
    // Clean the phone number
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it's a valid phone number
    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the phone URL
    final url = Uri.parse('tel:$cleanedNumber');

    // Show confirmation dialog
    final shouldCall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Doctor'),
        content: Text('Do you want to call $phoneNumber?'),
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
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not launch phone app'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to make call: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _DoctorPhoneDialog extends StatefulWidget {
  final String title;
  final String initialPhone;
  final Function(String) onSave;

  const _DoctorPhoneDialog({
    required this.title,
    required this.initialPhone,
    required this.onSave,
  });

  @override
  State<_DoctorPhoneDialog> createState() => _DoctorPhoneDialogState();
}

class _DoctorPhoneDialogState extends State<_DoctorPhoneDialog> {
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone validation
    final cleaned = value.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10) {
      return 'Please enter a valid phone number (at least 10 digits)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Doctor Phone Number',
                hintText: '+1 (555) 123-4567',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 8),
            const Text(
              'Example: +1 (555) 123-4567 or 5551234567',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_phoneController.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}


// ADD THIS TO features/profile/presentation/pages/profile_page.dart
// (Add this class at the end of the file)

class _EditProfileDialog extends StatefulWidget {
  final User user;
  final Function(String?, String?, String?) onSave;

  const _EditProfileDialog({
    required this.user,
    required this.onSave,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _doctorPhoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _doctorPhoneController = TextEditingController(text: widget.user.doctorPhoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final cleaned = value.trim().replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.length < 10) {
        return 'Please enter a valid phone number (at least 10 digits)';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Phone Number',
                  hintText: '+1 (555) 123-4567',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 8),
              const Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _nameController.text.trim(),
                _emailController.text.trim(),
                _doctorPhoneController.text.trim().isEmpty ? null : _doctorPhoneController.text.trim(),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}