import '../../domain/entities/article.dart';
import '../../../streaming/domain/entities/live_stream_entity.dart';

enum FeedItemType { article, liveStream }

class FeedItem {
  final FeedItemType type;
  final ArticleEntity? article;
  final LiveStreamEntity? liveStream;

  const FeedItem.article(this.article)
      : type = FeedItemType.article,
        liveStream = null;

  const FeedItem.liveStream(this.liveStream)
      : type = FeedItemType.liveStream,
        article = null;
}
