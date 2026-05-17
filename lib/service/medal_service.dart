import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medal.dart'; // Ajuste o caminho conforme a sua estrutura de pastas

class MedalService {
  // Instância do Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collectionName = 'medals';

  // Retorna um Stream de uma lista de Medalhas.
  // O Stream escuta o Firestore em tempo real. Se qualquer dado mudar lá,
  // a tela atualizará sozinha automaticamente.
  Stream<List<Medal>> getMedalsStream() {
    return _firestore
        .collection(_collectionName)
        .snapshots() // Tira uma "foto" em tempo real da coleção
        .map((snapshot) {
          // Mapeia cada documento retornado para o nosso modelo Medal
          return snapshot.docs.map((doc) {
            // Passamos o doc.id (gerado automaticamente) e os dados do corpo (doc.data())
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
