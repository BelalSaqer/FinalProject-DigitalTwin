import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/state.dart';
import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appHeader(title: 'Profile', subtitle: 'Account & settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: DT.grad,
                    boxShadow: [BoxShadow(color: DT.blue.alphaF(0.28), blurRadius: 18, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Operator', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('operator@factory.com', style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: DT.surface(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: DT.border(0.45)),
                    ),
                    child: Icon(Icons.edit_rounded, color: DT.cyan, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('Account Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                _KVRow(label: 'Role', value: 'Operator'),
                SizedBox(height: 12),
                _KVRow(label: 'Facility', value: 'Main Plant'),
                SizedBox(height: 12),
                _KVRow(label: 'Access', value: 'Standard'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          GlassCard(
            padding: const EdgeInsets.all(10),
            child: const Column(
              children: [
                _SettingTile(icon: Icons.notifications_rounded, title: 'Notifications', subtitle: 'Manage alert preferences', color: DT.yellow),
                _Divider(),
                _SettingTile(icon: Icons.language_rounded, title: 'Language', subtitle: 'English', color: DT.blue),
                _Divider(),
                _SettingTile(icon: Icons.lock_rounded, title: 'Security', subtitle: 'Change password & PIN', color: DT.purple),
              ],
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.read<AppState>().logout(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: DT.red.alphaF(0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: DT.red.alphaF(0.26)),
              ),
              child: const Center(
                child: Text('Logout', style: TextStyle(color: DT.red, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w600))),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.alphaF(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.alphaF(0.26)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: DT.dim(0.55)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(height: 1, thickness: 1, color: DT.border(0.35));
}