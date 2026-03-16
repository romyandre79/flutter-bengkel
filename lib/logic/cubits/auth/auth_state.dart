import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/user.dart';
=======
import 'package:flutter_otopart_offline/data/models/user.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - during login/logout
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - auth operation failed
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password changed successfully
class AuthPasswordChanged extends AuthState {
  const AuthPasswordChanged();
}
