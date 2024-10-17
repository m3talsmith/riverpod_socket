import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@riverpod
class ServerController extends _$ServerController {
  Socket? socket;
  final List<String> messages = [];

  @override
  Stream<List<String>> build() async* {
    if (socket == null) {
      await connect();
    }
    await for (var data in socket!.asBroadcastStream()) {
      messages.add(utf8.decode(data));
      yield messages;
    }
  }

  connect() async {
    socket = await Socket.connect('localhost', 3030);
    socket!.handleError((error) {
      log('socket error: $error');
    });
  }
}

class ServerStream extends ConsumerWidget {
  const ServerStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serverControllerProvider);
    return Scaffold(
      body: state.when(
        data: (data) => ListView(
          children: data.map((e) => Text(e)).toList(),
        ),
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
