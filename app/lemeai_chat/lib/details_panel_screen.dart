// ARQUIVO: lib/details_panel_screen.dart

import 'package:flutter/material.dart';
// 1. CORREÇÃO: A importação do 'chat_models.dart' foi removida pois não era utilizada aqui.

// Simulação de um modelo de contato para esta tela
class ContactDetails {
  final String name;
  final String initials;
  final String phone;
  ContactDetails({required this.name, required this.initials, required this.phone});
}

class DetailsPanelScreen extends StatefulWidget {
  final ContactDetails contact;
  const DetailsPanelScreen({super.key, required this.contact});

  @override
  State<DetailsPanelScreen> createState() => _DetailsPanelScreenState();
}

class _DetailsPanelScreenState extends State<DetailsPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAsDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // 2. CORREÇÃO: 'withOpacity' substituído por '.withAlpha()'
        // (alpha 25 é similar a opacity 0.1)
        shadowColor: Colors.grey.withAlpha(25),
        title: const Text('Detalhes do Contato', style: TextStyle(color: Color(0xFF343A40), fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildContactSummary(),
          Container(
            color: const Color(0xFFF8F9FA),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3.0,
              tabs: const [
                Tab(text: 'Detalhes'),
                Tab(text: 'Histórico'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactSummary() {
    // ... (este widget não precisa de alterações)
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(widget.contact.initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Text(widget.contact.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(widget.contact.phone, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailsTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          _buildFormGroup(
            icon: Icons.tag,
            label: "Status da Negociação",
            child: DropdownButtonFormField<String>(
              // 3. CORREÇÃO: 'value' trocado por 'initialValue'
              initialValue: 'negotiating',
              onChanged: (value) => _markAsDirty(),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'not-started', child: Text("Não iniciado")),
                DropdownMenuItem(value: 'negotiating', child: Text("Em negociação")),
                DropdownMenuItem(value: 'deal-won', child: Text("Venda Fechada")),
                DropdownMenuItem(value: 'deal-lost', child: Text("Venda Perdida")),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFormGroup(
            icon: Icons.sticky_note_2_outlined,
            label: "Observações",
            child: TextField(
              maxLines: 5,
              onChanged: (value) => _markAsDirty(),
              decoration: const InputDecoration(
                hintText: "Adicione uma anotação sobre o cliente...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isDirty ? () => setState(() => _isDirty = false) : null,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(_isDirty ? "Salvar Alterações" : "Salvo", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryTab() {
     // ... (este widget não precisa de alterações)
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(25.0),
        children: const [
          _HistoryItem(
            iconColor: Colors.orange,
            title: "Status alterado para Em negociação.",
            time: "Hoje, 10:15",
          ),
          _HistoryItem(
            iconColor: Colors.blue,
            title: "Nota adicionada: 'Cliente pediu para ligar amanhã'.",
            time: "Ontem, 16:45",
          ),
          _HistoryItem(
            iconColor: Colors.green,
            title: "Venda #1234 ganha (R\$ 1.500,00).",
            time: "24 de Jul, 2025",
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormGroup({required IconData icon, required String label, required Widget child}) {
    // ... (este widget não precisa de alterações)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  // ... (este widget não precisa de alterações)
  final Color iconColor;
  final String title;
  final String time;
  const _HistoryItem({required this.iconColor, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF495057), fontSize: 14)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}