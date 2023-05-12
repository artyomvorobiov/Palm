import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth.dart';
import '../providers/color.dart';
import '../widgets/setting_field.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key key}) : super(key: key);

  _sendingMails() async {
    final url = Uri.parse(
        "mailto:palm.assistance@gmail.com ?subject=Palm%20help&body=I%20need%20help!");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentFirstColor = Provider.of<ColorTheme>(context).currentFirstColor;
    ColorTheme colorTheme = Provider.of<ColorTheme>(context);
    print("COLOR $currentFirstColor");
    final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Настройки', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            SettingField("Сменить тему", () {
              colorTheme
                  .switchTheme(currentFirstColor == 0xFF40E0D0 ? false : true);
            }),
            SettingField(
              "Поддержка",
              () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      // scrollable: true,
                      title: Container(
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              margin: const EdgeInsets.all(15.0),
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                              child: Row(
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
                                    child: Image.asset(
                                        'assets/images/palm-tree.png',
                                        fit: BoxFit.fill,
                                        height: 80,
                                        width: 25,
                                        scale: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      content: Container(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 80,
                                  child: Text(
                                    "Все обращения направляйте на почту",
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20)))),
                                  child: Text(
                                    "Отправить письмо",
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    _sendingMails();
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      actions: [
                        TextButton(
                          child: Text(
                            "Закрыть",
                            style: TextStyle(
                              fontSize: 19,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            Align(
                alignment: Alignment.center,
                child: SettingField("Выйти из аккаунта", () {
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).logout();
                })),
          ],
        ),
      ),
    );
  }
}
