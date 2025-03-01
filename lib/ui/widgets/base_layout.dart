import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/constants.dart';

enum NavigationItem {
  home,
  search,
  camera,
  history,
  profile,
}

class BaseLayout extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final NavigationItem? currentItem;
  final Function(NavigationItem)? onNavigationItemSelected;
  final bool showAppBar;
  final bool showBottomNav;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? customAppBar;

  const BaseLayout({
    Key? key,
    required this.body,
    this.title,
    this.actions,
    this.currentItem,
    this.onNavigationItemSelected,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
    this.customAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar
          ? customAppBar ??
              AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
                elevation: 0,
              )
          : null,
      body: SafeArea(
        bottom: !showBottomNav,
        child: kIsWeb ? _buildWebLayout(context) : body,
      ),
      bottomNavigationBar:
          showBottomNav ? _buildBottomNavigationBar(context) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    // For web, we'll add some constraints to prevent the content from stretching too wide
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: body,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentItem?.index ?? 0,
        onTap: (index) {
          if (onNavigationItemSelected != null) {
            onNavigationItemSelected!(NavigationItem.values[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
