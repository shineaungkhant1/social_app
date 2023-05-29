import 'package:flutter/foundation.dart';
import 'package:social_media_app/data/models/social_model.dart';
import 'package:social_media_app/data/models/social_model_impl.dart';

class AddNewPostBloc extends ChangeNotifier {
  /// State
  String newPostDescription = "";
  bool isAddNewPostError = false;
  bool isDisposed = false;

  /// Model
  final SocialModel _model = SocialModelImpl();

  void onNewPostTextChanged(String newPostDescription) {
    this.newPostDescription = newPostDescription;
  }

  Future onTapAddNewPost() {
    if (newPostDescription.isEmpty) {
      isAddNewPostError = true;
      if (!isDisposed) {
        notifyListeners();
      }
      return Future.error("Error");
    } else {
      isAddNewPostError = false;
      return _model.addNewPost(newPostDescription);
    }
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }
}
