import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/data/vos/news_feed_vo.dart';
import 'package:social_media_app/data/vos/user_vo.dart';
import 'package:social_media_app/network/social_data_agent.dart';

/// Database Paths
const newsFeedPath = "newsfeed";
const usersPath = "users";

/// File Upload References
const fileUploadRef = "uploads";

class RealtimeDatabaseDataAgentImpl extends SocialDataAgent {
  static final RealtimeDatabaseDataAgentImpl _singleton =
      RealtimeDatabaseDataAgentImpl._internal();

  factory RealtimeDatabaseDataAgentImpl() {
    return _singleton;
  }

  RealtimeDatabaseDataAgentImpl._internal();

  /// Database
  var databaseRef = FirebaseDatabase.instance.reference();

  /// Storage
  var firebaseStorage = FirebaseStorage.instance;

  /// Auth
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Stream<List<NewsFeedVO>> getNewsFeed() {
    return databaseRef.child(newsFeedPath).onValue.map((event) {
      final dynamic value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        return value.values
            .map<NewsFeedVO>((element) =>
            NewsFeedVO.fromJson(Map<String, dynamic>.from(element)))
            .toList();
      } else {
        return [];
      }
    });
  }


  @override
  Stream<NewsFeedVO> getNewsFeedById(int newsFeedId) {
    return databaseRef
        .child(newsFeedPath)
        .child(newsFeedId.toString())
        .once()
        .asStream()
        .map((snapShot) {
      final dynamic value = snapShot.snapshot.value;
      if (value != null) {
        return NewsFeedVO.fromJson(Map<String, dynamic>.from(value));
      } else {
        throw Exception('Data not found');
      }
    });
  }

  @override
  Future<void> addNewPost(NewsFeedVO newPost) {
    return databaseRef
        .child(newsFeedPath)
        .child(newPost.id.toString())
        .set(newPost.toJson());
  }

  @override
  Future<void> deletePost(int postId) {
    return databaseRef.child(newsFeedPath).child(postId.toString()).remove();
  }

  @override
  Future<String> uploadFileToFirebase(File image) {
    return firebaseStorage
        .ref(fileUploadRef)
        .child("${DateTime.now().millisecondsSinceEpoch}")
        .putFile(image)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());
  }

  @override
  Future registerNewUser(UserVO newUser) {
    return auth
        .createUserWithEmailAndPassword(
            email: newUser.email ?? "", password: newUser.password ?? "")
        .then((credential) =>
            credential.user?..updateDisplayName(newUser.userName))
        .then((user) {
      newUser.id = user?.uid ?? "";
      _addNewUser(newUser);
    });
  }

  Future<void> _addNewUser(UserVO newUser) {
    return databaseRef
        .child(usersPath)
        .child(newUser.id.toString())
        .set(newUser.toJson());
  }

  @override
  Future login(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  @override
  UserVO getLoggedInUser() {
    return UserVO(
      id: auth.currentUser?.uid,
      userProfile: auth.currentUser?.photoURL,
      email: auth.currentUser?.email,
      userName: auth.currentUser?.displayName,
    );
  }

  @override
  Future logOut() {
    return auth.signOut();
  }

  @override
  Future<UserVO> getUserProfileById(String userId) {
    // return databaseRef
    //     .child(usersPath)
    //     .child(newsFeedId.toString())
    //     .once()
    //     .asStream()
    //     .map((snapShot) {
    //   final dynamic value = snapShot.snapshot.value;
    //   if (value != null) {
    //     return NewsFeedVO.fromJson(Map<String, dynamic>.from(value));
    //   } else {
    //     throw Exception('Data not found');
    //   }
    // });
    return databaseRef
        .child(usersPath)
        .child(userId)
        .once()
        .then((databaseEvent){
       final dynamic value = databaseEvent.snapshot.value;
       if(value != null){
         return UserVO.fromJson(Map<String,dynamic>.from(value));
       } else {
         throw Exception('Data not Found');
       }
    });

  }
}
