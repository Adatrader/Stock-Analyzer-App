import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:stock_analyzer/helpers/fmp_helper.dart';

class StockDetails extends StatefulWidget {
  final String ticker;
  final String name;

  StockDetails(this.ticker, this.name);

  @override
  State<StatefulWidget> createState() {
    return new StockDetailsState(this.ticker, this.name);
  }
}

class StockDetailsState extends State<StockDetails> {
  final String ticker;
  final String name;
  Map<String, double> ema = {};
  late StockFmpHelper api;
  StockDetailsState(this.ticker, this.name);

  @override
  void initState() {
    api = StockFmpHelper();
    loadEma();
    super.initState();
  }

  void loadEma() async {
    ema = await api.getEmaList(ticker, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.purple[900]!, Colors.blue])),
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    ticker,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ])),
            Center(
              child: GFImageOverlay(
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
                borderRadius: BorderRadius.circular(20.0),
                image: NetworkImage(
                    'https://charts2.finviz.com/chart.ashx?t=$ticker&ty=c&ta=1&p=d&s=l'),
              ),
            ),
            const Center(
              child: Text(
                "Fundamental Recommendation",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 200),
            const Center(
              child: Text(
                "EMA Crossover History",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
