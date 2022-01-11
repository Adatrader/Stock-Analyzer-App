import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getwidget/getwidget.dart';
import 'package:localstorage/localstorage.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:stock_analyzer/helpers/fmp_helper.dart';
import 'package:stock_analyzer/model/fmp_stock.dart';
import 'package:stock_analyzer/model/stock_item.dart';
import 'package:stock_analyzer/model/stock_list.dart';
import 'package:stock_analyzer/src/pages/stock_details.dart';
import 'package:stock_analyzer/widgets/navigation_drawer.dart';
import '../settings/settings_view.dart';
import 'package:stock_analyzer/pageRoute/custom_route.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/homepage';
  const HomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final StockList stockList = StockList();
  final LocalStorage storage = LocalStorage('stock_app');
  bool initialized = false;
  bool showSearch = false;
  StockFmpHelper fmpHelper = StockFmpHelper();
  List<Widget> suggestions = [];
  // TODO: Hit batch
  late Map<String, List<double>> stockPrices;

  void addStock(String ticker, String companyName) {
    var item = StockItem(ticker: ticker, companyName: companyName);
    bool contain = false;
    for (StockItem stock in stockList.items) {
      if (stock.ticker == item.ticker) {
        contain = true;
        showMessage("$ticker already in watchlist.");
      }
    }
    if (!contain) {
      showMessage("Added $ticker to watchlist.");
      setState(() {
        stockList.items.add(item);
        stockList.items
            .sort((stock1, stock2) => stock1.ticker.compareTo(stock2.ticker));
        _saveToStorage();
      });
    } else {
      setState(() {});
    }
    FocusManager.instance.primaryFocus?.unfocus();
    suggestions = [];
    showSearch = false;
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(text),
    ));
  }

  void _saveToStorage() {
    storage.setItem('stocks', stockList.toJSONEncodable());
  }

  void _clearStorage() async {
    await storage.clear();

    setState(() {
      stockList.items = storage.getItem('stocks') ?? [];
    });
  }

  Widget getStockList(BuildContext context) {
    return FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: GFLoader(type: GFLoaderType.circle),
            );
          }
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
              )..sort(
                  (stock1, stock2) => stock1.ticker.compareTo(stock2.ticker));
            }
            initialized = true;
          }
          List<Slidable> stockListWidgets = stockList.items.map((item) {
            return Slidable(
                // Specify a key if the Slidable is dismissible.
                key: Key(item
                    .ticker), // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  extentRatio:
                      MediaQuery.of(context).size.width > 800 ? 0.15 : 0.30,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        stockList.items.removeWhere((element) {
                          return element.ticker == item.ticker;
                        });
                        _saveToStorage();
                        setState(() {});
                        // deleteStock(item);
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: SizedBox(
                    height: 70,
                    child: GFListTile(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        titleText: item.ticker,
                        color: Colors.white,
                        avatar: GFAvatar(
                          backgroundColor: Colors.grey[200],
                          size: GFSize.SMALL,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: ExtendedImage.network(
                              'https://financialmodelingprep.com/image-stock/${item.ticker}.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        subTitle: Flexible(
                          child: Text(item.companyName,
                              style: TextStyle(color: Colors.black)),
                        ),
                        onTap: () {
                          // Navigate to the details page. If the user leaves and returns to
                          // the app after it has been killed while running in the
                          // background, the navigation stack is restored.
                          Navigator.of(context).push(FadePageRoute(
                              builder: (context) =>
                                  StockDetails(item.ticker, item.companyName)));
                        })));
          }).toList();
          return ListView(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width > 800
                    ? MediaQuery.of(context).size.width * 0.15
                    : 10,
                20,
                MediaQuery.of(context).size.width > 800
                    ? MediaQuery.of(context).size.width * 0.15
                    : 10,
                20),
            children: stockListWidgets,
          );
        });
  }

  List<Widget> buildSuggestions(BuildContext context, List<FmpStock> result) {
    List<Widget> newSuggestions = [];
    for (FmpStock stock in result) {
      newSuggestions.add(
        ListTile(
          title: Text(
            '${stock.symbol} - ${stock.name}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(color: Colors.black),
          ),
          onTap: () => {
            addStock(stock.symbol, stock.name),
          },
        ),
      );
    }
    return newSuggestions;
  }

  Widget searchWidget() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Visibility(
      visible: showSearch,
      child: FloatingSearchBar(
        hint: 'Search for stock..',
        implicitDuration: const Duration(milliseconds: 100),
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: const Duration(milliseconds: 800),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        automaticallyImplyDrawerHamburger: false,
        automaticallyImplyBackButton: false,
        axisAlignment: 0.0,
        openAxisAlignment: 0.0,
        width: isPortrait ? 600 : 500,
        debounceDelay: const Duration(milliseconds: 200),
        onQueryChanged: (query) {
          if (query == '') {
            suggestions = [];
          } else {
            // Call your model, bloc, controller here.
            fmpHelper.getSearchResult(query).then((List<FmpStock> data) {
              setState(() {
                suggestions = buildSuggestions(context, data);
              });
            });
          }
        },
        transition: CircularFloatingSearchBarTransition(),
        actions: [
          FloatingSearchBarAction(
            showIfOpened: false,
            child: CircularButton(
              icon: const Icon(Icons.add_chart),
              onPressed: () {},
            ),
          ),
          FloatingSearchBarAction.searchToClear(
            showIfClosed: false,
          ),
        ],
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: suggestions,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
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
            child: getStockList(context),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              elevation: 8,
              highlightElevation: 100,
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                });
              },
              child: Icon(
                showSearch ? Icons.close : Icons.add,
                size: 30,
              ),
              backgroundColor: Colors.blue,
            ),
          ),
          searchWidget(),
        ],
      ),
      drawer: NavigationDrawer(),
    );
  }
}
