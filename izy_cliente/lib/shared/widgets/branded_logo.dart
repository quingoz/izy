import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/branding_provider.dart';
import '../../core/constants/app_constants.dart';

class BrandedLogo extends ConsumerWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const BrandedLogo({
    super.key,
    this.height = 60,
    this.width = 120,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandingState = ref.watch(brandingProvider);
    final logoUrl = brandingState.branding.logoUrl;

    if (logoUrl == null || logoUrl.isEmpty) {
      return Image.asset(
        IzyAssets.logoSvg,
        height: height,
        width: width,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: logoUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        IzyAssets.logoSvg,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}

class BrandedBanner extends ConsumerWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const BrandedBanner({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandingState = ref.watch(brandingProvider);
    final bannerUrl = brandingState.branding.bannerUrl;

    if (bannerUrl == null || bannerUrl.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: IzyColors.greyLight,
        child: const Center(
          child: Icon(Icons.image, size: 48, color: IzyColors.greyMedium),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: bannerUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: IzyColors.greyLight,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: IzyColors.greyLight,
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: IzyColors.greyMedium),
        ),
      ),
    );
  }
}
