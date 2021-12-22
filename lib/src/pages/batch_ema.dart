import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stock_analyzer/constants/crossover.dart';
import 'package:stock_analyzer/helpers/fmp_helper.dart';
import 'package:stock_analyzer/model/stock_item.dart';
import 'package:stock_analyzer/model/stock_list.dart';
import 'package:stock_analyzer/pageRoute/custom_route.dart';
import 'package:stock_analyzer/src/pages/stock_details.dart';
import 'package:stock_analyzer/widgets/navigation_drawer.dart';

class BatchEma extends StatefulWidget {
  const BatchEma({Key? key}) : super(key: key);
  static const routeName = '/batch_ema';

  @override
  BatchEmaState createState() => BatchEmaState();
}

class BatchEmaState extends State<BatchEma> {
  final StockList stockList = StockList();
  final LocalStorage storage = LocalStorage('stock_app');
  List<StockItem> neutral = [];
  List<StockItem> crossedAbove = [];
  List<StockItem> crossedBelow = [];
  bool initialized = false;
  int stockCount = 0;
  StockFmpHelper fmpHelper = StockFmpHelper();
  String now = DateFormat("yyyy-MM-dd").format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadStorage();
    sortStocks();
  }

  void loadStorage() {
    if (!initialized) {
      var items = storage.getItem('stocks');
      if (items != null) {
        stockList.items = List<StockItem>.from(
          (items as List).map(
            (item) => StockItem(
              ticker: item['ticker'],
              companyName: item['company_name'],
            ),
          ),
        );
      }
      initialized = true;
    }
  }

  Future<bool> sortStocks() async {
    stockCount = 0;
    for (StockItem stock in stockList.items) {
      await fmpHelper.getCrossover(stock.ticker).then((value) {
        value == Crossover.CROSSOVER_DOWN
            ? crossedBelow.add(stock)
            : value == Crossover.CROSSOVER_UP
                ? crossedAbove.add(stock)
                : neutral.add(stock);
        stockCount++;
        showMessage(stockCount.toString());
      });
    }
    if (crossedBelow.isEmpty) {
      crossedBelow.add(StockItem(ticker: 'None', companyName: 'Today'));
    }
    if (crossedAbove.isEmpty) {
      crossedAbove.add(StockItem(ticker: 'None', companyName: 'Today'));
    }
    setState(() {});
    return true;
  }

  void showMessage(String count) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Finished $count of ${stockList.items.length}"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA Snapshot - (Use after 4pm)'),
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.purple[900]!, Colors.blue])),
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
              primary: true,
              crossAxisCount: MediaQuery.of(context).size.width > 1060 ? 2 : 1,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: <Widget>[
                      Text("EMA Crossovers on $now",
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      Card(
                        margin: stockCount != stockList.items.length
                            ? const EdgeInsets.only(bottom: 50)
                            : null,
                        child: const Center(
                            child: Text("Crossed Above",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))),
                      ),
                      stockCount == stockList.items.length
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: crossedAbove.length,
                              itemBuilder: (BuildContext context, int index) {
                                StockItem stock = crossedAbove[index];

                                return SizedBox(
                                    height: 80,
                                    child: GFListTile(
                                        titleText: stock.ticker,
                                        color: Colors.green,
                                        subTitleText: stock.companyName,
                                        onTap: () {
                                          Navigator.of(context).push(
                                              FadePageRoute(
                                                  builder: (context) =>
                                                      StockDetails(stock.ticker,
                                                          stock.companyName)));
                                        }));
                              })
                          : const GFLoader(type: GFLoaderType.circle),
                      const SizedBox(
                        height: 40,
                      ),
                      Card(
                        margin: stockCount != stockList.items.length
                            ? const EdgeInsets.only(bottom: 50)
                            : null,
                        child: const Center(
                            child: Text("Crossed Below",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))),
                      ),
                      stockCount == stockList.items.length
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: crossedBelow.length,
                              itemBuilder: (BuildContext context, int index) {
                                StockItem stock = crossedBelow[index];

                                return SizedBox(
                                    height: 80,
                                    child: GFListTile(
                                        titleText: stock.ticker,
                                        color: Colors.red,
                                        subTitleText: stock.companyName,
                                        onTap: () {
                                          Navigator.of(context).push(
                                              FadePageRoute(
                                                  builder: (context) =>
                                                      StockDetails(stock.ticker,
                                                          stock.companyName)));
                                        }));
                              })
                          : const GFLoader(type: GFLoaderType.circle),
                    ])),
                Visibility(
                    visible: MediaQuery.of(context).size.width > 600,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: <Widget>[
                          Card(
                            margin: stockCount != stockList.items.length
                                ? const EdgeInsets.only(bottom: 50)
                                : null,
                            child: const Center(
                                child: Text("Neutral",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold))),
                          ),
                          stockCount == stockList.items.length
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: neutral.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        StockItem stock = neutral[index];

                                        return SizedBox(
                                            height: 80,
                                            child: GFListTile(
                                                titleText: stock.ticker,
                                                color: Colors.white,
                                                subTitleText: stock.companyName,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      FadePageRoute(
                                                          builder: (context) =>
                                                              StockDetails(
                                                                  stock.ticker,
                                                                  stock
                                                                      .companyName)));
                                                }));

                                        // ...crossedBelowCards
                                      }))
                              : const GFLoader(type: GFLoaderType.circle),
                        ])))
              ])),
      drawer: NavigationDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
