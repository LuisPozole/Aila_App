import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static final String uri = "mongodb+srv://Luis:XahmSNY8h2ykcQEA@aila.ilku2.mongodb.net/Aila";
  static Db? _db;

  static Future<void> connect() async {
    _db = await Db.create(uri);
    await _db!.open();
    print("Conectado a MongoDB");
  }

  static DbCollection getCollection(String collectionName) {
    return _db!.collection(collectionName);
  }

  static Future<void> close() async {
    await _db?.close();
  }
}
