import 'package:flutter/material.dart';

class Choise extends StatefulWidget {
  int result;
  int value;
  Choise(this.value);
  //  const Choise({super.key});
  @override
  State<Choise> createState() => _ChoiseState();
}

class _ChoiseState extends State<Choise> {
  // const _ChoiseState({super.key});
  // State<MyThreeOptions> createState() => _MyThreeOptionsState();
  var t;
  // int _value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      // list of length 3
      children: List.generate(
        2,
        (int index) {
          if (index == 0)
            t = 'Мужской';
          else {
            t = 'Женский';
          }
          // choice chip allow us to
          // set its properties.
          return ChoiceChip(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            // backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.all(8),
            label: Text(t),
            // color of selected chip
            selectedColor: Theme.of(context).primaryColor,
            // selected chip value
            selected: widget.value == index,
            labelStyle: TextStyle(
              color: widget.value == index
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).primaryColor,
            ),

            // onselected method
            onSelected: (bool selected) {
              setState(() {
                widget.value = selected ? index : null;
                widget.result = widget.value;
              });
            },
          );
        },
      ).toList(),
    );
  }
}
