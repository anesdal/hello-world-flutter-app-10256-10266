import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/home/home_fragment.dart';
import 'package:ride_karo/features/drawer/payment_fragment.dart';
import 'package:ride_karo/features/drawer/my_rides_fragment.dart';
import 'package:ride_karo/features/drawer/invite_friends_fragment.dart';
import 'package:ride_karo/features/drawer/power_pass_fragment.dart';
import 'package:ride_karo/features/drawer/notifications_fragment.dart';
import 'package:ride_karo/features/drawer/insurance_fragment.dart';
import 'package:ride_karo/features/drawer/settings_fragment.dart';
import 'package:ride_karo/features/drawer/support_fragment.dart';
import 'package:ride_karo/features/drawer/covid19_fragment.dart';

/// Main navigation shell matching the Kotlin [HomeActivity].
///
/// Uses a [Scaffold] with a [Drawer] to host all drawer fragments.
/// The start destination is [HomeFragment] (map screen).
/// Toolbar matches `activity_home.xml` — yellow background, elevated,
/// with yellow-tinted title text (yellow-on-yellow, matching f3.png).
/// Nav drawer matches `nav_header.xml` with profile icon, name, and email.
class HomeActivity extends StatefulWidget {
  /// Creates the home activity widget.
  const HomeActivity({
    super.key,
    this.userName,
    this.userEmail,
    this.userPhoto,
  });

  /// User display name passed from login.
  final String? userName;

  /// User email passed from login.
  final String? userEmail;

  /// User photo URL passed from login.
  final String? userPhoto;

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  int _selectedDrawerIndex = 0;
  String _title = 'Ride Karo';

  late String _displayName;
  late String _displayEmail;

  /// Drawer items matching nav_graph.xml destinations and drawer_menu.xml.
  /// Icons chosen to closely match the original ic_ drawables.
  static const List<_DrawerItem> _drawerItems = [
    _DrawerItem(icon: Icons.home, label: 'Home'),
    _DrawerItem(icon: Icons.coronavirus, label: 'COVID 19'),
    _DrawerItem(icon: Icons.payment, label: 'Payment'),
    _DrawerItem(icon: Icons.two_wheeler, label: 'My Rides'),
    _DrawerItem(icon: Icons.people, label: 'Invite Friends'),
    _DrawerItem(icon: Icons.card_membership, label: 'PowerPass'),
    _DrawerItem(icon: Icons.notifications, label: 'Notifications'),
    _DrawerItem(icon: Icons.health_and_safety, label: 'Insurance'),
    _DrawerItem(icon: Icons.settings, label: 'Settings'),
    _DrawerItem(icon: Icons.support_agent, label: 'Support'),
  ];

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName ??
        PreferenceHelper.getString(AppConstants.keyDisplayName);
    _displayEmail = widget.userEmail ??
        PreferenceHelper.getString(AppConstants.keyUserGoogleGmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar matching my_toolbar in activity_home.xml:
      // yellow background (?attr/colorPrimary), elevation 4dp,
      // titleTextColor = yellow (yellow-on-yellow blends with bg as in f3.png)
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.primaryYellow,
          ),
        ),
        backgroundColor: AppTheme.primaryYellow,
        foregroundColor: AppTheme.black,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black45,
        iconTheme: const IconThemeData(
          color: AppTheme.black,
          size: 24,
        ),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  /// Builds the navigation drawer matching NavigationView in activity_home.xml
  /// with nav_header.xml header layout and drawer_menu.xml items.
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Nav header matching nav_header.xml — profile picture,
          // name, and phone/email below
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 60,
              bottom: 16,
            ),
            color: AppTheme.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circle profile image — matches CircleImageView ivProfile
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: widget.userPhoto != null &&
                          widget.userPhoto!.isNotEmpty
                      ? NetworkImage(widget.userPhoto!)
                      : null,
                  child: widget.userPhoto == null || widget.userPhoto!.isEmpty
                      ? Icon(Icons.person,
                          size: 32, color: Colors.grey.shade500)
                      : null,
                ),
                const SizedBox(width: 12),
                // Name and email/phone — matches tv_user_name & tv_user_email_id
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName.isNotEmpty ? _displayName : 'Rahul Yadav',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ProductSans',
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _displayEmail.isNotEmpty
                            ? _displayEmail
                            : '+91 9819087614',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'ProductSans',
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Drawer menu items — matching drawer_menu.xml with
          // Style.NavBarView (ProductSans font)
          for (int i = 0; i < _drawerItems.length; i++)
            ListTile(
              leading: Icon(
                _drawerItems[i].icon,
                color: _selectedDrawerIndex == i
                    ? AppTheme.accentOrange
                    : Colors.grey.shade700,
                size: 22,
              ),
              title: Text(
                _drawerItems[i].label,
                style: TextStyle(
                  fontWeight: _selectedDrawerIndex == i
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  color: _selectedDrawerIndex == i
                      ? AppTheme.accentOrange
                      : AppTheme.black,
                ),
              ),
              selected: _selectedDrawerIndex == i,
              onTap: () => _onDrawerItemTapped(i),
            ),
        ],
      ),
    );
  }

  /// Builds the body content based on the selected drawer item.
  Widget _buildBody() {
    switch (_selectedDrawerIndex) {
      case 0:
        return const HomeFragment();
      case 1:
        return const Covid19Fragment();
      case 2:
        return const PaymentFragment();
      case 3:
        return const MyRidesFragment();
      case 4:
        return const InviteFriendsFragment();
      case 5:
        return const PowerPassFragment();
      case 6:
        return const NotificationsFragment();
      case 7:
        return const InsuranceFragment();
      case 8:
        return const SettingsFragment();
      case 9:
        return const SupportFragment();
      default:
        return const HomeFragment();
    }
  }

  /// Handles drawer item tap — updates selected index and closes drawer.
  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedDrawerIndex = index;
      _title = _drawerItems[index].label;
    });
    Navigator.of(context).pop(); // Close drawer
  }
}

/// Internal drawer item model.
class _DrawerItem {
  const _DrawerItem({required this.icon, required this.label});

  /// The icon for the drawer item.
  final IconData icon;

  /// The label text for the drawer item.
  final String label;
}
