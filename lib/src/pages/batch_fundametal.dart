import 'dart:collection';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stock_analyzer/constants/crossover.dart';
import 'package:stock_analyzer/helpers/fmp_helper.dart';
import 'package:stock_analyzer/model/fmp_dcf.dart';
import 'package:stock_analyzer/model/fmp_stock_rating.dart';
import 'package:stock_analyzer/model/stock_item.dart';
import 'package:stock_analyzer/model/stock_list.dart';
import 'package:stock_analyzer/pageRoute/custom_route.dart';
import 'package:stock_analyzer/src/pages/stock_details.dart';
import 'package:stock_analyzer/widgets/navigation_drawer.dart';
import 'package:stock_analyzer/widgets/rating_display.dart';
import 'package:url_launcher/url_launcher.dart';

class BatchFundamental extends StatefulWidget {
  const BatchFundamental({Key? key}) : super(key: key);
  static const routeName = '/batch_fundamental';

  @override
  BatchFundamentalState createState() => BatchFundamentalState();
}

class BatchFundamentalState extends State<BatchFundamental> {
  final StockList stockList = StockList();
  final LocalStorage storage = LocalStorage('stock_app');
  bool initialized = false;
  bool fundamentalsLoaded = false;
  late List<List<dynamic>> stockFundamental;
  StockFmpHelper fmpHelper = StockFmpHelper();

  @override
  void initState() {
    super.initState();
    loadStorage();
    loadFundamental();
  }

  void loadFundamental() async {
    stockFundamental = await fmpHelper.getStocksFundamental(stockList.items);
    setState(() {});
    print(stockFundamental.length);
    print(stockList.items.length);
    fundamentalsLoaded = true;
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

  void launchURL() async {
    const url =
        'https://site.financialmodelingprep.com/developer/docs/recommendations-formula';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Failed to launch info page.");
    }
  }

  Widget getSubViewCard(String heading, String recommendation, int score) {
    return Padding(
      padding: const EdgeInsets.only(left: 100, right: 100),
      child: GFCard(
          color: Colors.white70,
          content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Text(heading,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black)),
                ),
                Expanded(
                  child: Text(
                    "Recommendation: " + recommendation,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: IconTheme(
                    data: const IconThemeData(
                      color: Colors.green,
                      size: 20,
                    ),
                    child: RatingDisplay(
                      value: score,
                    ),
                  ),
                ),
              ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundamental Analysis'),
      ),
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.purple[900]!, Colors.blue])),
              padding: const EdgeInsets.all(10.0),
              constraints: const BoxConstraints.expand(),
              child: fundamentalsLoaded
                  ? ListView.builder(
                      itemCount: stockFundamental.length + 2,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return const Text(
                            "Fundamental Analysis",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        } else if (index == 1) {
                          return const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Text(
                                "Sorted by most undervalued",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ));
                        } else {
                          List<dynamic> stock = stockFundamental[index - 2];
                          FmpDcf fmpDcf = stock[0] as FmpDcf;
                          FmpStockRating fmpStockRating =
                              stock[1] as FmpStockRating;

                          return Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  right:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: GFAccordion(
                                  collapsedTitleBackgroundColor:
                                      const Color(0xFFE0E0E0),
                                  titleChild: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      GFAvatar(
                                        backgroundColor: Colors.grey[200],
                                        size: GFSize.SMALL,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: ExtendedImage.network(
                                            'https://financialmodelingprep.com/image-stock/${fmpDcf.symbol}.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text("    " + fmpDcf.symbol,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      const Expanded(
                                        child: Text("Total Score:  ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87)),
                                      ),
                                      Expanded(
                                        child: IconTheme(
                                          data: const IconThemeData(
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          child: RatingDisplay(
                                              value:
                                                  fmpStockRating.ratingScore),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                            "Grade: " + fmpStockRating.rating,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      Expanded(
                                        child: Text(
                                            fmpStockRating.ratingRecommendation,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      Expanded(
                                        child: Text(
                                            "Stock Price: \$${fmpDcf.stockPrice}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      Expanded(
                                        child: Text(
                                            "DCF Value: \$${fmpDcf.dcf.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      Expanded(
                                        child: stock[2] > 0
                                            ? Text(
                                                "+${stock[2].toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green))
                                            : Text(
                                                "-${stock[2].toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                  contentChild: SizedBox(
                                    height: 400,
                                    child: GridView.count(
                                      crossAxisCount: 1,
                                      children: [
                                        Column(
                                          children: [
                                            getSubViewCard(
                                                "Discounted Cash Flow",
                                                fmpStockRating
                                                    .dcfRecommendation,
                                                fmpStockRating.dcfScore),
                                            getSubViewCard(
                                                "Price to Earnings",
                                                fmpStockRating.peRecommendation,
                                                fmpStockRating.peScore),
                                            getSubViewCard(
                                                "Return on Assets",
                                                fmpStockRating
                                                    .roaRecommendation,
                                                fmpStockRating.roaScore),
                                            getSubViewCard(
                                                "Return on Equity",
                                                fmpStockRating
                                                    .roeRecommendation,
                                                fmpStockRating.roeScore),
                                            getSubViewCard(
                                                "P/B Ratio",
                                                fmpStockRating.pbRecommendation,
                                                fmpStockRating.pbScore),
                                            getSubViewCard(
                                                "Debt to Equity",
                                                fmpStockRating.deRecommendation,
                                                fmpStockRating.deScore)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  contentBackgroundColor: Colors.white,
                                  collapsedIcon: const Icon(
                                    MdiIcons.chevronDown,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  expandedIcon: const Icon(MdiIcons.chevronUp,
                                      color: Colors.black, size: 30)));
                        }
                      })
                  : const Center(
                      child: GFLoader(type: GFLoaderType.circle),
                    )),
          Positioned(
              right: 40,
              bottom: 40,
              child: FloatingActionButton(
                heroTag: "btn1",
                elevation: 8,
                tooltip: "Recommendations formula",
                backgroundColor: Colors.blue,
                child: const Icon(
                  MdiIcons.helpCircle,
                  color: Colors.white,
                ),
                onPressed: () => launchURL(),
              )),
        ],
      ),
      drawer: NavigationDrawer(),
    );
  }
}
