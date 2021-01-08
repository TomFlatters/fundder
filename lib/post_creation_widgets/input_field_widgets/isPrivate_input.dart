/**For now, the user cannot choose in add post whether the post is private.
 * It depends on their private status. 
 * Private users make private posts and public users make public posts. 
 */
class PrivateStatusStateManager {
  bool _isPrivate = false;
  bool get currentValue => _isPrivate;

/**Updates the private status of the post to 'newPrivateStatus' */
  void updateValue(bool newPrivateStatus) {
    _isPrivate = newPrivateStatus;
  }
}
