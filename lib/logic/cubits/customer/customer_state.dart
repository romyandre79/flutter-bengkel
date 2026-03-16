import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:kreatif_otopart/data/models/customer.dart';
=======
import 'package:flutter_otopart_offline/data/models/customer.dart';
>>>>>>> 61bd5f38dd367d6fd8d20e8cbc086ce0d3d7e92e

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomerLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  final Customer? customer;

  const CustomerOperationSuccess(this.message, {this.customer});

  @override
  List<Object?> get props => [message, customer];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
