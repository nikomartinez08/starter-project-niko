import '../../domain/entities/profile_entities.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/remote/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<int> getFollowersCount() {
    return _remoteDataSource.getFollowersCount();
  }

  @override
  Future<int> getFollowingCount() {
    return _remoteDataSource.getFollowingCount();
  }

  @override
  Future<void> updateProfile({String? name, String? title, String? photoUrl}) {
    return _remoteDataSource.updateProfile(name: name, title: title, photoUrl: photoUrl);
  }

  @override
  Future<List<UserPostEntity>> getUserPosts() {
    return _remoteDataSource.getUserPosts();
  }

  @override
  Future<UserProfileDataEntity> getUserProfile() {
    return _remoteDataSource.getUserProfile();
  }
}
