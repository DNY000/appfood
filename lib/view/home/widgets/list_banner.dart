import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/show_loading.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/banner_viewmodel.dart';

class ListBanner extends StatelessWidget {
  const ListBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeContainer = MediaQuery.of(context).size.width * 0.5;
    final bannerVM = Provider.of<BannerViewmodel>(context);

    if (bannerVM.listBanner.isEmpty && !bannerVM.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        LoadingUtil.show();
        try {
          await bannerVM.getListBanner();
        } finally {
          LoadingUtil.hide();
        }
      });
    }

    // if (bannerVM.isLoading) {
    //   return const SizedBox();
    // }

    if (bannerVM.listBanner.isEmpty) {
      return const Center(child: Text('Không có banner nào'));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CarouselSlider.builder(
        itemCount: bannerVM.listBanner.length,
        itemBuilder: (context, index, realIndex) {
          final banner = bannerVM.listBanner[index];
          final isAsset = banner.image.startsWith('assets/');

          return GestureDetector(
            onTap: () {
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: isAsset
                      ? AssetImage(banner.image) as ImageProvider
                      : NetworkImage(banner.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      banner.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      banner.subTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: sizeContainer,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}

