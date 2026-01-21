import 'package:flutter/material.dart';
import 'package:postman/views/login_view.dart';
import 'package:postman/views/register_user_view.dart';
import 'package:postman/views/dashboard.dart';
void main() { 
runApp(MaterialApp( 
  debugShowCheckedModeBanner: false,
initialRoute: '/login', 
routes: { 
'/': (context) => RegisterUserView(), 
'/login': (context) => LoginView(),
'/dashboard': (context) => DashboardView(),
}, 
)); 
} 