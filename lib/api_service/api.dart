import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MandiSelector extends StatefulWidget {
  @override
  _MandiSelectorState createState() => _MandiSelectorState();
}

class _MandiSelectorState extends State<MandiSelector> {
  List<String> states = [];
  List<String> mandis = [];
  List<Map<String, String>> commodities = [];

  String? selectedState;
  String? selectedMandi;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool isLoadingStates = false;
  bool isLoadingMandis = false;
  bool isLoadingCommodities = false;

  Future<void> fetchStates() async {
    setState(() {
      isLoadingStates = true;
      states = [];
      selectedState = null;
      mandis = [];
      selectedMandi = null;
    });

    final String apiUrl =
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
        "?api-key=579b464db66ec23bdd00000165ae113c04ed4d205c70ec8cf773e87d"
        "&format=json"
        "&filters%5Barrival_date%5D=$selectedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('records') && data['records'] is List) {
          List records = data['records'];

          Set<String> uniqueStates = records
              .map<String>((record) => record['state']?.toString() ?? '')
              .where((state) => state.isNotEmpty)
              .toSet();

          setState(() {
            states = uniqueStates.toList();
            isLoadingStates = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingStates = false;
      });
    }
  }

  Future<void> fetchMandis() async {
    if (selectedState == null) return;

    setState(() {
      isLoadingMandis = true;
      mandis = [];
      selectedMandi = null;
    });

    final String apiUrl =
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
        "?api-key=579b464db66ec23bdd00000165ae113c04ed4d205c70ec8cf773e87d"
        "&format=json"
        "&filters%5Bstate.keyword%5D=${Uri.encodeComponent(selectedState!)}"
        "&filters%5Barrival_date%5D=$selectedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('records') && data['records'] is List) {
          List records = data['records'];

          Set<String> uniqueMandis = records
              .map<String>((record) => record['market']?.toString() ?? '')
              .where((mandi) => mandi.isNotEmpty)
              .toSet();

          setState(() {
            mandis = uniqueMandis.toList();
            isLoadingMandis = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingMandis = false;
      });
    }
  }

  Future<void> fetchCommodities() async {
    if (selectedState == null || selectedMandi == null){
      showToast(
        "Please select all fields",
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.top,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      isLoadingCommodities = true;
      commodities = [];
    });

    final String apiUrl =
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
        "?api-key=579b464db66ec23bdd00000165ae113c04ed4d205c70ec8cf773e87d"
        "&format=json"
        "&filters%5Bstate.keyword%5D=${Uri.encodeComponent(selectedState!)}"
        "&filters%5Bmarket.keyword%5D=${Uri.encodeComponent(selectedMandi!)}"
        "&filters%5Barrival_date%5D=$selectedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('records') && data['records'] is List) {
          List<dynamic> records = data['records'];

          List<Map<String, String>> fetchedCommodities = records.map((record) {
            return {
              "commodity": record['commodity']?.toString() ?? "Unknown",
              "price": record['modal_price']?.toString() ?? "N/A",
            };
          }).toList();

          setState(() {
            commodities = fetchedCommodities;
            isLoadingCommodities = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoadingCommodities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mandi Price Checker")),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.black),
                    title: Text("Select Date: $selectedDate"),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                        fetchStates();
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
          
                // State Dropdown
                isLoadingStates
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.greenAccent,
                          labelText: "Select State",
                        ),
                        value: selectedState,
                        items: states.map((state) {
                          return DropdownMenuItem(value: state, child: Text(state));
                        }).toList(),
                        onChanged: (newState) {
                          setState(() {
                            selectedState = newState;
                          });
                          fetchMandis();
                        },
                      ),
                SizedBox(height: 20),
          
                // Mandi Dropdown
                isLoadingMandis
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.greenAccent,
                          labelText: "Select Mandi",
                        ),
                        value: selectedMandi,
                        items: mandis.map((mandi) {
                          return DropdownMenuItem(value: mandi, child: Text(mandi));
                        }).toList(),
                        onChanged: (newMandi) {
                          setState(() {
                            selectedMandi = newMandi;
                          });
                        },
                      ),
                SizedBox(height: 20),
          
                //ElevatedButton(onPressed: fetchCommodities, child: Text("Get Prices")),
          
          
                ElevatedButton(
                              onPressed: fetchCommodities,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                minimumSize: Size(double.infinity, 0),
                              ),
                              child: Text(
                                'Fetch Data',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
          
          
          
              SizedBox(
                height: 10,
              ),
          
          
                Container(
                  decoration: BoxDecoration(
    color: Colors.green.shade100, // Softer green shade
    borderRadius: BorderRadius.circular(16), // Rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.black26, // Light shadow
        blurRadius: 8,
        offset: Offset(0, 4), // Shadow positioned below
      ),
    ],
  ),
                  height: MediaQuery.of(context).size.height*0.6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Expanded(
                      child: isLoadingCommodities
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: commodities.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.green.shade100,
                                  child: ListTile(
                                    leading: Icon(Icons.shopping_cart, color: Colors.green),
                                    title: Text(
                                      commodities[index]["commodity"]!,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("Price: ₹${commodities[index]["price"]} per Quintal"),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
