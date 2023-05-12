import 'package:app/screens/search_places_screen.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/profiles.dart';
import '/screens/profile_screen.dart';
import '../widgets/popup_categories.dart';
import 'package:flutter/material.dart';

import '../widgets/events_grid.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic> categories = {
    'Спорт': false,
    'Развлечения': false,
    'Вечеринки': false,
    'Прогулка': false,
    'Искусство': false,
    'Обучение': false,
    'Концерт': false,
    'Настольные игры': false,
    'Гастрономия': false,
  };
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  bool alreadyCreated = false;

  @override
  void initState() {
    _pages = [
      {
        'page': SearchPlacesScreen(),
        'title': 'Карта',
      },
      {
        'title': 'Мероприятия',
      },
      {
        'page': ProfileScreen(),
        'title': 'Профиль',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    // print(index);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Future<void> addProfile() async {
    String curEmail;
    await Provider.of<Profiles>(context, listen: false).setEmail();
    if (!await Provider.of<Profiles>(context, listen: false).alreadyAdded()) {
      try {
        // print('ADD NEW ACCOUNT ${curEmail}');
        curEmail = Profiles.curEmail;
        await Provider.of<Profiles>(context, listen: false)
            .addProfile(curEmail);
      } catch (error) {
        // print('WRONG ADDING PROFILE');
        throw error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyCreated) {
      addProfile();
      alreadyCreated = true;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Container(
              height: 19,
              child: Text(
                'Palm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 20,
              child: Image.asset('assets/images/palm-tree.png',
                  fit: BoxFit.fill, height: 80, width: 25, scale: 0.8),
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex]['title'] == 'Мероприятия'
          ? EventsGrid(categories, 1)
          : _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Карта',
            icon: Icon(Icons.map),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Мероприятия',
            icon: Icon(Icons.event),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Профиль',
            icon: Icon(Icons.account_box_outlined),
          ),
        ],
      ),
      floatingActionButton: _pages[_selectedPageIndex]['title'] == 'Мероприятия'
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.black,
              ),
              height: 50,
              child: IconButton(
                icon: Icon(Icons.filter_alt_rounded),
                color: Theme.of(context).primaryColor,
                onPressed: callPopUp,
              ),
            )
          : null,
    );
  }

  Future<void> callPopUp() async {
    dynamic newCategories = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PopUpDialog(
          oldCategories: categories,
        ).build(context),
      ),
    ) as Map<String, dynamic>;
    setFilters(newCategories);
  }

  void setFilters(Map<String, dynamic> newCategories) {
    setState(() {
      for (String key in newCategories.keys) {
        categories[key] = newCategories[key];
      }
    });
  }
}
