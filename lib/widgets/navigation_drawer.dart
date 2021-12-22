import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:stock_analyzer/src/pages/batch_ema.dart';
import 'package:stock_analyzer/src/pages/batch_fundametal.dart';
import 'package:stock_analyzer/src/pages/home_page.dart';
import 'package:stock_analyzer/src/pages/portfolio_optimization.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NavigationDrawerState();
  }
}

class NavigationDrawerState extends State<NavigationDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GFDrawerHeader(
            currentAccountPicture: const GFAvatar(
              radius: 80.0,
              backgroundImage: NetworkImage(
                  "https://cdn.pixabay.com/photo/2016/11/23/14/37/blur-1853262_1280.jpg"),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text('Adatrader'),
                Text('abc@server.in'),
              ],
            ),
          ),
          ListTile(
              title: const Text('Watchlist'),
              onTap: () {
                Navigator.restorablePushNamed(context, HomePage.routeName);
              }),
          ListTile(
            title: const Text('EMA Snapshot'),
            onTap: () {
              Navigator.restorablePushNamed(context, BatchEma.routeName);
            },
          ),
          ListTile(
            title: const Text('Portfolio Optimization'),
            onTap: () {
              Navigator.restorablePushNamed(
                  context, PortfolioOptimization.routeName);
            },
          ),
          ListTile(
            title: const Text('Fundamental Analysis'),
            onTap: () {
              Navigator.restorablePushNamed(
                  context, BatchFundamental.routeName);
            },
          ),
        ],
      ),
    );
  }
}
