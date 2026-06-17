String? normalizeFirebaseImageUrl(String? url) {
  if (url == null || url.isEmpty) return url;
  if (url.contains('storage.googleapis.com/v0/b/')) {
    return url.replaceFirst(
      'storage.googleapis.com',
      'firebasestorage.googleapis.com',
    );
  }
  return url;
}
