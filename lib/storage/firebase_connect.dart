import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbConnect {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference usersCollection = firestore.collection(
    ConstantValues.firestoreCollection,
  );

  Future<Map<String, dynamic>?> fetchWeightMap() async {
    final uuid = await DeviceMapper().getUuid();
    try {
      final docSnapshot = await usersCollection.doc(uuid).get();
      if (!docSnapshot.exists) return {};
      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) return {};
      final List users = data['users'] ?? [];

      final currentUser = await SessionManager.getCurrentUser();
      if (currentUser == null) return {};
      final email = currentUser['usermail'];

      for (var user in users) {
        if ((user as Map)['usermail'] == email) {
          return Map<String, dynamic>.from(user['weightMap'] ?? {});
        }
      }
    } catch (e) {
      print("Error fetching weight map from firebase: $e");
    }
    return null;
  }

  Future<void> updateWeightMap(Map<String, dynamic> weightMap) async {
    final uuid = await DeviceMapper().getUuid();
    try {
      final docSnapshot = await usersCollection.doc(uuid).get();
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) return;
      List users = data['users'] ?? [];

      final currentUser = await SessionManager.getCurrentUser();
      if (currentUser == null) return;
      final email = currentUser['usermail'];

      bool found = false;
      for (var i = 0; i < users.length; i++) {
        if ((users[i] as Map)['usermail'] == email) {
          users[i]['weightMap'] = weightMap;
          found = true;
          break;
        }
      }
      if (found) {
        await usersCollection.doc(uuid).update({'users': users});
      }
    } catch (e) {
      print("Error updating weight map sequentially: $e");
    }
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
          await DeviceMapper().saveFromFirebase(doc.id);
          return matchedUser;
        }
      }
    } catch (e) {
      print("Error getting weight map: $e");
    }
    return null;
  }

  Future<void> createNewUserRecord(String name, String email) async {
    final uuid = await DeviceMapper().getUuid();
    try {
      final docSnapshot = await usersCollection.doc(uuid).get();
      Map<String, dynamic> data = {};
      if (docSnapshot.exists) {
        data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      }
      List users = data['users'] ?? [];
      users.add({
        "username": name,
        "usermail": email,
        // "isloggedin": 1,
        "weightMap": {},
      });
      data['users'] = users;
      await usersCollection.doc(uuid).set(data);
    }catch(e){

    }
  }

  Future<void> addExerciseForADate(String uuid, String date, Map<String, dynamic> exerciseMap) async {
    try {
      await usersCollection
          .doc(uuid)
          .collection(date)
          .doc(ConstantValues.exerciseDocIdFirestore).set(exerciseMap);
    }catch(e){}
  }

  Future<Map<String, dynamic>> fetchExerciseForADate(String uuid, String date) async {
    try{
    final exerciseDocSnapshot = await usersCollection
        .doc(uuid)
        .collection(date)
        .doc(ConstantValues.exerciseDocIdFirestore)
        .get();
    if (!exerciseDocSnapshot.exists) return {};
    return exerciseDocSnapshot.data() ?? {};
    }catch(e){return {};}
  }

  Future<void> addFoodForADate(String uuid, String date, Map<String, dynamic> foodMap) async {
    try {
      await usersCollection
          .doc(uuid)
          .collection(date)
          .doc(ConstantValues.foodDocIdFirestore)
          .set(foodMap);
    }catch(e){}
    ///Food: {morning : {inKCal:0, inProt:0,}
  }

  Future<Map<String, dynamic>> fetchFoodForADate(String uuid, String date) async {
    try {
      final foodDocSnapshot = await usersCollection
          .doc(uuid)
          .collection(date)
          .doc(ConstantValues.foodDocIdFirestore)
          .get();
      if (!foodDocSnapshot.exists) return {};
      return foodDocSnapshot.data() ?? {};
    }catch(e){return {};}
  }
}
