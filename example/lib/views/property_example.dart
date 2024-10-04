import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

class PropertyExample extends StatelessWidget {
  PropertyExample({super.key});

  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  void setGender(AdropGender gender) {
    AdropMetrics.setProperty(AdropProperties.gender.code, gender.code);
  }

  void setAge(int age) {
    AdropMetrics.setProperty(AdropProperties.age.code, age.toString());
  }

  void setBirth(String birth) {
    AdropMetrics.setProperty(AdropProperties.birth.code, birth);
  }

  void sendProperty(String value) {
    var key = _keyController.text;

    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      AdropMetrics.setProperty(key, value.toLowerCase() == 'true');
    } else if (int.tryParse(value) != null) {
      AdropMetrics.setProperty(key, int.parse(value));
    } else if (double.tryParse(value) != null) {
      AdropMetrics.setProperty(key, double.parse(value));
    } else {
      AdropMetrics.setProperty(key, value);
    }
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
                          TextButton(
                              onPressed: () {
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
                                AdropMetrics.logEvent("CustomKey", params);
                              },
                              child: const Text(
                                  "send event \nkey: \"CustomKey\", \nvalue: {\n\tkey1: true,\n\tkey2: 123,\n\tkey3: 1.1,\n\tkey4: 'value'\n\t}"))
                        ],
                      )
                    ]))));
  }
}
