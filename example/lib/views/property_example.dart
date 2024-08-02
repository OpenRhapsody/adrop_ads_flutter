import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

class PropertyExample extends StatelessWidget {
  const PropertyExample({super.key});

  void setGender(AdropGender gender) {
    AdropMetrics.setProperty(AdropProperties.gender.code, gender.code);
  }

  void setAge(int age) {
    AdropMetrics.setProperty(AdropProperties.age.code, age.toString());
  }

  void setBirth(String birth) {
    AdropMetrics.setProperty(AdropProperties.birth.code, birth);
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
                child: Column(children: [
                  const Text("Gender"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            setGender(AdropGender.male);
                          },
                          child: const Text("Male")),
                      TextButton(
                          onPressed: () {
                            setGender(AdropGender.female);
                          },
                          child: const Text("Female")),
                      TextButton(
                          onPressed: () {
                            setGender(AdropGender.other);
                          },
                          child: const Text("Other")),
                      TextButton(
                          onPressed: () {
                            setGender(AdropGender.unknown);
                          },
                          child: const Text("Unknown"))
                    ],
                  ),
                  const Text("Age"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            setAge(18);
                          },
                          child: const Text("18")),
                      TextButton(
                          onPressed: () {
                            setAge(25);
                          },
                          child: const Text("25")),
                      TextButton(
                          onPressed: () {
                            setAge(37);
                          },
                          child: const Text("37")),
                      TextButton(
                          onPressed: () {
                            setAge(45);
                          },
                          child: const Text("45"))
                    ],
                  ),
                  const Text("Birth"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            setBirth("20101111");
                          },
                          child: const Text("20101111")),
                      TextButton(
                          onPressed: () {
                            setBirth("199507");
                          },
                          child: const Text("199507")),
                      TextButton(
                          onPressed: () {
                            setBirth("2000");
                          },
                          child: const Text("2000")),
                    ],
                  ),
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
                            debugPrint("event key: CustomKey, value: $params");
                            AdropMetrics.logEvent("CustomKey", params);
                          },
                          child: const Text(
                              "send event \nkey: \"CustomKey\", \nvalue: {\n\tkey1: true,\n\tkey2: 123,\n\tkey3: 1.1,\n\tkey4: 'value'\n\t}"))
                    ],
                  )
                ]))));
  }
}
