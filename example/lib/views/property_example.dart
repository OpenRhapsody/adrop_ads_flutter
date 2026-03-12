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
            child: SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      const Text("Default Events",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // 1. app_open
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("app_open");
                          },
                          child: const Text("app_open")),

                      // 2. sign_up
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("sign_up", {
                              "method": "google",
                            });
                          },
                          child: const Text("sign_up")),

                      // 3. push_clicks
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("push_clicks", {
                              "campaign_id": "camp-2024-summer",
                            });
                          },
                          child: const Text("push_clicks")),

                      // 4. page_view
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("page_view", {
                              "page_id": "home",
                              "page_category": "main",
                              "page_url": "/home",
                            });
                          },
                          child: const Text("page_view")),

                      // 5. click
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("click", {
                              "element_id": "cta-banner",
                              "element_type": "button",
                              "target_url": "/promo/summer-sale",
                            });
                          },
                          child: const Text("click")),

                      // 6. view_item
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("view_item", {
                              "item_id": "SKU-123",
                              "item_name": "Widget",
                              "item_category": "Electronics",
                              "brand": "BrandX",
                              "price": 29900,
                            });
                          },
                          child: const Text("view_item")),

                      // 7. view_content
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("view_content", {
                              "content_id": "article-456",
                              "content_name": "How to use Adrop SDK",
                              "content_type": "blog_post",
                            });
                          },
                          child: const Text("view_content")),

                      // 8. add_to_wishlist
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("add_to_wishlist", {
                              "item_id": "SKU-789",
                              "item_name": "Gadget Pro",
                              "item_category": "Electronics",
                              "brand": "BrandY",
                              "price": 49900,
                            });
                          },
                          child: const Text("add_to_wishlist")),

                      // 9. add_to_cart
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("add_to_cart", {
                              "item_id": "SKU-123",
                              "item_name": "Widget",
                              "item_category": "Electronics",
                              "brand": "BrandX",
                              "price": 29900,
                              "quantity": 2,
                              "value": 59800,
                              "currency": "KRW",
                            });
                          },
                          child: const Text("add_to_cart")),

                      // 10. begin_lead_form
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("begin_lead_form", {
                              "form_id": "form-1",
                              "form_name": "Contact Us",
                              "form_type": "lead",
                              "form_destination": "sales@example.com",
                            });
                          },
                          child: const Text("begin_lead_form")),

                      // 11. generate_lead
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("generate_lead", {
                              "form_id": "form-1",
                              "form_name": "Contact Us",
                              "form_type": "lead",
                              "form_destination": "sales@example.com",
                              "value": 100,
                              "currency": "KRW",
                            });
                          },
                          child: const Text("generate_lead")),

                      // 12. begin_checkout (with items)
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("begin_checkout", {
                              "currency": "KRW",
                              "items": [
                                {
                                  "item_id": "SKU-001",
                                  "item_name": "상품A",
                                  "price": 29900,
                                  "quantity": 1
                                },
                                {
                                  "item_id": "SKU-002",
                                  "item_name": "상품B",
                                  "price": 15000,
                                  "quantity": 2
                                },
                              ],
                            });
                          },
                          child: const Text("begin_checkout")),

                      // 13. purchase (with items)
                      TextButton(
                          onPressed: () {
                            AdropMetrics.sendEvent("purchase", {
                              "tx_id": "TXN-20240101-001",
                              "currency": "KRW",
                              "items": [
                                {
                                  "item_id": "SKU-001",
                                  "item_name": "상품A",
                                  "item_category": "Electronics",
                                  "brand": "BrandX",
                                  "price": 29900,
                                  "quantity": 1
                                },
                                {
                                  "item_id": "SKU-002",
                                  "item_name": "상품B",
                                  "price": 15000,
                                  "quantity": 2
                                },
                              ],
                            });
                          },
                          child: const Text("purchase")),
                    ]))));
  }
}
