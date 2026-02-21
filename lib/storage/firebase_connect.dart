import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbConnect {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference usersCollection = firestore.collection('chalthee');

  // Add a new document with an auto-generated ID
  void addProduct(Map<String, dynamic> encodedString) async {
    final uuid = await DeviceMapper().getUuid();
    print("uuid in dbconnect = $uuid");
    bool ableToSync = true;
    try{
      await usersCollection.doc(uuid).set(encodedString);
    }catch(e){
      ableToSync = false;
    }
    finally{
      DeviceMapper().changeSyncStatus(ableToSync);
    }
  }

// Fetch all documents from a collection
  Future<Object?> getProductsByUuid(String uuid) async {
    final docSnapshot = await usersCollection.doc(uuid).get();
    return docSnapshot.data();
  }

    Future<Map<String, dynamic>?> getProductsByUserMail(String mailId) async {
      final querySnapshot = await usersCollection.get();
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('users')) {
          final List users = data['users'];
          for (var user in users) {
            final Map<String, dynamic> userMap = user as Map<String, dynamic>;
            if (userMap['usermail'] == mailId) {
              return {
                "docId" : doc.id,
                "user": userMap
              };
            }
          }
        }
      }
      return null;
    }

  Future<Map<String, dynamic>?> getProductsByMail(String username) async {
    try {
      final querySnapshot = await usersCollection.get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        final List<dynamic> users = data['users'] ?? [];
        final matchedUser = users.cast<Map<String, dynamic>?>().firstWhere(
              (user) => user?['usermail'] == username,
          orElse: () => null,
        );
        if (matchedUser != null) {
          await SessionManager.saveSession(data);
          await DeviceMapper().saveFromFirebase(doc.id);
          return matchedUser;
        }
      }
    }catch(e){
      await DeviceMapper().changeFbStatus(false);
    }
    return null;
  }


}