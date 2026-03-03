import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';

abstract class DraftState extends Equatable {
  const DraftState();

  @override
  List<Object?> get props => [];
}

class DraftInitial extends DraftState {
  const DraftInitial();
}

class DraftsLoading extends DraftState {
  const DraftsLoading();
}

class DraftsLoaded extends DraftState {
  final List<DraftEntity> drafts;

  const DraftsLoaded(this.drafts);

  @override
  List<Object?> get props => [drafts];
}

class DraftSaved extends DraftState {
  final int draftId;

  const DraftSaved(this.draftId);

  @override
  List<Object?> get props => [draftId];
}

class DraftDeleted extends DraftState {
  const DraftDeleted();
}

class DraftError extends DraftState {
  final String message;

  const DraftError(this.message);

  @override
  List<Object?> get props => [message];
}
