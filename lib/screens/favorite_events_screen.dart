import 'package:flutter/material.dart';

import '../widgets/events_grid.dart';

class FavoriteEventsScreen extends StatelessWidget {
  static const routeName = '/favoriteEvents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Избранные мероприятия',
            style: TextStyle(color: Colors.black)),
      ),
      body: EventsGrid(null, 3),
    );
  }
}
