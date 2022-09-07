import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:punch_ios_android/home_news/home_model.dart';
import 'package:punch_ios_android/news_tag/news_tag_model.dart';


abstract class NewsTagState extends Equatable {
  @override
  List<Object> get props => [];
}

class NewsTagInitialState extends NewsTagState {
  @override
  List<Object> get props => [];
}

class NewsTagLoadingState extends NewsTagState {
  @override
  List<Object> get props => [];
}


class NewsTagLoadingMoreState extends NewsTagState {
  @override
  List<Object> get props => [];
}


class NewsTagRefreshingState extends NewsTagState {
  @override
  List<Object> get props => [];
}

class NewsTagLoadedState extends NewsTagState {
  List<HomeNewsModel> newsTag;
  String message;
  NewsTagLoadedState({required this.newsTag, required this.message});

  @override
  List<Object> get props => [];
}

class NewsTagCachedNewsLoadedState extends NewsTagState {
  List<NewsTagModel> cachedNews;
  String message;
  NewsTagCachedNewsLoadedState({required this.cachedNews, required this.message});

  @override
  List<Object> get props => [];
}

class NewsTagRefreshedState extends NewsTagState {
  List<NewsTagModel> newsTag;
  String message;
  NewsTagRefreshedState({required this.newsTag, required this.message});

  @override
  List<Object> get props => [];
}

class NewsTagMoreLoadedState extends NewsTagState {
  List<NewsTagModel> newsTag;
  NewsTagMoreLoadedState({required this.newsTag});

  @override
  List<Object> get props => [];
}

class NewsTagMoreFailureState extends NewsTagState {
  final String error;

  NewsTagMoreFailureState({required this.error});

  @override
  List<Object> get props => [error];
}

class NewsTagLoadFailureState extends NewsTagState {
  final String error;

  NewsTagLoadFailureState({required this.error});

  @override
  List<Object> get props => [error];
}
