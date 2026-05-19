part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({this.title = ''});

  final String title;

  HomeState copyWith({String? title}) {
    return HomeState(title: title ?? this.title);
  }

  @override
  List<Object?> get props => [title];
}
