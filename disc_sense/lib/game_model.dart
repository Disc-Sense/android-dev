import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:objectbox/objectbox.dart'; // Import ObjectBox package

@Entity()
class Player {
  int id = 0; // ObjectBox requires an ID field
  String name;
  int points = 0;
  int assists = 0;
  int turnovers = 0;
  int blocks = 0;

  Player({required this.name});
}

class GameModel {
  late final Store _store;
  late final Box<Player> _playerBox;

  GameModel._create(this._store) {
    _playerBox = _store.box<Player>();
  }

/*
  static Future<GameModel> create() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocDir.path, 'disc_sense_db');
    final store = await openStore(directory: dbPath);
    return GameModel._create(store);
  }
*/
  void addPlayer(String name) {
    final player = Player(name: name);
    _playerBox.put(player);
  }

  List<Player> getAllPlayers() {
    return _playerBox.getAll();
  }

  void close() {
    _store.close();
  }
}
