import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _playerController = TextEditingController();
  final _teamController = TextEditingController();
  int _points = 0;
  int _assists = 0;
  int _turnovers = 0;
  int _blocks = 0;

  @override
  void dispose() {
    _playerController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  void _changeStat(String stat, int amount) {
    setState(() {
      switch (stat) {
        case 'points':
          _points = (_points + amount).clamp(0, 99).toInt();
        case 'assists':
          _assists = (_assists + amount).clamp(0, 99).toInt();
        case 'turnovers':
          _turnovers = (_turnovers + amount).clamp(0, 99).toInt();
        case 'blocks':
          _blocks = (_blocks + amount).clamp(0, 99).toInt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game statistics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'New game',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _playerController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Player name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teamController,
            decoration: const InputDecoration(
              labelText: 'Team or opponent',
              prefixIcon: Icon(Icons.groups_outlined),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Live stats',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _StatCounter(
                label: 'Points',
                value: _points,
                icon: Icons.flag_outlined,
                onDecrease: () => _changeStat('points', -1),
                onIncrease: () => _changeStat('points', 1),
              ),
              _StatCounter(
                label: 'Assists',
                value: _assists,
                icon: Icons.handshake_outlined,
                onDecrease: () => _changeStat('assists', -1),
                onIncrease: () => _changeStat('assists', 1),
              ),
              _StatCounter(
                label: 'Turnovers',
                value: _turnovers,
                icon: Icons.sync_problem_outlined,
                onDecrease: () => _changeStat('turnovers', -1),
                onIncrease: () => _changeStat('turnovers', 1),
              ),
              _StatCounter(
                label: 'Blocks',
                value: _blocks,
                icon: Icons.shield_outlined,
                onDecrease: () => _changeStat('blocks', -1),
                onIncrease: () => _changeStat('blocks', 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game stats saved.')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save game'),
          ),
        ],
      ),
    );
  }
}

class _StatCounter extends StatelessWidget {
  const _StatCounter({
    required this.label,
    required this.value,
    required this.icon,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: value == 0 ? null : onDecrease,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: onIncrease,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
