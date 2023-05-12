import 'package:flutter/material.dart';
import './button_widget.dart';

class PopUpDialog extends StatelessWidget {
  static Map<String, dynamic> popUpCategories = {
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
  bool setOld = false;
  Map<String, dynamic> oldCategories;

  PopUpDialog({this.oldCategories});

  static void setNewCategory(String buttonName) {
    bool curSelect = popUpCategories[buttonName];
    popUpCategories[buttonName] = !curSelect;
    // print('NEWWWW CATEGORIES POPUP $categories');
    // print('WE SET $buttonName');
  }

  void setSelectedCategories() {
    for (String buttonName in oldCategories.keys) {
      popUpCategories[buttonName] = oldCategories[buttonName];
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('WE BUILD POPUP');
    if (!setOld) {
      setSelectedCategories();
      setOld = true;
    }

    final deviceSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        // градиент на весь экран авторизации
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.9),
                Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/palm-tree.png',
                            fit: BoxFit.fill,
                            height: 60,
                            width: 60,
                            scale: 0.8),
                      ),
                    ],
                  ),
                ),
                AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    "Выберите категории, подходящие к Вашему мероприятию",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  content: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 325,
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(children: [
                              ButtonWidget(
                                name: 'Спорт',
                                isSelected: popUpCategories['Спорт'],
                              ),
                              ButtonWidget(
                                  name: 'Развлечения',
                                  isSelected: popUpCategories['Развлечения']),
                              ButtonWidget(
                                  name: 'Вечеринки',
                                  isSelected: popUpCategories['Вечеринки']),
                              ButtonWidget(
                                  name: 'Прогулка',
                                  isSelected: popUpCategories['Прогулка']),
                              ButtonWidget(
                                  name: 'Искусство',
                                  isSelected: popUpCategories['Искусство']),
                              ButtonWidget(
                                  name: 'Обучение',
                                  isSelected: popUpCategories['Обучение']),
                              ButtonWidget(
                                  name: 'Концерт',
                                  isSelected: popUpCategories['Концерт']),
                              ButtonWidget(
                                  name: 'Настольные игры',
                                  isSelected:
                                      popUpCategories['Настольные игры']),
                              ButtonWidget(
                                  name: 'Гастрономия',
                                  isSelected: popUpCategories['Гастрономия']),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            // print('CATEGORIES POPUP');
                            // print(oldCategories);
                            Navigator.of(context).pop(oldCategories);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Отменить',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 58),
                          child: TextButton(
                            onPressed: () {
                              // возвращаем, новый массив newCategories
                              // print('VERY NEW CATEGORIES $categories');
                              //oldEvent.categories = categories;
                              Navigator.of(context).pop(popUpCategories);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).primaryColor),
                            child: Text(
                              'Применить',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    //  return buildPopupDialog(context);
    // return Placeholder();
  }
}
