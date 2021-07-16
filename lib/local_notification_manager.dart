import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:io' show Platform;
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz3;

class LocalNotificationManager {
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static late var configuracoesGerais;
  BehaviorSubject<ReceberNotificacao> get didRecebeuNotificacao =>
      BehaviorSubject<ReceberNotificacao>();

  LocalNotificationManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Verificando sobre as diferentes plataformas
    if (Platform.isIOS) {
      requestIOSPermission();
    }

    inicializandoPlataforma();
  }

  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  inicializandoPlataforma() {
    var configuracoesAndroid = AndroidInitializationSettings("sotuna");
    var configuracoesIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, titulo, body, payload) async {
          ReceberNotificacao notificacao = ReceberNotificacao(
              id: id, titulo: titulo, corpo: body, payload: payload);

          didRecebeuNotificacao.add(notificacao);
        });

    configuracoesGerais = InitializationSettings(
        android: configuracoesAndroid, iOS: configuracoesIOS);
  }

  setAoReceberNotificacao(Function aoReceberNotificacao) {
    didRecebeuNotificacao.listen((notificacao) {
      aoReceberNotificacao(notificacao);
    });
  }

  setAoClicarNotificacao(Function aoClicarNotificacao) async {
    await flutterLocalNotificationsPlugin.initialize(configuracoesGerais,
        onSelectNotification: (String? payload) async {
      aoClicarNotificacao(payload);
    });
  }

  Future<void> mostrarNotificacao(
      int id, String dicas, String descricao) async {
    var canalAndroid = AndroidNotificationDetails("ID_CANAL", "CANAL", "DESC",
        importance: Importance.max, priority: Priority.high, playSound: true);
    var canalIOS = IOSNotificationDetails();
    var canalPlataforma =
        NotificationDetails(android: canalAndroid, iOS: canalIOS);

    // Mostrando a notificação push
    await flutterLocalNotificationsPlugin
        .show(id, dicas, descricao, canalPlataforma, payload: "Novo Payload");
  }

  Future<void> _configureLocalTimeZone() async {
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz3.setLocalLocation(tz3.getLocation(timeZoneName!));
  }

  // Verificando a próxima instancia do horário de 10 da manhã
  tz3.TZDateTime _proximaInstancia15PM() {
    final tz3.TZDateTime now = tz3.TZDateTime.now(tz3.local);
    tz3.TZDateTime scheduledDate =
        tz3.TZDateTime(tz3.local, now.year, now.month, now.day, 15, 52);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Verificando a próxima instância do horário 10 da manhã de segunda
  tz3.TZDateTime _proximaInstanciade15PMSegunda() {
    tz3.TZDateTime scheduledDate = _proximaInstancia15PM();
    // Procura até ser a próxima segunda
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> mostrarNotificacaoAgendada(
      int id, String dicas, String descricao) async {
    var canalAndroid = AndroidNotificationDetails("ID_CANAL", "CANAL", "DESC",
        importance: Importance.max, priority: Priority.high, playSound: true);
    var canalIOS = IOSNotificationDetails();
    var canalPlataforma =
        NotificationDetails(android: canalAndroid, iOS: canalIOS);

    // Mostrando a notificação push
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, dicas, descricao, _proximaInstanciade15PMSegunda(), canalPlataforma,
        payload: "Novo Payload",
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }
}

class ReceberNotificacao {
  final int id;
  final String? titulo;
  final String? corpo;
  final String? payload;
  ReceberNotificacao(
      {required this.id,
      required this.titulo,
      required this.corpo,
      required this.payload});
}
