import 'dart:io';

import 'package:social_media_app/data/models/authentication_model.dart';
import 'package:social_media_app/data/models/authentication_model_impl.dart';
import 'package:social_media_app/data/models/social_model.dart';
import 'package:social_media_app/data/vos/news_feed_vo.dart';
import 'package:social_media_app/data/vos/user_vo.dart';
import 'package:social_media_app/network/real_time_database_data_agent_impl.dart';
import 'package:social_media_app/network/social_data_agent.dart';

import '../../network/cloud_firestore_data_agent_impl.dart';

class SocialModelImpl extends SocialModel {
  static final SocialModelImpl _singleton = SocialModelImpl._internal();

  factory SocialModelImpl() {
    return _singleton;
  }

  SocialModelImpl._internal();

  SocialDataAgent mDataAgent = RealtimeDatabaseDataAgentImpl();
  // SocialDataAgent mDataAgent = CloudFireStoreDataAgentImpl();

  /// Other Models
  final AuthenticationModel _authenticationModel = AuthenticationModelImpl();


  @override
  Stream<List<NewsFeedVO>> getNewsFeed() {
    return mDataAgent.getNewsFeed();
  }

  @override
  Future<void> deletePost(int postId) {
    return mDataAgent.deletePost(postId);
  }

  @override
  Future<void> addNewPost(String description, File? imageFile ) {
    if (imageFile != null) {
      return mDataAgent
          .uploadFileToFirebase(imageFile)
          .then((downloadUrl) => craftNewsFeedVO(description, downloadUrl))
          .then((newPost) => mDataAgent.addNewPost(newPost));
    } else {
      return craftNewsFeedVO(description, "")
          .then((newPost) => mDataAgent.addNewPost(newPost));
    }
  }

  Future<NewsFeedVO> craftNewsFeedVO(String description,String imageUrl) {
    var currentMilliseconds = DateTime.now().millisecondsSinceEpoch;
    var newPost = NewsFeedVO(
      id: currentMilliseconds,
      userName: _authenticationModel.getLoggedInUser().userName,
      postImage: imageUrl,
      description: description,
    );
    return Future.value(newPost);
  }

  @override
  Stream<NewsFeedVO> getNewsFeedById(int newsFeedId) {
    return mDataAgent.getNewsFeedById(newsFeedId);
  }

  @override
  Future<void> editPost(NewsFeedVO newsFeed, File? imageFile) {
    return mDataAgent.addNewPost(newsFeed);
  }

  @override
  Future<UserVO> getUserProfileById(String userId) {
    return mDataAgent.getUserProfileById(userId);
  }
}
