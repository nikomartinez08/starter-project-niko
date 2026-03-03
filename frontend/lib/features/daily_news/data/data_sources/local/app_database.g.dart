// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually extended to include FavoriteDao and DraftDao implementations.

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleDao? _articleDAOInstance;
  FavoriteDao? _favoriteDaoInstance;
  DraftDao? _draftDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))');

        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorite_article` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `externalId` TEXT, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, `savedAt` TEXT)');

        await database.execute(
            'CREATE TABLE IF NOT EXISTS `draft` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `author` TEXT, `title` TEXT, `content` TEXT, `imagePath` TEXT, `createdAt` TEXT, `updatedAt` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDao get articleDAO {
    return _articleDAOInstance ??= _$ArticleDao(database, changeListener);
  }

  @override
  FavoriteDao get favoriteDAO {
    return _favoriteDaoInstance ??= _$FavoriteDao(database, changeListener);
  }

  @override
  DraftDao get draftDAO {
    return _draftDaoInstance ??= _$DraftDao(database, changeListener);
  }
}

class _$ArticleDao extends ArticleDao {
  _$ArticleDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _articleModelInsertionAdapter = InsertionAdapter(
            database,
            'article',
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content
                }),
        _articleModelDeletionAdapter = DeletionAdapter(
            database,
            'article',
            ['id'],
            (ArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleModel> _articleModelInsertionAdapter;

  final DeletionAdapter<ArticleModel> _articleModelDeletionAdapter;

  @override
  Future<List<ArticleModel>> getArticles() async {
    return _queryAdapter.queryList('SELECT * FROM article',
        mapper: (Map<String, Object?> row) => ArticleModel(
            id: row['id'] as int?,
            author: row['author'] as String?,
            title: row['title'] as String?,
            description: row['description'] as String?,
            url: row['url'] as String?,
            urlToImage: row['urlToImage'] as String?,
            publishedAt: row['publishedAt'] as String?,
            content: row['content'] as String?));
  }

  @override
  Future<void> insertArticle(ArticleModel article) async {
    await _articleModelInsertionAdapter.insert(
        article, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteArticle(ArticleModel articleModel) async {
    await _articleModelDeletionAdapter.delete(articleModel);
  }
}

class _$FavoriteDao extends FavoriteDao {
  _$FavoriteDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _favoriteArticleModelInsertionAdapter = InsertionAdapter(
            database,
            'favorite_article',
            (FavoriteArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'externalId': item.externalId,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content,
                  'savedAt': item.savedAt?.toIso8601String(),
                }),
        _favoriteArticleModelDeletionAdapter = DeletionAdapter(
            database,
            'favorite_article',
            ['id'],
            (FavoriteArticleModel item) => <String, Object?>{
                  'id': item.id,
                  'externalId': item.externalId,
                  'author': item.author,
                  'title': item.title,
                  'description': item.description,
                  'url': item.url,
                  'urlToImage': item.urlToImage,
                  'publishedAt': item.publishedAt,
                  'content': item.content,
                  'savedAt': item.savedAt?.toIso8601String(),
                });

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;
  final QueryAdapter _queryAdapter;
  final InsertionAdapter<FavoriteArticleModel>
      _favoriteArticleModelInsertionAdapter;
  final DeletionAdapter<FavoriteArticleModel>
      _favoriteArticleModelDeletionAdapter;

  FavoriteArticleModel _rowToFavoriteArticleModel(Map<String, Object?> row) {
    return FavoriteArticleModel(
      id: row['id'] as int?,
      externalId: row['externalId'] as String?,
      author: row['author'] as String?,
      title: row['title'] as String?,
      description: row['description'] as String?,
      url: row['url'] as String?,
      urlToImage: row['urlToImage'] as String?,
      publishedAt: row['publishedAt'] as String?,
      content: row['content'] as String?,
      savedAt: row['savedAt'] != null
          ? DateTime.tryParse(row['savedAt'] as String)
          : null,
    );
  }

  @override
  Future<List<FavoriteArticleModel>> getFavorites() async {
    return _queryAdapter.queryList(
        'SELECT * FROM favorite_article ORDER BY id DESC',
        mapper: _rowToFavoriteArticleModel);
  }

  @override
  Future<FavoriteArticleModel?> getFavoriteByExternalId(
      String externalId) async {
    return _queryAdapter.query(
        'SELECT * FROM favorite_article WHERE externalId = ?1 LIMIT 1',
        mapper: _rowToFavoriteArticleModel,
        arguments: [externalId]);
  }

  @override
  Future<void> insertFavorite(FavoriteArticleModel article) async {
    await _favoriteArticleModelInsertionAdapter.insert(
        article, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteFavorite(FavoriteArticleModel article) async {
    await _favoriteArticleModelDeletionAdapter.delete(article);
  }

  @override
  Future<void> deleteFavoriteByExternalId(String externalId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM favorite_article WHERE externalId = ?1',
        arguments: [externalId]);
  }
}

class _$DraftDao extends DraftDao {
  _$DraftDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _draftModelInsertionAdapter = InsertionAdapter(
            database,
            'draft',
            (DraftModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'content': item.content,
                  'imagePath': item.imagePath,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                }),
        _draftModelUpdateAdapter = UpdateAdapter(
            database,
            'draft',
            ['id'],
            (DraftModel item) => <String, Object?>{
                  'id': item.id,
                  'author': item.author,
                  'title': item.title,
                  'content': item.content,
                  'imagePath': item.imagePath,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                });

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;
  final QueryAdapter _queryAdapter;
  final InsertionAdapter<DraftModel> _draftModelInsertionAdapter;
  final UpdateAdapter<DraftModel> _draftModelUpdateAdapter;

  DraftModel _rowToDraftModel(Map<String, Object?> row) {
    return DraftModel(
      id: row['id'] as int?,
      author: row['author'] as String?,
      title: row['title'] as String?,
      content: row['content'] as String?,
      imagePath: row['imagePath'] as String?,
      createdAt: row['createdAt'] as String?,
      updatedAt: row['updatedAt'] as String?,
    );
  }

  @override
  Future<List<DraftModel>> getDrafts() async {
    return _queryAdapter.queryList(
        'SELECT * FROM draft ORDER BY updatedAt DESC',
        mapper: _rowToDraftModel);
  }

  @override
  Future<DraftModel?> getDraftById(int id) async {
    return _queryAdapter.query('SELECT * FROM draft WHERE id = ?1',
        mapper: _rowToDraftModel, arguments: [id]);
  }

  @override
  Future<int> insertDraft(DraftModel draft) async {
    return _draftModelInsertionAdapter.insertAndReturnId(
        draft, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateDraft(DraftModel draft) async {
    await _draftModelUpdateAdapter.update(draft, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDraftById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM draft WHERE id = ?1',
        arguments: [id]);
  }
}
