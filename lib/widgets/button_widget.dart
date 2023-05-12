import 'popup_categories.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  String name;
  bool isSelected;

  ButtonWidget({this.name, this.isSelected});
  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  Color _buttonColor, _textColor;

  // @override
  // void initState() {
  //   widget.isSelected == true
  //       ? _buttonColor = Theme.of(context).primaryColor
  //       : _buttonColor = Theme.of(context).colorScheme.secondary;
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    widget.isSelected == true
        ? _buttonColor = Theme.of(context).primaryColor
        : _buttonColor = Theme.of(context).colorScheme.secondary;
    widget.isSelected == true
        ? _textColor = Theme.of(context).colorScheme.secondary
        : _textColor = Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (_buttonColor == Theme.of(context).colorScheme.secondary) {
                  _buttonColor = Theme.of(context).primaryColor;
                } else {
                  _buttonColor = Theme.of(context).colorScheme.secondary;
                }
                if (_textColor == Theme.of(context).primaryColor) {
                  _textColor = Theme.of(context).colorScheme.secondary;
                } else {
                  _textColor = Theme.of(context).primaryColor;
                }
              });
              PopUpDialog.setNewCategory(widget.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              side: BorderSide(
                width: 1.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
            child: Text(
              widget.name,
              style: TextStyle(
                fontSize: 22,
                color: _textColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
