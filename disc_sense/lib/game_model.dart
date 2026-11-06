import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'objectbox.g.dart';
import 'bluetooth.dart';

@Entity()
class Player {
  int id = 0; // ObjectBox requires an ID field
  String name;
  int points = 0;
  int assists = 0;
  int turnovers = 0;
  int blocks = 0;

  Player({
    required this.name,
    this.points = 0,
    this.assists = 0,
    this.turnovers = 0,
    this.blocks = 0,
  });
}

@Entity()
class Game {
  int id = 0;
  String opponent;
  final players = ToMany<Player>();
  List<dynamic> timestamps = [];

  Game({required this.opponent});
}

class GameModel {
  late final Store _store;
  late final Box<Game> _gameBox;

  GameModel._create(this._store) {
    _gameBox = _store.box<Game>();
  }

  static Future<GameModel> create() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocDir.path, 'disc_sense_db');
    final store = await openStore(directory: dbPath);
    return GameModel._create(store);
  }

  List<Game> getAllGames() {
    return _gameBox.getAll();
  }

  Game saveGame(String opponent, Iterable<Player> players) {
    final game = Game(opponent: opponent);
    game.players.addAll(players);
    _gameBox.put(game);
    return game;
  }

  void updateGame(Game game, String opponent, Iterable<Player> players) {
    game.opponent = opponent;
    game.players
      ..clear()
      ..addAll(players);
    _gameBox.put(game);
  }

  bool deleteGame(Game game) {
    return _gameBox.remove(game.id);
  }

  void addTimestamp(Game game) {
    game.timestamps.add(BluetoothPeripheral.receiveData());
    _gameBox.put(game);
  }

  void close() {
    _store.close();
  }
}
