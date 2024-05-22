import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// URL de requisição API HGBrasil
const request = "https://api.hgbrasil.com/finance?format=json&key=f18e82aa";

void main() async {
  runApp(
    const MaterialApp(
      home: Home(),
    ),
  );
}

// Função que retorna um dado futuro
Future<Map> getData() async {
  // Resposta da API
  http.Response response = await http.get(Uri.parse(request));

  // Convertendo resposta para JSON e retornando ela
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double dolar;
  late double euro;

  // controladores dos TextField
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    // resetando os campos se o text estiver vazio
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    // transformando texto em double
    double real = double.parse(text);

    // converter de real para dolar e euro String
    //toStringAsFixed para mostrar apenas a qtd fornecida de casa decimais
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text) {
    // resetando os campos se o text estiver vazio
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    // transformando texto em double
    double dolarText = double.parse(text);

    // converter de dolar para real e euro String
    realController.text = (dolarText * dolar).toStringAsFixed(2);
    euroController.text = (dolarText * dolar / euro).toStringAsFixed(2);
  }
  void _euroChanged(String text) {
    // resetando os campos se o text estiver vazio
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    // transformando texto em double
    double euroText = double.parse(text);

    // converter de euro para real e dolar String
    realController.text = (euroText * euro).toStringAsFixed(2);
    dolarController.text = (euroText * euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      // corpo do aplicativo
      body: FutureBuilder(
        // que futuro que queremos que ele construa
        // iremos mostrar 'Carregando dados' para quando os dados ainda não tiverem sido tragos
        // e caso já tenha, mostrará a tela com os dados
        future: getData(),
        builder: (context, snapshot) {
          // snapshot - uma copia dos dados tragos

          // verificando qual o status da requisição
          switch (snapshot.connectionState) {
            // Cao não esteja conectando em nada
            case ConnectionState.none:
            // caso esteja esperando a conexão
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando Dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            // Caso já tenha os dados
            default:
              // verificando se teve erro na requisição dos dados
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao Carregar Dados :(',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                // Caso não tenha erro

                // Pegando o valores de dola e euro da API
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                // Widget que será construido em tela
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    // irá centralizar o icone, fazendo com que os filhos(children) ocupem toda a largura disponivel em tela
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField('Reais', 'R\$', realController, _realChanged),
                      const SizedBox(height: 10),
                      buildTextField('Dólares', 'US\$', dolarController, _dolarChanged),
                      const SizedBox(height: 10),
                      buildTextField('Euros', '€', euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

// Widget TextField
Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      // borda no TextField
      border: const OutlineInputBorder(),
      // cor da borda quando ela está selecionada
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      // prefixo antes do texto do input
      prefixText: prefix,
      prefixStyle:
      const TextStyle(color: Colors.amber, fontSize: 25),
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    // toda vez que mudar o dado digitado irá chamar a função
    onChanged: function,
    // que tipo de dado será inserido
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
