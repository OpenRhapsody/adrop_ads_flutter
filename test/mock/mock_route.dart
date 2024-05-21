import 'package:flutter/material.dart';

class MockRoute extends Route {
  MockRoute({required String name}) : super(settings: RouteSettings(name: name));
}
