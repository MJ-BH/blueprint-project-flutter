import 'package:equatable/equatable.dart';

abstract class Result<S, E extends Exception> extends Equatable {
  const Result();

  static Result<S, E> success<S, E extends Exception>(S data) => Success(data);
  static Result<S, E> failure<S, E extends Exception>(E error) => FailureResult(error);

  bool get isSuccess => this is Success<S, E>;
  bool get isFailure => this is FailureResult<S, E>;

  T fold<T>(T Function(S success) onSuccess, T Function(E failure) onFailure) {
    if (this is Success<S, E>) {
      return onSuccess((this as Success<S, E>).data);
    } else if (this is FailureResult<S, E>) {
      return onFailure((this as FailureResult<S, E>).error);
    }
    throw Exception('Unhandled Result state');
  }

  @override
  List<Object?> get props => [];
}

class Success<S, E extends Exception> extends Result<S, E> {
  final S data;
  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class FailureResult<S, E extends Exception> extends Result<S, E> {
  final E error;
  const FailureResult(this.error);

  @override
  List<Object?> get props => [error];
}
