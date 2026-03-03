import '../../domain/entities/profile_entities.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/remote/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserProfileDataEntity> getUserProfile() {
    return _remoteDataSource.getUserProfile();
  }
}
