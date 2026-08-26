class MovieCountry {
  final String id;
  final String name;

  MovieCountry({required this.id, required this.name});
}

enum MovieWatchStatus {
  unwatched,
  watching,
  watched,
}

extension MovieWatchStatusExtension on MovieWatchStatus {
  int get value => switch (this) {
    MovieWatchStatus.unwatched => 1,
    MovieWatchStatus.watching => 2,
    MovieWatchStatus.watched => 3,
  };
}
