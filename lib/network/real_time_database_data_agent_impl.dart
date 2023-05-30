import 'package:firebase_database/firebase_database.dart';
import 'package:social_media_app/data/vos/news_feed_vo.dart';
import 'package:social_media_app/network/social_data_agent.dart';

/// Database Paths
const newsFeedPath = "newsfeed";

class RealtimeDatabaseDataAgentImpl extends SocialDataAgent {
  static final RealtimeDatabaseDataAgentImpl _singleton =
      RealtimeDatabaseDataAgentImpl._internal();

  factory RealtimeDatabaseDataAgentImpl() {
    return _singleton;
  }

  RealtimeDatabaseDataAgentImpl._internal();

  /// Database
  var databaseRef = FirebaseDatabase.instance.reference();

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
  Future<void> addNewPost(NewsFeedVO newPost) {
    return databaseRef
        .child(newsFeedPath)
        .child(newPost.id.toString())
        .set(newPost.toJson());
  }

  @override
  Future<void> deletePost(int postId) {
    return databaseRef.child(newsFeedPath)
        .child(postId.toString()).remove();
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

}
