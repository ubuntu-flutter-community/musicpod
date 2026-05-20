class PodcastUpdateCapsule {
  final PodcastUpdateType type;
  final List<String> feedUrls;

  const PodcastUpdateCapsule({required this.type, required this.feedUrls});

  const PodcastUpdateCapsule.updateAll()
    : this(type: PodcastUpdateType.update, feedUrls: const []);

  const PodcastUpdateCapsule.removeAll()
    : this(type: PodcastUpdateType.remove, feedUrls: const []);
}

enum PodcastUpdateType { remove, update }
