import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class GameFailure extends Failure {
  final String message;

  GameFailure(this.message);

  @override
  List<Object> get props => [message];
}
