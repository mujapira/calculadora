import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'main.dart';

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({super.key});

  @override
  State<CalculadoraHomePage> createState() => _CalculadoraHomePageState();
}

class _CalculadoraHomePageState extends State<CalculadoraHomePage> {
  String display = '0';
  List<String> historico = [];
  bool abreParenteses = true;

  void atualizarDisplay(String valor) {
    setState(() {
      if (display == '0' && valor != '.') {
        display = valor;
      } else {
        display += valor;
      }
    });
  }

  void aplicarPorcentagem() {
    try {
      final numero = double.parse(display);
      setState(() {
        display = (numero / 100).toString();
      });
    } catch (_) {}
  }

  void alternarSinal() {
    setState(() {
      if (display.startsWith('-')) {
        display = display.substring(1);
      } else if (display != '0') {
        display = '-$display';
      }
    });
  }

  void inserirParenteses() {
    setState(() {
      if (display == '0') display = '';
      display += abreParenteses ? '(' : ')';
      abreParenteses = !abreParenteses;
    });
  }

  void apagarUltimoDigito() {
    setState(() {
      if (display.length <= 1) {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
      }
    });
  }

  void calcularResultado() {
    try {
      final parser = ShuntingYardParser();
      final expression = parser.parse(display.replaceAll('x', '*'));
      ContextModel cm = ContextModel();
      double eval = expression.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        mostrarErro('Erro: operação inválida/impossível.');
        return;
      }

      setState(() {
        String resultadoFormatado = formatarNumero(eval);
        historico.insert(0, "$display = $resultadoFormatado");
        display = resultadoFormatado;
      });
    } catch (_) {
      mostrarErro('Expressão inválida.');
    }
  }

  String formatarNumero(double valor) {
    if (valor % 1 == 0) {
      return valor.toInt().toString();
    }

    String texto = valor.toStringAsFixed(8);
    if (RegExp(
      r"(\d)\1{9,}",
    ).hasMatch(texto.replaceAll('.', '').replaceAll(',', ''))) {
      return valor.toStringAsFixed(9).replaceFirst(RegExp(r'\.?0+$'), '');
    }

    return valor.toStringAsFixed(9).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void limparTudo() {
    setState(() {
      display = '0';
      historico.clear();
    });
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
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
            corTexto ?? Theme.of(context).textTheme.bodyLarge?.color,
        textStyle: const TextStyle(fontSize: 24),
      ),
      child: Text(texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.backspace),
                  onPressed: apagarUltimoDigito,
                  tooltip: 'Apagar último dígito',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2,
                  ),
                  child: Text(
                    historico[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
          const Divider(),
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
