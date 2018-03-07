import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'dart:io';
import 'dart:convert';

void main() async {
  var httpClient = new HttpClient();
  var uri = new Uri.http(
      '18.182.16.183:3000', '/api/v1/search', {});
  var request = await httpClient.getUrl(uri);
  var response = await request.close();
  var responseBody = await response.transform(UTF8.decoder).join();
  Map data = JSON.decode(responseBody);
  //print(data['total']);

  runApp(new MyApp(data: data));
}

class MyApp extends StatelessWidget {
  final _saved = new Set<WordPair>();
  final _data;
  MyApp({Map data}) : _data = data;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcom to Flutter',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/': return new MyCustomRoute(
            builder: (_) => new RandomWords(data: _data),
            settings: settings,
          );

          case '/favorites': return new MyCustomRoute(
            builder: (_) => new Favorites(_saved),
            settings: settings,
          );
        }
      }
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({ WidgetBuilder builder, RouteSettings settings })
    : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.isInitialRoute) {
      return child;
    }
    
    return new FadeTransition(opacity: animation, child: child);
  }
}

class RandomWords extends StatefulWidget {
  final _data;
  RandomWords({Map data}) :_data = data, super();

  @override
  createState() => new RandomWordsState(data: _data);
}

class Favorites extends StatelessWidget {
  final _saved;
  Favorites(Set<WordPair> saved) : _saved = saved, super();

  @override
  Widget build(BuildContext context) {
    final tiles = _saved.map(
            (pair) {
          return new ListTile(
              title: new Text(pair.asPascalCase)
          );
        }
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Saved suggestions'),
        ),
        body: new ListView(
          children: divided,
        )
    );
  }
}

class RentInfoWidget extends StatelessWidget {
  final _data;
  final _biggerFont  = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w800);
  final _smallerFont = const TextStyle(fontSize: 12.0, color: Colors.grey);
  final _iconSize    = 10.0;
  RentInfoWidget(Map data) : _data = data;

  @override
  Widget build(BuildContext context) {
    final item      = _data;
    final cover     = item["cover_image"];
    final kind      = item["kind_name"];
    final title     = item["title"];
    final floor     = item["floor_num"].toString() + '/' + item["total_floors"].toString();
    final address   = <String>[
      item["region_name"],
      item["section_name"],
      item["street_name"],
      item["lane_name"],
      floor
    ].join(", ");
    final price     = '\$' + item["price"].toString();
    final contact   = item["contact_name"];

    return new GestureDetector(
      onLongPress: () {
        Scaffold.of(context).showSnackBar(
          new SnackBar(
            content: new Container(
              height: 250.0,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 1,
                    child: new Image.network(cover)
                  ),
                  new Expanded(
                      flex: 2,
                      child: new Image.network(cover)
                  ),
                  new Expanded(
                      flex: 1,
                      child: new Image.network(cover)
                  ),
                ]
              )
            )
          )
        );
      },
      child:new Container(
        child: new Column(
          children: <Widget> [
            // Main
            new Container(
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget> [
                  // Main Left,
                  new Column(
                    children: <Widget> [
                      new Image.network(cover, width: 48.0, height: 48.0),
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget> [
                          new Icon(Icons.star, size: _iconSize, color: Colors.yellow),
                          new Icon(Icons.star, size: _iconSize, color: Colors.yellow),
                          new Icon(Icons.star_border, size: _iconSize),
                          new Icon(Icons.star_border, size: _iconSize),
                          new Icon(Icons.star_border, size: _iconSize),
                        ]
                      )
                    ]
                  ),


                  // Main Right
                  new Expanded(
                    child: new Container(
                      height: 56.0,
                      margin: const EdgeInsets.all(5.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget> [
                          new Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(title, style: _biggerFont),
                          ),
                          new Container(
                            alignment: Alignment.centerLeft,
                            child:new Text(address, style: _smallerFont),
                          )
                        ]
                      )
                    )
                  )

                ]
              )
            ),
            new Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
                  new Text(kind, style: const TextStyle(color: Colors.blue)),
                  new Text(contact),
                  new Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                ]
              )
            )
          ]
        )
      )
    );

    /*
    return new ListTile(
      leading: new Image.network(cover, fit: BoxFit.fill),
      title: new Text(title),
      subtitle: new Text(address),
      trailing: new Text(price),
    );
    */
  }
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont  = const TextStyle(fontSize: 18.0);
  var _data;

  RandomWordsState({Map data}) {
    _data = data["items"];
    _data.sort((l, r) {
      return r["price"] - l["price"];
    });
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return new Divider();
        }

        final id = index ~/ 2;
        if (id < _data.length) {
          return new RentInfoWidget(_data[id]);
        }
        else {
          return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Name generator'),
      ),
      body: _buildSuggestions(),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget> [
            new DrawerHeader(
              child: new Container(child: new Text("Head"))
            ),
            new ListTile(
              leading: const Icon(Icons.navigate_next),
              title: const Text("Favorites"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/favorites');
              }
            )
          ]
        )
      )
    );
  }
}