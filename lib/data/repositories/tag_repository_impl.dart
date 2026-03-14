import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/remote_data_source.dart';

class TagRepositoryImpl implements TagRepository {
  final RemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Tag>> getTags() async {
    return await remoteDataSource.getTags();
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    return await remoteDataSource.createTag(tag);
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    return await remoteDataSource.updateTag(tag);
  }

  @override
  Future<void> deleteTag(String id) async {
    return await remoteDataSource.deleteTag(id);
  }

  @override
  Future<void> setTagTracks(String tagId, List<String> trackIds) async {
    return await remoteDataSource.setTagTracks(tagId, trackIds);
  }
}
