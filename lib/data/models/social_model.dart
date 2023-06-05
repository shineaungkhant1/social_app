import 'dart:io';

import 'package:social_media_app/data/vos/news_feed_vo.dart';

import '../vos/user_vo.dart';

abstract class SocialModel {
  Stream<List<NewsFeedVO>> getNewsFeed();
  Stream<NewsFeedVO> getNewsFeedById(int newsFeedId);
  Future<void> addNewPost(String description, File? imageFile, String profilePicture);
  Future<void> editPost(NewsFeedVO newsFeed, File? imageFile);
  Future<void> deletePost(int postId);
  Future<UserVO> getUserProfileById(String userId );
}
