import 'package:app/providers/address.dart';
import 'package:provider/provider.dart';

import '../providers/events.dart';
import '../widgets/events_grid.dart';
import '/screens/creating_event_screen.dart';
import 'package:flutter/material.dart';
import '../providers/event.dart';

class EventsScreen extends StatefulWidget {
  static const routeName = '/events';
  const EventsScreen({Key key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  void createFunc() async {
    await Navigator.of(context).pushNamed(
      CreatingEventScreen.routeName,
      arguments: Event(
        id: null,
        dateTime: null,
        description: '',
        price: '',
        name: '',
        address: Address(),
        extraInformation: '',
        creatorId: '',
        categories: {
          'Спорт': false,
          'Развлечения': false,
          'Вечеринки': false,
          'Прогулка': false,
          'Искусство': false,
          'Обучение': false,
          'Концерт': false,
          'Настольные игры': false,
          'Гастрономия': false,
        },
      ),
    );
    setState(() {
      Provider.of<Events>(context, listen: false).fetchAndSetEvents(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            children: <Widget>[
              Text('Мои мероприятия', style: TextStyle(color: Colors.black)),
              Container(
                padding: EdgeInsets.only(left: 45),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    createFunc();
                  },
                ),
              ),
            ],
          )),
      body: EventsGrid(null, 2),
    );
  }
}
