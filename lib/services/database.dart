import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {  
  
  // create for activity
  Future addActivityDetails
    (User currentUser, Map<String, dynamic> activityInfoMap) async {           
      int activityCount = await getActivityCount(currentUser) + 1;
      String activityID = "A${activityCount.toString().padLeft(4, '0')}"; // activityID will be A0001, A0002, A0003, etc.

      activityInfoMap['activityID'] = activityID; 
             
      return await FirebaseFirestore.instance
      .collection('users') // Top-level collection for all users
      .doc(currentUser.uid) // Document for the current user (using their UID)
      .collection('activities')
      .doc(activityID)
      .set(activityInfoMap);    
  }  


  // create for timer activity
  Future<void> addTimerLogDetails
    (User currentUser, String activityID, Map<String, dynamic> timerLogInfoMap) async {
      int timerLogCount = await getTimerLogCount(currentUser, activityID) + 1;
      String timerLogID = "T${timerLogCount.toString().padLeft(4, '0')}"; // timerLogID will be T0001, T0002, T0003, etc.

      timerLogInfoMap['timerLogID'] = timerLogID;

      return await FirebaseFirestore.instance
      .collection('users') 
      .doc(currentUser.uid) 
      .collection('activities')
      .doc(activityID)
      .collection('timerLogs')
      .doc(timerLogID)
      .set(timerLogInfoMap);
      
  }

  // get activity count
  // Future<int> getActivityCount() async {
  //   QuerySnapshot activityCount = await FirebaseFirestore.instance.collection('activities').get();
  //   return activityCount.docs.length; // return the number of documents in the collection
  // }
  Future<int> getActivityCount(User currentUser) async {
    QuerySnapshot activitySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('activities')
      .get();
    return activitySnapshot.docs.length;
  }
  


  // get timer log count
  Future<int> getTimerLogCount(User currentUser, String activityID) async {
    QuerySnapshot timerLogCount = await FirebaseFirestore.instance
      .collection('users') 
      .doc(currentUser.uid) 
      .collection('activities')
      .doc(activityID)
      .collection('timerLogs')
      .get();
    return timerLogCount.docs.length; // return the number of documents in the collection
  }


  // check if activityID exists
  Future<bool> checkActivityIDExists(String activityID) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
      // .collection('users') 
      // .doc(currentUser.uid) 
      .collection('activities')
      .doc(activityID)
      .get();
    return doc.exists;
  }

  // check if timerLogID exists
  Future<bool> checkTimerLogIDExists(String activityID, String timerLogID) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
      // .collection('users') 
      // .doc(currentUser.uid)
      .collection('activities')
      .doc(activityID)
      .collection('timerLogs')
      .doc(timerLogID)
      .get();
    return doc.exists;
  }

  // read for activity
  Future<Stream<QuerySnapshot>> getActivityDetails(User currentUser) async {
    return await FirebaseFirestore.instance
    .collection('users') 
    .doc(currentUser.uid)
    .collection('activities')
    .snapshots();
  }

  // read for timer
  Future<Stream<QuerySnapshot>> getTimerDetails(User currentUser, String activityID) async {
    return await FirebaseFirestore.instance
      .collection('users') 
      .doc(currentUser.uid)
      .collection('activities')
      .doc(activityID)
      .collection('timerLogs')
      .snapshots();
  }

  // update for activity
  Future updateActivityDetails
    (User currentUser, Map<String, dynamic> activityInfoMap, String activityID) async {
      return await FirebaseFirestore.instance
      .collection('users') 
      .doc(currentUser.uid)
      .collection('activities')
      .doc(activityID)
      .update(activityInfoMap); 
  }

  // update for timer
  Future updateTimerLogDetails
    (User currentUser, Map<String, dynamic> timerLogInfoMap, String activityID, String timerLogID) async {
      return await FirebaseFirestore.instance
      .collection('users') 
      .doc(currentUser.uid)
      .collection('activities')
      .doc(activityID)
      .collection('timerLogs')
      .doc(timerLogID)
      .update(timerLogInfoMap);
  }

  // delete for activity
  Future deleteActivity(User currentUser, String activityID) async {
    return await FirebaseFirestore.instance
    .collection('users') 
    .doc(currentUser.uid)
    .collection('activities')
    .doc(activityID)
    .delete();
  }
  // Future deleteActivity(String activityID) async {
  //   if (currentUser != null) {
  //     return await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentUser.uid)
  //       .collection('activities')
  //       .doc(activityID)
  //       .delete();
  //   } else {
  //     throw Exception('User not logged in');
  //   }
  // }

}
