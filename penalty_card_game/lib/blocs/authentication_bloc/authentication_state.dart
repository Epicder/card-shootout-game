part of 'authentication_bloc.dart';

enum AuthenticationStatus {authenticated, unauthenticated, limbo} // diferentes estados de auth

class AuthenticationState extends Equatable { //clase que handlea el comportamiento de los 3 casos de auth
  final AuthenticationStatus status;
  final User? user;

  const AuthenticationState._({
    this.status = AuthenticationStatus.limbo,
    this.user
  });

  const AuthenticationState.limbo() : this._();

  const AuthenticationState.authenticated(User user) :
   this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated() :
   this._(status: AuthenticationStatus.unauthenticated);



  @override
  // TODO: implement props
  List<Object?> get props => [status, user];
  
  }
