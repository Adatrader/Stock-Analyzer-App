import 'dart:collection';

import 'package:extended_image/extended_image.dart';
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
        showMessage(stockCount.toString(), stock.ticker);
      });
    }
    if (crossedBelow.isEmpty) {
      crossedBelow.add(StockItem(ticker: 'None', companyName: ''));
    }
    if (crossedAbove.isEmpty) {
      crossedAbove.add(StockItem(ticker: 'None', companyName: ''));
    }
    setState(() {});
    return true;
  }

  void showMessage(String count, String ticker) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Finished $count of ${stockList.items.length}: [$ticker]"),
    ));
  }

  Widget generateStockCard(String crossoverType, StockItem stock) {
    return SizedBox(
        height: 70,
        child: GFListTile(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            title: Flexible(
              child: Text(stock.ticker,
                  style: TextStyle(
                      color: crossoverType == Crossover.NEUTRAL
                          ? Colors.black
                          : Colors.white)),
            ),
            color: crossoverType == Crossover.CROSSOVER_UP
                ? Colors.green
                : crossoverType == Crossover.CROSSOVER_DOWN
                    ? Colors.red
                    : Colors.white,
            avatar: Visibility(
              visible: stock.ticker != "None",
              child: GFAvatar(
                backgroundColor: Colors.grey[200],
                size: GFSize.SMALL,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: ExtendedImage.network(
                    'https://financialmodelingprep.com/image-stock/${stock.ticker}.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            subTitle: Flexible(
              child: Text(stock.companyName,
                  style: TextStyle(
                      color: crossoverType == Crossover.NEUTRAL
                          ? Colors.black
                          : Colors.white)),
            ),
            onTap: () {
              if (stock.ticker != "None") {
                Navigator.of(context).push(FadePageRoute(
                    builder: (context) =>
                        StockDetails(stock.ticker, stock.companyName)));
              }
            }));
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
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
          child: GridView.count(
              primary: true,
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
              children: [
                ListView(children: <Widget>[
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
                                fontSize: 30, fontWeight: FontWeight.bold))),
                  ),
                  stockCount == stockList.items.length
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: crossedAbove.length,
                          itemBuilder: (BuildContext context, int index) {
                            StockItem stock = crossedAbove[index];
                            return generateStockCard(
                                Crossover.CROSSOVER_UP, stock);
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
                                fontSize: 30, fontWeight: FontWeight.bold))),
                  ),
                  stockCount == stockList.items.length
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: crossedBelow.length,
                          itemBuilder: (BuildContext context, int index) {
                            StockItem stock = crossedBelow[index];
                            return generateStockCard(
                                Crossover.CROSSOVER_DOWN, stock);
                          })
                      : const GFLoader(type: GFLoaderType.circle),
                ]),
                ListView(children: <Widget>[
                  Card(
                    margin: stockCount != stockList.items.length
                        ? const EdgeInsets.only(bottom: 50)
                        : null,
                    child: const Center(
                        child: Text("Neutral",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                  ),
                  stockCount == stockList.items.length
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: neutral.length,
                          itemBuilder: (BuildContext context, int index) {
                            StockItem stock = neutral[index];
                            return generateStockCard(Crossover.NEUTRAL, stock);
                          })
                      : const GFLoader(type: GFLoaderType.circle),
                ])
              ])),
      drawer: NavigationDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
