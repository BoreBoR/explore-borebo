import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onHomeStarted);
  }

  void _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) {
    emit(state.copyWith(title: 'Birthday Surprise'));
  }
}
