import 'package:equatable/equatable.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {
  const SignupInitial();
}

class SignupLoading extends SignupState {
  const SignupLoading();
}

class SignupSuccess extends SignupState {
  final String message;

  const SignupSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SignupFailure extends SignupState {
  final String message;

  const SignupFailure(this.message);

  @override
  List<Object?> get props => [message];
}

