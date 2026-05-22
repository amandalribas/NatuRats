import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medal.dart'; // Ajuste o caminho conforme a sua estrutura de pastas

class MedalService {
  // Instância do Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collectionName = 'medals';

  
  Stream<List<Medal>> getMedalsStream() {
    return _firestore
        .collection(_collectionName)
        .snapshots() 
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            
            return Medal.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  
  
  Future<List<Medal>> getMedalsOnce() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
      return querySnapshot.docs.map((doc) {
        return Medal.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Erro ao buscar medalhas: $e");
      return [];
    }
  }
}
