import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _textEditingController = TextEditingController();
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  _salvarTarefa() {
    String textoDigitado = _textEditingController.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _textEditingController.text = "";
  }

  Widget _criarItemTarefa(context, index) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]["titulo"]),
        value: _listaTarefas[index]["realizada"],
        onChanged: (valor) {
          setState(() {
            _listaTarefas[index]["realizada"] = valor;
          });
        },
      ),
      onDismissed: (direcao) {
        //Recuperando a ultima  tarefa removida
        _ultimaTarefaRemovida = _listaTarefas[index];

        //removendo a tarefa atual
        setState(() {
          _listaTarefas.removeAt(index);
        });
        _salvarArquivo();

        final snackbar = SnackBar(
          content: Text("Tarefa removida!"),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                //recupera
                _listaTarefas.insert(index, _ultimaTarefaRemovida);
              });
              //salva
              _salvarArquivo();
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // esse metodo carrega antes do build
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: _criarItemTarefa,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: CircularNotchedRectangle(),
        child: Row(
          children: [Padding(padding: EdgeInsets.all(25))],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar tarefa!"),
                  content: TextField(
                    controller: _textEditingController,
                    decoration:
                        InputDecoration(labelText: "Adicione sua tarefa!"),
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar")),
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            _salvarTarefa();
                          });

                          Navigator.pop(context);
                        },
                        child: Text("Salvar")),
                  ],
                );
              });
        },
      ),
    );
  }
}
