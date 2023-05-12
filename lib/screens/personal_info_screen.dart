import '/providers/profile.dart';
import '/providers/profiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../widgets/chip.dart';

class PersonalInfoScreen extends StatefulWidget {
  static const routeName = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  int resultFromMale = -1;
  var value = -1;

  String labelForMaleField = 'Выберите пол';
  bool alreadyUpdated = false;
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  var _isInit = true;
  var _isLoading = false;
  Profile _editedProfile;

  Map<String, dynamic> redPersInfo = {
    'id': '',
    'firstName': '',
    'lastName': '',
    'username': '',
    'description': '',
    'email': '',
    'age': '',
    'male': '',
  };

  void copyData() {
    _editedProfile = Profile(
        id: redPersInfo['id'],
        firstName: redPersInfo['firstName'],
        lastName: redPersInfo['lastName'],
        username: redPersInfo['username'],
        description: redPersInfo['description'],
        email: redPersInfo['email'],
        age: redPersInfo['age'],
        male: redPersInfo['male']);
  }

  Future<void> _saveForm() async {
    String newUsername;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      newUsername = _editedProfile.username;
      await Provider.of<Profiles>(context, listen: false)
          .updateProfile(_editedProfile.id, _editedProfile);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop(newUsername);
              },
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop(newUsername);
  }

  void setStartValues(Profile profile) {
    redPersInfo['id'] = profile.id;
    redPersInfo['firstName'] = profile.firstName;
    redPersInfo['lastName'] = profile.lastName;
    redPersInfo['username'] = profile.username;
    redPersInfo['description'] = profile.description;
    redPersInfo['email'] = profile.email;
    redPersInfo['age'] = profile.age;
    redPersInfo['male'] = profile.male;
  }

  Widget persField(String initVal, String labelText, String fieldName) {
    int limit = fieldName == 'username' ? 10 : 100;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(limit),
        ],
        //  maxLength: 10,
        initialValue: initVal,
        style: TextStyle(color: Theme.of(context).primaryColor),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
        keyboardType: fieldName == 'age' ? TextInputType.number : null,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_priceFocusNode);
        },
        validator: ((value) => value.isEmpty ? 'Please provide a name' : null),
        onSaved: (value) {
          redPersInfo[fieldName] = value;
          copyData();
        },
      ),
    );
  }

  void update() async {
    _editedProfile = Profiles.curProfile;
    // if (_editedProfile == null) {
    //   await Provider.of<Profiles>(context, listen: false).setCurrentProfile();
    // }
    setStartValues(_editedProfile);
    alreadyUpdated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyUpdated) {
      update();
    }
    String label = 'Выберите пол';
    if (resultFromMale == 0) {
      label = "Мужской";
    } else if (resultFromMale == 1) {
      label = 'Женский';
    }
    redPersInfo['male'] = label == 'Выберите пол' ? _editedProfile.male : label;
    copyData();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Личные данные', style: TextStyle(color: Colors.black)),
        /* actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ], */
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _form,
              child: Column(
                children: <Widget>[
                  persField(_editedProfile.firstName, 'Имя', 'firstName'),
                  persField(_editedProfile.lastName, 'Фамилия', 'lastName'),
                  persField(_editedProfile.username, 'Ник', 'username'),
                  persField(
                      _editedProfile.description, 'О себе', 'description'),
                  // Choise(),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 5),
                          child: Text(
                            'Пол: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                              width: MediaQuery.of(context).size.height * 0.3,
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor,
                              ),
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              // padding: EdgeInsets.only(right: 240),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            // child: Align(
                            //   alignment: Alignment.centerLeft,
                            child: Text(
                              _editedProfile.male == ''
                                  ? 'Выберите пол'
                                  : _editedProfile.male,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            //),
                            onPressed: () {
                              showSmth(context, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // persField(_editedProfile.male, 'Пол', 'male'),
                  persField(_editedProfile.age, 'Возраст', 'age'),
                  Container(
                    child: TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(25)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20)))),
                      child: Text(
                        "Сохранить",
                        style: TextStyle(
                          fontSize: 19,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: _saveForm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showSmth(BuildContext context, int value) async {
    Choise choise = Choise(value);
    await showDialog(
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
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 22,
                        child: Text(
                          'Palm',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        height: 22,
                        child: Image.asset('assets/images/palm-tree.png',
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
                        "Выберите свой пол",
                        style: TextStyle(
                          fontSize: 19,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    choise,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Применить",
                style: TextStyle(
                  fontSize: 19,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  resultFromMale = choise.value;
                  Navigator.of(context).pop(resultFromMale);
                });
              },
            ),
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
            ),
          ],
        );
      },
    );
  }
}
