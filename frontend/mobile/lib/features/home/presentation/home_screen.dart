import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/reminders');
        break;
      case 2:
        context.push('/documents');
        break;
      case 3:
        context.push('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: SahaayiColors.secondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: SahaayiColors.primary.withAlpha(80), width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.handshake_outlined,
                      color: SahaayiColors.primaryDark, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'സഹായി',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ക്രമീകരണങ്ങൾ (Settings)',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: SahaayiColors.border),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: SahaayiColors.textMain, size: 22),
            ),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: SahaayiColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: SahaayiColors.primary, width: 2),
              ),
              padding: const EdgeInsets.all(2),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: SahaayiColors.secondary,
                child: Icon(Icons.person,
                    color: SahaayiColors.primaryDark, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Warm Elderly Greeting Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: SahaayiColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: SahaayiColors.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            color: SahaayiColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'നമസ്കാരം!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.textMain,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ഇന്ന് സഹായി എന്തു ചെയ്യണം?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: SahaayiColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Upcoming Medication Reminder Card (High Priority for Senior Citizens)
              AccessibleCard(
                backgroundColor: SahaayiColors.card,
                padding: const EdgeInsets.all(18),
                onTap: () => context.push('/reminders'),
                border:
                    const BorderSide(color: SahaayiColors.primary, width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: SahaayiColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.alarm_on_rounded,
                            color: SahaayiColors.primaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'അടുത്ത മരുന്ന് ഓർമ്മപ്പെടുത്തൽ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: SahaayiColors.textMain,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SahaayiColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ഉച്ചയ്ക്ക് 2:00 PM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: SahaayiColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SahaayiColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.medication_liquid_rounded,
                              color: SahaayiColors.primary, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'പാരസെറ്റമോൾ 500mg',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.textMain,
                                  ),
                                ),
                                Text(
                                  'ഭക്ഷണത്തിന് ശേഷം 1 ഗുളിക',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: SahaayiColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Quick SOS / Emergency Strip
              GestureDetector(
                onTap: () => context.push('/emergency'),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: SahaayiColors.rose,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: SahaayiColors.emergency.withAlpha(120),
                        width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.emergency_rounded,
                          color: SahaayiColors.emergency, size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'അടിയന്തിര സഹായം (Emergency SOS)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: SahaayiColors.emergency,
                              ),
                            ),
                            Text(
                              'സഹായത്തിനായി ഇവിടെ സ്പർശിക്കുക',
                              style: TextStyle(
                                  fontSize: 14, color: SahaayiColors.textMain),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: SahaayiColors.emergency),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Main Service Grid (Large Elderly-Friendly Touch Targets)
              const Text(
                'പ്രധാന സേവനങ്ങൾ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SahaayiColors.textMain,
                ),
              ),
              const SizedBox(height: 12),

              _buildFeatureTile(
                context,
                title: 'രേഖകൾ വായിക്കുക',
                subtitle: 'രേഖകൾ ക്യാമറ വഴി പരിശോധിച്ച് വായിക്കാം',
                badgeText: 'Document Reader',
                icon: Icons.document_scanner_rounded,
                accentBg: SahaayiColors.secondary,
                accentColor: SahaayiColors.primaryDark,
                route: '/documents',
              ),

              _buildFeatureTile(
                context,
                title: 'മരുന്ന് ഓർമ്മകൾ',
                subtitle: 'നിങ്ങളുടെ ദിവസേനയുള്ള മരുന്നുകളുടെ പട്ടിക',
                badgeText: 'Reminders',
                icon: Icons.medication_rounded,
                accentBg: SahaayiColors.accent,
                accentColor: const Color(0xFF2B6CB0),
                route: '/reminders',
              ),

              _buildFeatureTile(
                context,
                title: 'ശബ്ദ സഹായി',
                subtitle: 'മലയാളത്തിൽ സംസാരിച്ച് നിർദ്ദേശങ്ങൾ നൽകാം',
                badgeText: 'Voice Assistant',
                icon: Icons.mic_rounded,
                accentBg: SahaayiColors.lavender,
                accentColor: const Color(0xFF6B46C1),
                route: '/voice',
              ),

              _buildFeatureTile(
                context,
                title: 'സ്മാർട്ട് ഫോം ഫില്ലർ',
                subtitle: 'നിങ്ങളുടെ വിവരങ്ങൾ ഉപയോഗിച്ച് ഫോം പൂരിപ്പിക്കാം',
                badgeText: 'Smart Autofill',
                icon: Icons.auto_fix_high_rounded,
                accentBg: SahaayiColors.secondary,
                accentColor: SahaayiColors.primaryDark,
                route: '/autofill',
              ),

              _buildFeatureTile(
                context,
                title: 'വീഴ്ച കണ്ടെത്തൽ & സുരക്ഷ',
                subtitle: 'സെൻസർ നിരീക്ഷണവും സുരക്ഷാ അലേർട്ടുകളും',
                badgeText: 'Safety & Sensors',
                icon: Icons.health_and_safety_rounded,
                accentBg: const Color(0xFFFFF4DE),
                accentColor: const Color(0xFFC05621),
                route: '/fall-detection',
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'വീട്',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_rounded),
            label: 'മരുന്നുകൾ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open_rounded),
            label: 'രേഖകൾ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'പ്രൊഫൈൽ',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color accentBg,
    required Color accentColor,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SahaayiColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push(route),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accentColor, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: SahaayiColors.textMain,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SahaayiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: SahaayiColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
