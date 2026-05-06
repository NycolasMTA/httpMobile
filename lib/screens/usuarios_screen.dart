import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _apiService = ApiService();

  List<Usuario> _usuarios = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscarUsuarios();
  }

  Future<void> _buscarUsuarios() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuarios = await _apiService.buscarUsuarios();

      setState(() {
        _usuarios = usuarios;
      });
    } catch (erro) {
      setState(() {
        _erro = 'Nao foi possivel carregar os usuarios.';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios da API'),
        actions: [
          IconButton(
            onPressed: _buscarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando usuarios...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _buscarUsuarios,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(
        child: Text('Nenhum usuario encontrado.'),
      );
    }

    return ListView.separated(
      itemCount: _usuarios.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final usuario = _usuarios[index];

        return ListTile(
          leading: CircleAvatar(
            child: Text(usuario.nome.substring(0, 1)),
          ),
          title: Text(usuario.nome),
          subtitle: Text('${usuario.email}\n${usuario.cidade}'),
          isThreeLine: true,
        );
      },
    );
  }
}