part of 'sign_up_bloc_bloc.dart';

sealed class SignUpBlocState extends Equatable {
  const SignUpBlocState();
  
  @override
  List<Object> get props => [];
}

final class SignUpBlocInitial extends SignUpBlocState {}
