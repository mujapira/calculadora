import 'package:calculadora/main.dart';
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

  Widget botao(
    String texto, {
    Color? corTexto,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            corTexto ?? Theme.of(context).textTheme.bodyLarge!.color,
        textStyle: const TextStyle(fontSize: 24),
      ),
      child: Text(texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.value =
                  themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  display,
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  historico,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Histórico",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(historico, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                botao('C', corTexto: Colors.red, onPressed: limparTudo),
                botao('()', onPressed: inserirParenteses),
                botao('%', onPressed: aplicarPorcentagem),
                botao('/', onPressed: () => atualizarDisplay('/')),
                botao('7', onPressed: () => atualizarDisplay('7')),
                botao('8', onPressed: () => atualizarDisplay('8')),
                botao('9', onPressed: () => atualizarDisplay('9')),
                botao('x', onPressed: () => atualizarDisplay('x')),
                botao('4', onPressed: () => atualizarDisplay('4')),
                botao('5', onPressed: () => atualizarDisplay('5')),
                botao('6', onPressed: () => atualizarDisplay('6')),
                botao('-', onPressed: () => atualizarDisplay('-')),
                botao('1', onPressed: () => atualizarDisplay('1')),
                botao('2', onPressed: () => atualizarDisplay('2')),
                botao('3', onPressed: () => atualizarDisplay('3')),
                botao('+', onPressed: () => atualizarDisplay('+')),
                botao('+/-', onPressed: alternarSinal),
                botao('0', onPressed: () => atualizarDisplay('0')),
                botao('.', onPressed: () => atualizarDisplay('.')),
                botao(
                  '=',
                  corTexto: Colors.green,
                  onPressed: calcularResultado,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
