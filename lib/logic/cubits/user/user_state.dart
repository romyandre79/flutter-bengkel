import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/user.dart';
=======
import 'package:flutter_otopart_offline/data/models/user.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<User> users;

  const UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
