import 'package:flutter/material.dart';
import 'package:gupsup/main.dart';

class Keyylock extends StatefulWidget {
  @override
  State<Keyylock> createState() => _KeyylockState();
}

class _KeyylockState extends State<Keyylock> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Key'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // TextBox
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '$key',
                  //hintText: 'Type something...',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
              SizedBox(height: 20), // Spacing between TextField and Button
              // Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    key = _controller.text;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.blue, // Background color
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
