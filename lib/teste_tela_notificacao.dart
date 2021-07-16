import 'package:flutter/material.dart';
import 'package:flutter_notificacoes_template/local_notification_manager.dart';

class TesteNotificacao extends StatefulWidget {
  const TesteNotificacao() : super();

  @override
  _TesteNotificacaoState createState() => _TesteNotificacaoState();
}

class _TesteNotificacaoState extends State<TesteNotificacao> {

  String mensagem = "";

  LocalNotificationManager _localNotificationManager = LocalNotificationManager.init();

  @override
  void initState() {
    super.initState();

    _localNotificationManager.setAoReceberNotificacao(aoReceberNotificacao);
    _localNotificationManager.setAoClicarNotificacao(aoClicarNotificacao);
  }

  // Métodos para lidar com as notificações
  aoReceberNotificacao(ReceberNotificacao notificacao) {
    print("Notificação recebida: ${notificacao.id}");
  }

  aoClicarNotificacao(String payload) {
    print("Payload $payload");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            try {
              await _localNotificationManager.mostrarNotificacao(1, "Dicas Ligamentar", "Ajeite a coluna!");
              await _localNotificationManager.mostrarNotificacaoAgendada(2, "Dicas Ligamentar Top", "Ajeite a coluna!");
            } catch (e) {
              setState(() {
                mensagem = e.toString();
              });
            }
          },
          style: TextButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0)
          ),
          child: Text("Enviar Notificação - Resultado:\n$mensagem"),
        ),
      ),
    );
  }
}
