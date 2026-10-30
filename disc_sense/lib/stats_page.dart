import 'package:flutter/material.dart';

class _Player {
  final String name;
  final int points;
  final int assists;
  final int turnovers;
  final int blocks;

  _Player({
    required this.name,
    required this.points,
    required this.assists,
    required this.turnovers,
    required this.blocks,
  });
}

class _Game {
  final String opponent;
  final List<_Player> players;

  _Game({required this.opponent, required List<_Player> players})
    : players = List.unmodifiable(players);
}

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
  final List<_Player> _players = [];
  final List<_Game> _games = [];
  bool _isAddingPlayer = false;
  int? _selectedPlayerIndex;

  void _showAddPlayerField() {
    setState(() {
      _isAddingPlayer = true;
      _selectedPlayerIndex = null;
      _playerController.clear();
      _points = 0;
      _assists = 0;
      _turnovers = 0;
      _blocks = 0;
    });
  }

  void _addPlayer() {
    final name = _playerController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a player name first.')),
      );
      return;
    }
    if (_players.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A player with that name already exists.'),
        ),
      );
      return;
    }

    setState(() {
      _players.add(
        _Player(
          name: name,
          points: _points,
          assists: _assists,
          turnovers: _turnovers,
          blocks: _blocks,
        ),
      );
      _playerController.clear();
      _points = 0;
      _assists = 0;
      _turnovers = 0;
      _blocks = 0;
      _isAddingPlayer = false;
    });
  }

  void _selectPlayer(int index) {
    final player = _players[index];
    setState(() {
      _selectedPlayerIndex = index;
      _points = player.points;
      _assists = player.assists;
      _turnovers = player.turnovers;
      _blocks = player.blocks;
    });
  }

  void _saveGame() {
    final opponent = _teamController.text.trim();
    if (opponent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a team or opponent first.')),
      );
      return;
    }
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one player first.')),
      );
      return;
    }

    setState(() {
      _games.add(_Game(opponent: opponent, players: _players));
      _players.clear();
      _teamController.clear();
      _selectedPlayerIndex = null;
      _isAddingPlayer = false;
      _points = 0;
      _assists = 0;
      _turnovers = 0;
      _blocks = 0;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Game stats saved.')));
  }

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

      final selectedIndex = _selectedPlayerIndex;
      if (selectedIndex != null) {
        final player = _players[selectedIndex];
        _players[selectedIndex] = _Player(
          name: player.name,
          points: _points,
          assists: _assists,
          turnovers: _turnovers,
          blocks: _blocks,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game statistics')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 400 ? 8.0 : 20.0;
          final statColumns = constraints.maxWidth < 520 ? 1 : 2;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            children: [
              Text(
                'Game Against',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),
              TextField(
                controller: _teamController,
                decoration: const InputDecoration(
                  labelText: 'Team or opponent',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
              ),
              const SizedBox(height: 16),
              if (_isAddingPlayer) ...[
                TextField(
                  controller: _playerController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Player name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isAddingPlayer ? _addPlayer : _showAddPlayerField,
                icon: const Icon(Icons.person_add_outlined),
                label: Text(
                  _isAddingPlayer ? 'Add player' : 'Add player to game',
                ),
              ),
              if (_players.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Players in game (${_players.length})',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._players.map(
                  (player) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(player.name),
                    onTap: () => _selectPlayer(_players.indexOf(player)),
                    selected: _selectedPlayerIndex == _players.indexOf(player),
                    subtitle: Text(
                      'Pts - ${player.points}  ·  Assists - ${player.assists}  ·  '
                      'Turns - ${player.turnovers}  ·  Blocks - ${player.blocks}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Player Stats (${_selectedPlayerIndex != null ? _players[_selectedPlayerIndex?.toInt() ?? 0].name : "none selected"})',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: statColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: statColumns == 1 ? 3.2 : 1.45,
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
                onPressed: _saveGame,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save game'),
              ),
              if (_games.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Saved games',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._games.map(
                  (game) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.sports),
                      title: Text('vs. ${game.opponent}'),
                      subtitle: Text(
                        '${game.players.length} player(s) recorded',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
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
