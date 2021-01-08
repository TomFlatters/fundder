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

  String _authorUsername = "";
  /**This mechanism really has no business being here but in bit of a rush and 
   * too messy to make everything proper at this moment. 
   */

  String get authorUsername => _authorUsername;

  /**This mechanism really has no business being here but in bit of a rush and 
   * too messy to make everything proper at this moment. 
   */

  void setUsername(String uname) {
    _authorUsername = uname;
  }
}
