import 'package:flutter/material.dart';
import 'package:rovify/presentation/common/common_appbar.dart';
import 'package:rovify/presentation/common/custom_bottom_navbar.dart';
import 'package:rovify/presentation/screens/home/tabs/create_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/explore_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/stream_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 2) {
      // Show bottom sheet from CreateTab
      CreateTab.showCreateBottomSheet(context, (){}, null);
      return; // Skip setting index or rebuilding screen
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    const ExploreTab(),   // Default screen
    const StreamTab(),    // Livestreams tab
    const SizedBox(),
    const Center(child: Text('Marketplace (Coming soon)')),
    const Center(child: Text('Echo (Coming soon)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        // location: "Accra, Ghana", // Will later dynamically pass location
        // userProfileUrl: null,  // Pass actual profile image URL later
        // onNotificationTap: () {
        //   // Implement navigation to notifications screen
        //   debugPrint("Notification tapped");
        // },
        // onProfileTap: () {
        //   // Navigate to profile page
        //   debugPrint("Profile tapped");
        // },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}