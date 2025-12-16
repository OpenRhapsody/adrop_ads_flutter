import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

/// Property & Event Example
///
/// This example demonstrates how to use AdropMetrics to set user properties
/// and log custom events for ad targeting purposes.
class PropertyExample extends StatelessWidget {
  PropertyExample({super.key});

  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  /// Set user gender property using predefined AdropProperties
  /// Call AdropMetrics.setProperty() with predefined property codes
  void setGender(AdropGender gender) {
    AdropMetrics.setProperty(AdropProperties.gender.code, gender.code);
  }

  /// Set user age property using predefined AdropProperties
  void setAge(int age) {
    AdropMetrics.setProperty(AdropProperties.age.code, age.toString());
  }

  /// Set user birth date property using predefined AdropProperties
  void setBirth(String birth) {
    AdropMetrics.setProperty(AdropProperties.birth.code, birth);
  }

  /// Set custom user property
  /// Supports various value types: bool, int, double, String
  void sendProperty(String value) {
    var key = _keyController.text;

    // AdropMetrics.setProperty() accepts different value types
    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      // Set boolean property
      AdropMetrics.setProperty(key, value.toLowerCase() == 'true');
    } else if (int.tryParse(value) != null) {
      // Set integer property
      AdropMetrics.setProperty(key, int.parse(value));
    } else if (double.tryParse(value) != null) {
      // Set double property
      AdropMetrics.setProperty(key, double.parse(value));
    } else {
      // Set string property
      AdropMetrics.setProperty(key, value);
    }

    // Retrieve all properties for verification
    Future.delayed(const Duration(seconds: 1), () async {
      debugPrint("properties: ${await AdropMetrics.properties()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Customizing the leading property to show a back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Navigates back when back button is pressed
            },
          ),
          title: const Text('Property Example'),
        ),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Custom Property"),
                      Row(
                        children: [
                          const Text("Key"),
                          const SizedBox(width: 16),
                          Container(
                              width: 200,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: EditableText(
                                controller: _keyController,
                                focusNode: FocusNode(),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                backgroundCursorColor: Colors.white,
                              )),
                        ],
                      ),
                      Row(children: [
                        const Text("Value"),
                        const SizedBox(width: 16),
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: EditableText(
                            controller: _valueController,
                            focusNode: FocusNode(),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            backgroundCursorColor: Colors.white,
                          ),
                        )
                      ]),
                      TextButton(
                          onPressed: () {
                            sendProperty(_valueController.text);
                          },
                          child: const Text("set property")),
                      const Text("Event"),
                      Column(
                        children: [
                          // Log custom event with AdropMetrics.logEvent()
                          // Event name and parameters map for tracking user actions
                          TextButton(
                              onPressed: () {
                                // Create event parameters map with various value types
                                var params = {
                                  "key1": true,
                                  "key2": 123,
                                  "key3": 1.1,
                                  "key4": "value",
                                  "array": ["123"],
                                  "dictionary": {"1": "1"},
                                  "null": null,
                                  "exp": 1.42e32
                                };
                                debugPrint(
                                    "event key: CustomKey, value: $params");
                                // Call AdropMetrics.logEvent() to track the event
                                AdropMetrics.logEvent("CustomKey", params);
                              },
                              child: const Text(
                                  "send event \nkey: \"CustomKey\", \nvalue: {\n\tkey1: true,\n\tkey2: 123,\n\tkey3: 1.1,\n\tkey4: 'value'\n\t}"))
                        ],
                      )
                    ]))));
  }
}
