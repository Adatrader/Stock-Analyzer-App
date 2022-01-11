import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stock_analyzer/helpers/portfolio_opt_helper.dart';
import 'package:stock_analyzer/model/portfolio_opt_results.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class PorfolioOptResultsPage extends StatefulWidget {
  final List<String> selectedStocks;
  final String investmentAmount;
  String? targetReturn;
  String? targetVolatility;

  PorfolioOptResultsPage(
      {Key? key,
      required this.selectedStocks,
      required this.investmentAmount,
      this.targetReturn,
      this.targetVolatility})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      PorfolioOptResultsPageState(
          selectedStocks, investmentAmount, targetReturn, targetVolatility);
}

class PorfolioOptResultsPageState extends State<PorfolioOptResultsPage> {
  final List<String> selectedStocks;
  final String investmentAmount;
  String? targetReturn;
  String? targetVolatility;
  late PortfolioOptResults? results;
  bool finished = false;
  late Widget chartAllocation;
  late Widget discreteAllocation;
  late PortfolioOptHelper api;
  List<TableRow> rows = [];
  PorfolioOptResultsPageState(this.selectedStocks, this.investmentAmount,
      this.targetReturn, this.targetVolatility);

  @override
  void initState() {
    api = PortfolioOptHelper();
    loadResults();
    super.initState();
  }

  void loadResults() async {
    results = targetReturn != null
        ? await api.getTargetReturn(
            selectedStocks, investmentAmount, targetReturn!)
        : targetVolatility != null
            ? await api.getOptimizedVolatility(
                selectedStocks, investmentAmount, targetVolatility!)
            : await api.getMaxSharpe(selectedStocks, investmentAmount);
    if (results != null) {
      await createChart();
      await createDiscrete();
      finished = true;
    }
    setState(() {});
  }

  Future<bool> createChart() async {
    Map<String, double> resulting = Map<String, double>.from(results!.weights);
    Map<String, double> dataMap = {};
    resulting.forEach((key, value) {
      if (value != 0) {
        dataMap[key] = value * 100;
      }
    });
    chartAllocation = Center(
        child: PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 1200),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 6,
      colorList: Colors.accents,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      // centerText: "HYBRID",
      legendOptions: LegendOptions(
        showLegendsInRow: dataMap.length > 8 ? false : true,
        legendPosition:
            dataMap.length > 8 ? LegendPosition.left : LegendPosition.bottom,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: true,
        decimalPlaces: 2,
      ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    ));
    return true;
  }

  void launchURL() async {
    const url =
        'https://github.com/robertmartin8/PyPortfolioOpt#an-overview-of-classical-portfolio-optimization-methods';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Failed to launch porfolio optimization page.");
    }
  }

  Future<bool> createDiscrete() async {
    Map<String, int> resulting = Map<String, int>.from(results!.allocation);

    rows.add(const TableRow(children: [
      Center(
          child: Text("Shares",
              textScaleFactor: 2,
              style: TextStyle(fontWeight: FontWeight.bold))),
      Center(
          child: Text("Ticker",
              textScaleFactor: 2,
              style: TextStyle(fontWeight: FontWeight.bold))),
    ]));

    resulting.forEach((key, value) {
      rows.add(TableRow(children: [
        Center(
            child: Text(
          value.toString(),
          textScaleFactor: 1.5,
        )),
        Center(
          child: Text(
            key,
            textScaleFactor: 1.5,
          ),
        ),
      ]));
    });

    return true;
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
        body: Stack(children: <Widget>[
          Container(
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
                      const Text(
                        "Results For:",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        selectedStocks.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        "Optimized for " +
                            (targetVolatility != null
                                ? 'volatility target: ${(double.parse(targetVolatility!) * 100).toString()}%'
                                : targetReturn != null
                                    ? 'Target Return: ${(double.parse(targetReturn!) * 100).toString()}%'
                                    : "Sharpe Ratio") +
                            ' with \$$investmentAmount investment',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ])),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            const Text(
                              "Performance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            finished
                                ? Column(children: [
                                    Text(
                                      "Sharpe Ratio: " +
                                          results!.sharpeRatio
                                              .toString()
                                              .substring(0, 4),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "Annual Volatility: " +
                                          results!.annualVolatility
                                              .toString()
                                              .substring(0, 4) +
                                          "%",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "Expected Annual Return: " +
                                          results!.expectedAnnualReturn
                                              .toString()
                                              .substring(0, 4) +
                                          "%",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Center(
                                      child: Text(
                                        "Allocation",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    chartAllocation,
                                  ])
                                : const GFLoader(type: GFLoaderType.circle),
                          ]),
                      SizedBox(
                          width: 300,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Discrete Allocation',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: finished
                                      ? Table(
                                          textDirection: TextDirection.rtl,
                                          // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                          border: TableBorder.all(
                                              width: 2.0,
                                              color: Colors.grey[800]!),
                                          children: [
                                            ...rows,
                                          ],
                                        )
                                      : const GFLoader(
                                          type: GFLoaderType.circle,
                                        ),
                                ),
                              ]))
                    ]),
              ],
            ),
          ),
          Positioned(
              right: 40,
              bottom: 40,
              child: FloatingActionButton(
                heroTag: "btn1",
                elevation: 8,
                tooltip: "Optimization details",
                backgroundColor: Colors.blue,
                child: const Icon(
                  MdiIcons.helpCircle,
                  color: Colors.white,
                ),
                onPressed: () => launchURL(),
              )),
        ]));
  }
}
