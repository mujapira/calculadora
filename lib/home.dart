import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({Key? key}) : super(key: key);

  @override
  State<CalculadoraHomePage> createState() => _CalculadoraHomePageState();
}

class _CalculadoraHomePageState extends State<CalculadoraHomePage> {
  String display = "0";
  String historico = "";
  String resultado = "0";
}
