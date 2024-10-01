import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'sign_up_bloc_event.dart';
part 'sign_up_bloc_state.dart';

class SignUpBlocBloc extends Bloc<SignUpBlocEvent, SignUpBlocState> {
  SignUpBlocBloc() : super(SignUpBlocInitial()) {
    on<SignUpBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
