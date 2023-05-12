import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  final Function function;
  final String fieldName;

  const ProfileField(this.fieldName, this.function);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      // alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10.0),
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
            width: MediaQuery.of(context).size.height * 0.4, height: 70),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            // padding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          child: Text(fieldName,
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              )),
          onPressed: function,
        ),
      ),
    );
  }
}
