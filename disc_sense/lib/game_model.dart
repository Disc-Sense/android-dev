import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart';

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

  Game({required this.opponent});
}

// class for holding data received from the PI for each game
@Entity()
class Timestamps {
  dynamic data;
  Timestamps();
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

  void close() {
    _store.close();
  }
}
