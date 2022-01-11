import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:localstorage/localstorage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:stock_analyzer/helpers/fmp_helper.dart';
import 'package:stock_analyzer/model/stock_item.dart';
import 'package:stock_analyzer/model/stock_list.dart';
import 'package:stock_analyzer/pageRoute/custom_route.dart';
import 'package:stock_analyzer/src/pages/childPages/porfolio_opt_results_page.dart';
import 'package:stock_analyzer/widgets/navigation_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioOptimization extends StatefulWidget {
  const PortfolioOptimization({Key? key}) : super(key: key);
  static const routeName = '/portfolio_optimization';

  @override
  PortfolioOptimizationState createState() => PortfolioOptimizationState();
}

class PortfolioOptimizationState extends State<PortfolioOptimization> {
  final StockList stockList = StockList();
  final LocalStorage storage = LocalStorage('stock_app');
  bool initialized = false;
  StockFmpHelper fmpHelper = StockFmpHelper();
  List<String> selectedStocks = [];
  int querySelection = 0;
  final form = FormGroup({
    'investment': FormControl<String>(value: '100000', validators: [
      Validators.required,
      Validators.pattern(RegExp(r'^[1-9][0-9]+$'))
    ]),
    'volatility': FormControl<String>(
        value: '0.15',
        validators: [Validators.pattern(RegExp(r'^[0].[0-9]+$'))]),
    'return': FormControl(
        value: '0.5',
        validators: [Validators.pattern(RegExp(r'^[0].[0-9]+$'))]),
  });

  @override
  void initState() {
    super.initState();
    loadStorage();
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

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(text),
    ));
  }

  void launchURL() async {
    const url =
        'https://github.com/robertmartin8/PyPortfolioOpt#an-overview-of-classical-portfolio-optimization-methods';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showMessage("Failed to launch porfolio optimization page.");
    }
  }

  void updateSelected(List<dynamic> indexes) {
    List<String> temp = indexes.map((e) => stockList.items[e].ticker).toList();
    setState(() {
      selectedStocks = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Optimization'),
      ),
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.purple[900]!, Colors.blue])),
          padding: const EdgeInsets.all(10.0),
          child: ListView(children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              "Query Type",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            GridView.count(
              childAspectRatio: size.width < 900
                  ? (itemWidth / (itemHeight / 2.5))
                  : (itemWidth / itemHeight / 1.4),
              shrinkWrap: true,
              crossAxisCount: size.width < 900 ? 1 : 3,
              children: <Widget>[
                GFCard(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFRadio(
                          type: GFRadioType.basic,
                          size: GFSize.MEDIUM,
                          autofocus: true,
                          value: 0,
                          groupValue: querySelection,
                          onChanged: (int value) {
                            setState(() {
                              querySelection = value;
                            });
                          },
                          inactiveIcon: null,
                          activeBorderColor: Colors.black,
                          radioColor: Colors.blue,
                        ),
                        const Text(
                          " Max Sharpe Ratio",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )),
                GFCard(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFRadio(
                          type: GFRadioType.basic,
                          size: GFSize.MEDIUM,
                          value: 1,
                          groupValue: querySelection,
                          onChanged: (int value) {
                            setState(() {
                              querySelection = value;
                            });
                          },
                          inactiveIcon: null,
                          activeBorderColor: Colors.black,
                          radioColor: Colors.blue,
                        ),
                        const Text(
                          " Target Volatility",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )),
                GFCard(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFRadio(
                          type: GFRadioType.basic,
                          size: GFSize.MEDIUM,
                          value: 2,
                          groupValue: querySelection,
                          onChanged: (int value) {
                            setState(() {
                              querySelection = value;
                            });
                          },
                          inactiveIcon: null,
                          activeBorderColor: Colors.black,
                          radioColor: Colors.blue,
                        ),
                        const Text(
                          " Target Return",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )),
              ],
            ),
            Padding(
              padding: size.width < 900
                  ? EdgeInsets.all(0)
                  : EdgeInsets.fromLTRB(
                      size.width * 0.2, 0, size.width * 0.2, 0),
              child: GFCard(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: querySelection == 0
                      ? size.height * 0.18
                      : size.height * 0.3,
                  content: ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: <Widget>[
                          Wrap(
                            children: [
                              const Text(
                                "Investment Amount: ",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              ReactiveTextField(
                                formControlName: 'investment',
                                validationMessages: (control) => {
                                  'required':
                                      'Investment amount must not be empty',
                                  'pattern': 'Only enter number values'
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: querySelection == 1,
                            child: Wrap(children: [
                              const Text(
                                "Volatility % (in decimal): ",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              ReactiveTextField(
                                formControlName: 'volatility',
                                validationMessages: (control) => {
                                  'pattern': 'Decimal < 1, ex. 0.15 '
                                  // 'volitility': 'The email value must be a valid email'
                                },
                              ),
                            ]),
                          ),
                          Visibility(
                            visible: querySelection == 2,
                            child: Wrap(children: [
                              const Text(
                                "Target return % (in decimal): ",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              ReactiveTextField(
                                formControlName: 'return',
                                validationMessages: (control) =>
                                    {'pattern': 'Decimal < 1, ex. 0.25 '},
                              ),
                            ]),
                          ),
                        ],
                      ))),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              "Select Stock Query Set",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: size.width < 900
                  ? const EdgeInsets.only(left: 10, right: 10)
                  : EdgeInsets.only(
                      left: size.width * 0.3, right: size.width * 0.3),
              child: GFMultiSelect(
                dropdownTitleTileText: "Selected Stocks: ",
                type: GFCheckboxType.circle,
                items: stockList.items.map((stock) => stock.ticker).toList(),
                onSelect: (value) {
                  updateSelected(value);
                },
                dropdownTitleTileColor: Colors.grey[200],
                activeBgColor: Colors.blue[300]!,
                color: Colors.grey[200],
                activeIcon:
                    const Icon(Icons.check, size: 20, color: Colors.black),
                dropdownTitleTileMargin: const EdgeInsets.only(
                    top: 22, left: 18, right: 18, bottom: 5),
                dropdownTitleTilePadding:
                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                dropdownUnderlineBorder:
                    const BorderSide(color: Colors.transparent, width: 2),
                dropdownTitleTileBorder:
                    Border.all(color: Colors.grey[300]!, width: 1),
                dropdownTitleTileBorderRadius: BorderRadius.circular(5),
                expandedIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
                collapsedIcon: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.black54,
                ),
                submitButton: const Text('OK'),
                dropdownTitleTileTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.black54),
                margin: const EdgeInsets.all(6),
                inactiveBorderColor: Colors.grey[200]!,
              ),
            ),
            Padding(
              padding: size.width < 900
                  ? EdgeInsets.only(left: 40, right: 40)
                  : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.4,
                      0, MediaQuery.of(context).size.width * 0.4, 0),
              child: GFButton(
                onPressed: () => {
                  Navigator.of(context).push(FadePageRoute(
                      builder: (context) => querySelection == 0
                          ? PorfolioOptResultsPage(
                              selectedStocks: selectedStocks,
                              investmentAmount:
                                  form.control('investment').value)
                          : querySelection == 1
                              ? PorfolioOptResultsPage(
                                  selectedStocks: selectedStocks,
                                  investmentAmount:
                                      form.control('investment').value,
                                  targetVolatility:
                                      form.control('volatility').value)
                              : PorfolioOptResultsPage(
                                  selectedStocks: selectedStocks,
                                  investmentAmount:
                                      form.control('investment').value,
                                  targetReturn: form.control('return').value)))
                },
                text: "Submit",
                textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                blockButton: true,
                color: Colors.grey[800]!,
                child: const Icon(MdiIcons.arrowRightBold,
                    size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ]),
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
      ]),
      drawer: NavigationDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
