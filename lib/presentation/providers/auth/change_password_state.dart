import 'package:flutter/material.dart';

class ChangePasswordState {
  final bool isLoading;
  final String? error;

  const ChangePasswordState({
    this.isLoading = false,
    this.error,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
