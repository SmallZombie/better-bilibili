import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/ui/core/bilibili/movie/movie_poster.dart';
import 'package:better_bilibili/ui/core/bilibili/series/series_poster.dart';
import 'package:better_bilibili/ui/core/bilibili/unsupported_card.dart';
import 'package:flutter/material.dart';

class DynamicPoster extends StatelessWidget {
  final dynamic data;

  const DynamicPoster({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data is SearchResultSeries) {
      final series = data as SearchResultSeries;
      return SeriesPoster(
        seriesId: series.id,
        title: series.title,
        cover: series.cover,
        countries: series.countries.first,
        category: series.tags.first,
        year: series.year,
        badge: '剧集',
      );
    } else if (data is SearchResultMovie) {
      final movie = data as SearchResultMovie;
      return MoviePoster(
        movieId: movie.id,
        title: movie.title,
        cover: movie.cover,
        countries: movie.countries.first,
        category: movie.tags.first,
        year: movie.year,
        badge: '电影',
      );
    } else {
      return UnsupportedCard(title: '${data.runtimeType}');
    }
  }
}
