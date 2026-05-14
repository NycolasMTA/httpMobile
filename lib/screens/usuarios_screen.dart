import 'dart:math';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import 'cadastro_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen>
    with SingleTickerProviderStateMixin {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _carregando = true;
  bool _modoGrid = false;
  String? _erro;
  String _termoBusca = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _animarCorIndex = 0;
  
  final List<Color> _coresGalaxia = [
    const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF312E81),
    const Color(0xFF4C1D95), const Color(0xFF701A75), const Color(0xFF831843),
  ];

  List<Usuario> get _usuariosExibidos {
    if (_termoBusca.isEmpty) return _usuarios;
    return _usuarios.where((u) =>
      u.nome.toLowerCase().contains(_termoBusca.toLowerCase()) ||
      u.email.toLowerCase().contains(_termoBusca.toLowerCase()) ||
      u.cidade.toLowerCase().contains(_termoBusca.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _animarCoresGalaxia();
  }

  void _animarCoresGalaxia() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _animarCorIndex = (_animarCorIndex + 1) % _coresGalaxia.length);
        _animarCoresGalaxia();
      }
    });
  }

  Future<void> _carregarUsuarios() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final usuarios = await ApiService.buscarUsuarios();
      setState(() => _usuarios = usuarios);
    } catch (e) {
      setState(() => _erro = '🌌 Erro cósmico ao carregar heróis!');
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _confirmarExclusao(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 70, color: Colors.amber),
            const SizedBox(height: 20),
            Text('Excluir ${usuario.nome}?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Esta ação não pode ser desfeita!', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
              )),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Excluir', style: TextStyle(color: Colors.white)),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmar != true) return;
    try {
      await ApiService.deletarUsuario(usuario.id);
      setState(() => _usuarios.removeWhere((i) => i.id == usuario.id));
      _mostrarMensagem('🗑️ ${usuario.nome} foi removido!', sucesso: true);
    } catch (e) {
      _mostrarMensagem('❌ Erro na exclusão');
    }
  }

  void _mostrarMensagem(String msg, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(sucesso ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: sucesso ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    final atualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CadastroUsuarioScreen(usuarioParaEditar: usuario)),
    );
    if (atualizado == true) await _carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_coresGalaxia[_animarCorIndex], _coresGalaxia[(_animarCorIndex + 1) % _coresGalaxia.length], const Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(children: [
              _buildHeaderGalactico(),
              _buildBarraBuscaGalactica(),
              Expanded(child: _buildCorpoEstelar()),
            ]),
          ),
        ),
      ),
      floatingActionButton: _buildBotaoCosmico(),
    );
  }

  Widget _buildHeaderGalactico() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Constelação Heroica', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0, 2), blurRadius: 10)]))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.star, size: 18, color: Colors.amber.shade400),
          const SizedBox(width: 8),
          Text('${_usuariosExibidos.length} Heróis Cadastrados', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          IconButton(
            icon: Icon(_modoGrid ? Icons.list : Icons.grid_view, color: Colors.white),
            onPressed: () => setState(() => _modoGrid = !_modoGrid),
          ),
        ]),
      ]),
    );
  }

  Widget _buildBarraBuscaGalactica() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _termoBusca = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '🔭 Buscar herói cósmico...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _termoBusca.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.white70), onPressed: () => setState(() => _termoBusca = '')) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCorpoEstelar() {
    if (_carregando) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 2 * pi),
          duration: const Duration(seconds: 2),
          builder: (_, double angulo, __) => Transform.rotate(
            angle: angulo,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(gradient: const RadialGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]),
              child: const Center(child: Icon(Icons.auto_awesome, color: Colors.white, size: 30)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Carregando heróis...', style: TextStyle(color: Colors.white70, fontSize: 16)),
      ]));
    }
    if (_erro != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 80, color: Colors.white54),
        const SizedBox(height: 16),
        Text(_erro!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: _carregarUsuarios, icon: const Icon(Icons.refresh), label: const Text('Tentar Novamente'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      ]));
    }
    if (_usuariosExibidos.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(_termoBusca.isEmpty ? '✨ Nenhum herói encontrado ✨' : '🔍 Nenhum resultado para "$_termoBusca"', style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ]));
    }
    return _modoGrid ? _buildGridView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _usuariosExibidos.length,
      itemBuilder: (context, index) => _buildCardHeroi(_usuariosExibidos[index]),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: _usuariosExibidos.length,
      itemBuilder: (context, index) => _buildCardHeroiGrid(_usuariosExibidos[index]),
    );
  }

  Widget _buildCardHeroi(Usuario usuario) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (usuario.id * 50)),
      builder: (context, double value, child) => Transform.scale(
        scale: value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [usuario.corPrincipal.withOpacity(0.2), usuario.corSecundaria.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: usuario.corPrincipal.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _editarUsuario(usuario),
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  _buildAvatarHeroi(usuario),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(usuario.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(children: [Icon(Icons.email, size: 14, color: Colors.white70), const SizedBox(width: 4), Expanded(child: Text(usuario.emailMascarado, style: const TextStyle(fontSize: 12, color: Colors.white70)))]),
                    const SizedBox(height: 2),
                    Row(children: [Icon(Icons.location_city, size: 14, color: Colors.white70), const SizedBox(width: 4), Text(usuario.cidade, style: const TextStyle(fontSize: 12, color: Colors.white70))]),
                  ])),
                  Column(children: [
                    IconButton(icon: Icon(Icons.edit, color: usuario.corPrincipal), onPressed: () => _editarUsuario(usuario)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _confirmarExclusao(usuario)),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeroiGrid(Usuario usuario) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (usuario.id * 50)),
      builder: (context, double value, child) => Transform.scale(
        scale: value,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [usuario.corPrincipal.withOpacity(0.3), usuario.corSecundaria.withOpacity(0.2)]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: usuario.corPrincipal.withOpacity(0.4), width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _editarUsuario(usuario),
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildAvatarHeroi(usuario, tamanho: 70),
                  const SizedBox(height: 12),
                  Text(usuario.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(usuario.cidade, style: const TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(icon: Icon(Icons.edit, size: 20, color: usuario.corPrincipal), onPressed: () => _editarUsuario(usuario), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    const SizedBox(width: 16),
                    IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () => _confirmarExclusao(usuario), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarHeroi(Usuario usuario, {double tamanho = 50}) {
    return Container(
      width: tamanho, height: tamanho,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [usuario.corPrincipal, usuario.corSecundaria]),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: usuario.corPrincipal.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Center(child: Icon(usuario.iconePersonalizado, color: Colors.white, size: tamanho * 0.5)),
    );
  }

  Widget _buildBotaoCosmico() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final criou = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => const CadastroUsuarioScreen()));
        if (criou == true) await _carregarUsuarios();
      },
      icon: const Icon(Icons.add),
      label: const Text('Novo Herói'),
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}