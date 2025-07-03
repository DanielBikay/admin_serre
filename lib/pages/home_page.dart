// home_page.dart
import 'package:flutter/material.dart';
import 'accueil_page.dart';
import 'capteurs_page.dart';
import 'actionneurs_page.dart';
import 'alertes_page.dart';
import 'seuils_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onChangeTheme;
  final int currentThemeIndex;

  const HomePage({super.key, required this.onChangeTheme, required this.currentThemeIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AccueilPage(),
    CapteursPage(),
    ActionneursPage(),
    AlertesPage(),
    SeuilsPage(),
  ];

  final List<String> _titles = [
    'Accueil',
    'Capteurs',
    'Actionneurs',
    'Alertes',
    'Seuils',
  ];

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.home;
      case 1: return Icons.sensors;
      case 2: return Icons.power;
      case 3: return Icons.warning;
      case 4: return Icons.tune;
      default: return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final itemCount = _pages.length;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: _showThemeChooser,
          ),
        ],
      ),
      drawer: _buildCustomDrawer(context),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildResponsiveBottomBar(isSmallScreen, itemCount),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildResponsiveBottomBar(bool isSmallScreen, int itemCount) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          selectedFontSize: isSmallScreen ? 12 : 14,
          unselectedFontSize: isSmallScreen ? 12 : 14,
          iconSize: isSmallScreen ? 24 : 28,
          items: List.generate(itemCount, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_getIconForIndex(index)),
              label: _titles[index],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(230),
              Theme.of(context).colorScheme.secondary.withAlpha(230),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.eco,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Serre Intelligente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ..._pages.asMap().entries.map((entry) {
              final index = entry.key;
              return ListTile(
                leading: Icon(
                  _getIconForIndex(index),
                  color: Colors.white.withAlpha(204),
                ),
                title: Text(
                  _titles[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: _selectedIndex == index 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              );
            }),
            Divider(color: Colors.white.withAlpha(51)),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white.withAlpha(204)),
              title: Text(
                'Paramètres',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeChooser() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisissez un thème',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeChooserItem(0, 'Nature', Colors.green),
                  _buildThemeChooserItem(1, 'Professionnel', Colors.blue),
                  _buildThemeChooserItem(2, 'Sombre', Colors.deepPurple),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeChooserItem(int index, String label, Color color) {
    return GestureDetector(
      onTap: () {
        widget.onChangeTheme(index);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.currentThemeIndex == index
                    ? Colors.black
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}