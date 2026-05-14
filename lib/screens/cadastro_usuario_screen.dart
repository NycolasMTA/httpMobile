import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  final Usuario? usuarioParaEditar;
  
  const CadastroUsuarioScreen({super.key, this.usuarioParaEditar});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _websiteController = TextEditingController();
  
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  
  bool _salvando = false;
  bool _modoEdicao = false;
  int _corAtual = 0;
  
  final List<Color> _coresMisticas = [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();
    _verificarModoEdicao();
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _animController.forward();
    _animarCores();
  }
  
  void _animarCores() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _corAtual = (_corAtual + 1) % _coresMisticas.length);
        _animarCores();
      }
    });
  }

  void _verificarModoEdicao() {
    if (widget.usuarioParaEditar != null) {
      _modoEdicao = true;
      _nomeController.text = widget.usuarioParaEditar!.nome;
      _emailController.text = widget.usuarioParaEditar!.email;
      _cidadeController.text = widget.usuarioParaEditar!.cidade;
      _telefoneController.text = widget.usuarioParaEditar!.telefone ?? '';
      _websiteController.text = widget.usuarioParaEditar!.website ?? '';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _telefoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final usuario = Usuario(
      id: _modoEdicao ? widget.usuarioParaEditar!.id : 0,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cidade: _cidadeController.text.trim(),
      telefone: _telefoneController.text.trim().isNotEmpty 
          ? _telefoneController.text.trim() : null,
      website: _websiteController.text.trim().isNotEmpty 
          ? _websiteController.text.trim() : null,
    );

    try {
      if (_modoEdicao) {
        await ApiService.atualizarUsuario(usuario);
        _mostrarMensagem('✨ Herói atualizado com sucesso! ✨', sucesso: true);
      } else {
        await ApiService.criarUsuario(usuario);
        _mostrarMensagem('🎉 Novo herói cadastrado! 🎉', sucesso: true);
      }

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('💥 ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String msg, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(sucesso ? Icons.celebration : Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 14))),
        ]),
        backgroundColor: sucesso ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        _buildBackgroundAnimado(),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(children: [
                _buildHeaderVidraceiro(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        _buildAvatarCosmico(),
                        const SizedBox(height: 32),
                        _buildCampoNeon(
                          controller: _nomeController,
                          label: 'Nome do Herói',
                          icon: Icons.auto_awesome,
                          validator: (v) => v == null || v.trim().isEmpty ? '⚡ Digite um nome heroico!' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildCampoNeon(
                          controller: _emailController,
                          label: 'E-mail Cósmico',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '📧 Precisa de um e-mail!';
                            if (!v.contains('@')) return '🔮 E-mail mágico precisa de @';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildCampoNeon(
                          controller: _cidadeController,
                          label: 'Base Secreta',
                          icon: Icons.location_city,
                          validator: (v) => v == null || v.trim().isEmpty ? '🏙️ Onde é sua base?' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildCampoNeon(
                          controller: _telefoneController,
                          label: 'Contato Heroico',
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 20),
                        _buildCampoNeon(
                          controller: _websiteController,
                          label: 'Site da Aventura',
                          icon: Icons.language,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 40),
                        _buildBotoesCosmicos(),
                        const SizedBox(height: 30),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildBackgroundAnimado() {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _coresMisticas[_corAtual],
            _coresMisticas[(_corAtual + 1) % _coresMisticas.length],
            const Color(0xFF1E1B4B),
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
    );
  }

  Widget _buildHeaderVidraceiro() {
    return ClipRRect(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ]),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _modoEdicao ? '✏️ Editar Herói' : '🌟 Novo Herói',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(0, 2), blurRadius: 10, color: Colors.black26)],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAvatarCosmico() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const RadialGradient(colors: [Colors.white, Colors.white70], radius: 1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _coresMisticas[_corAtual].withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _modoEdicao ? Icons.edit_note : Icons.person_add_alt_1,
              size: 60,
              color: _coresMisticas[_corAtual],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampoNeon({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _coresMisticas[_corAtual]),
          prefixIcon: Icon(icon, color: _coresMisticas[_corAtual]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildBotoesCosmicos() {
    return Row(children: [
      Expanded(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, double value, child) => Transform.scale(
            scale: value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _salvando ? null : () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('Cancelar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, double value, child) => Transform.scale(
            scale: value,
            child: ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_coresMisticas[_corAtual], _coresMisticas[(_corAtual + 1) % _coresMisticas.length]]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _salvando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Text(_modoEdicao ? 'Atualizar ✨' : 'Criar 🚀', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}