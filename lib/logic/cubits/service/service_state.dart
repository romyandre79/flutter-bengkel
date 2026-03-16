import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/service.dart';
=======
import 'package:flutter_otopart_offline/data/models/service.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<Service> services;

  const ServiceLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class ServiceOperationSuccess extends ServiceState {
  final String message;

  const ServiceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
