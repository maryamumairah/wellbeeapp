import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  //collection reference
  //final CollectionReference activityCollection = FirebaseFirestore.instance.collection('activities');
  
  // create
  Future addActivityDetails
    (Map<String, dynamic> activityInfoMap) async {           
      int activityCount = await getActivityCount() + 1;
      String activityID = "A${activityCount.toString().padLeft(4, '0')}"; // activityID will be A0001, A0002, A0003, etc.

      activityInfoMap['activityID'] = activityID; 
      
      return await FirebaseFirestore.instance
      .collection('activities')
      .doc(activityID)
      .set(activityInfoMap);    
  }  

  // get activity count
  Future<int> getActivityCount() async {
    QuerySnapshot activityCount = await FirebaseFirestore.instance.collection('activities').get();
    return activityCount.docs.length; // return the number of documents in the collection
  }

    // check if activityID exists
  Future<bool> checkActivityIDExists(String activityID) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('activities')
      .doc(activityID)
      .get();
    return doc.exists;
  }

  // read
  Future<Stream<QuerySnapshot>> getActivityDetails() async {
    return await FirebaseFirestore.instance.collection('activities').snapshots();
  }

  // update
  Future updateActivityDetails
    (Map<String, dynamic> activityInfoMap, String activityID) async {
      return await FirebaseFirestore.instance
      .collection('activities')
      .doc(activityID)
      .update(activityInfoMap); 
  }

  // delete
  Future deleteActivity(String activityID) async {
    return await FirebaseFirestore.instance
    .collection('activities')
    .doc(activityID)
    .delete();
  }

}
