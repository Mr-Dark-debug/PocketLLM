import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromARGB(157, 155, 128, 255), // Custom color
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 20), // Add some space at the top
            ListTile(
              leading: Icon(Icons.chat, color: Colors.white),
              title: Text(
                'New Chat',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () {
                // Handle New Chat tap
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            ExpansionTile(
              leading: Icon(Icons.history, color: Colors.white),
              title: Text(
                'Chat History',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              children: <Widget>[
                ListTile(
                  title: Text('Chat 1'),
                  onTap: () {
                    // Handle Chat 1 tap
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Chat 2'),
                  onTap: () {
                    // Handle Chat 2 tap
                    Navigator.pop(context);
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              collapsedIconColor: Colors.white,
              iconColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.white),
              title: Text(
                'Docs',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () {
                // Handle Docs tap
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text(
                'About',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () {
                // Handle About tap
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
