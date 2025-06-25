import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A reusable loading button widget that displays a loading indicator
/// when an async operation is in progress
class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Widget? icon;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: backgroundColor?.withOpacity(0.6) ?? 
              AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? 
                BorderRadius.circular(AppConstants.defaultRadius),
          ),
          padding: padding ?? 
              const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding,
                horizontal: AppConstants.largePadding,
              ),
          elevation: AppConstants.defaultElevation,
        ),
        child: isLoading 
            ? _buildLoadingIndicator() 
            : _buildButtonContent(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          foregroundColor ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            text,
            style: textStyle ?? const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle ?? const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A specialized loading button for primary actions
class PrimaryLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Widget? icon;

  const PrimaryLoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressed: onPressed,
      isLoading: isLoading,
      text: text,
      icon: icon,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }
}

/// A specialized loading button for secondary actions
class SecondaryLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Widget? icon;

  const SecondaryLoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressed: onPressed,
      isLoading: isLoading,
      text: text,
      icon: icon,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
    );
  }
}

/// A specialized loading button for success actions
class SuccessLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Widget? icon;

  const SuccessLoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressed: onPressed,
      isLoading: isLoading,
      text: text,
      icon: icon,
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
    );
  }
}

/// A specialized loading button for destructive actions
class DestructiveLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Widget? icon;

  const DestructiveLoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressed: onPressed,
      isLoading: isLoading,
      text: text,
      icon: icon,
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
    );
  }
}