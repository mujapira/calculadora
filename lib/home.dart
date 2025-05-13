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
  bool abreParenteses = true;

  void atualizarDisplay(String valor) {
    setState(() {
      if (display == "0" && valor != ".") {
        display = valor;
      } else {
        display += valor;
      }
    });
  }

  void aplicarPorcentagem() {
    setState(() {
      try {
        final numero = double.parse(display);
        setState(() {
          display = (numero / 100).toString();
        });
      } catch (_) {}
    });
  }

  void alternarSinal() {
    setState(() {
      if (display.startsWith('-')) {
        display = display.substring(1);
      } else if (display != "0") {
        display = "-$display";
      }
    });
  }

  void inserirParenteses() {
    setState(() {
      if (display == "0") display = "";
      display += abreParenteses ? "(" : ")";
      abreParenteses = !abreParenteses;
    });
  }

  void calcularResultado() {
    setState(() {
      try {
        final parser = ShuntingYardParser();
        final expression = parser.parse(display.replaceAll('x', '*'));
        ContextModel cm = ContextModel();
        double eval = expression.evaluate(EvaluationType.REAL, cm);
        setState(() {
          historico = display;
          display = eval.toString();
        });
      } catch (e) {
        mostrarErro('Expressão inválida');
      }
    });
  }

  void limparTudo() {
    setState(() {
      display = "0";
      historico = "";
      abreParenteses = true;
    });
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: Center(child: Text(display, style: const TextStyle(fontSize: 48))),
    );
  }
}
