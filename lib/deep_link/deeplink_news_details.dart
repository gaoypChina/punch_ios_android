import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:punch_ios_android/home_news/home_model.dart';
import 'package:punch_ios_android/utility/ad_helper.dart';
import 'package:punch_ios_android/utility/colors.dart';
import 'package:punch_ios_android/utility/deeplink_news_details_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';


// this is the deeplink that works for notification from OneSignal

class DeepLinkNewsDetails extends StatefulWidget {
 final String slug;

  const DeepLinkNewsDetails ({Key? key , required this.slug,}) : super( key: key );

  @override
  _DeepLinkNewsDetailsState createState() => _DeepLinkNewsDetailsState();
}

class _DeepLinkNewsDetailsState extends State<DeepLinkNewsDetails> {
  StreamSubscription? subscription;
  bool isSaved=false;
  bool adShown=true;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final BannerAd articleMedium = BannerAd(
    adUnitId: AdHelper.articleMedium2,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  final BannerAd inArticleAds = BannerAd(
    adUnitId: AdHelper.homeBanner,
    size: AdSize.largeBanner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  final AdManagerBannerAd adManagerBannerAd = AdManagerBannerAd(
    adUnitId: AdHelper.adManagerBannerUnitId,
    // sizes: [AdSize.largeBanner],
    sizes: [AdSize(width: 300, height: 250)],
    request: AdManagerAdRequest(),
    listener: AdManagerBannerAdListener(),
  );

  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-7167863529667065/3759929490'
            : 'ca-app-pub-7167863529667065/7063763571',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            // print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      // print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        // print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        // print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  Widget getAd() {
    BannerAdListener bannerAdListener =
    BannerAdListener(onAdWillDismissScreen: (ad) {
      ad.dispose();
    }, onAdClosed: (ad) {
      debugPrint("Ad Got Closeed");
    });
    BannerAd bannerAd = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: Platform.isAndroid
      //working ad medium size
          ? "ca-app-pub-7167863529667065/7963339325"
          : "ca-app-pub-7167863529667065/1645777752",

      // ? "ca-app-pub-3940256099942544/6300978111"
      // : "ca-app-pub-3940256099942544/2934735716",
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    bannerAd.load();

    return SizedBox(
      height: 120,
      child: AdWidget(ad: bannerAd),
    );
  }



  @override
  void initState() {
    super.initState();
    DeepLinkNewsDetailsProvider _favoritesProvider = Provider.of<DeepLinkNewsDetailsProvider>(context, listen: false);
    _favoritesProvider.setSlug(widget.slug);
    _favoritesProvider.getFeed();
    // _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);

    articleMedium.load();
    inArticleAds.load();
    adManagerBannerAd.load();

    _createInterstitialAd();

  }


  @override
  Widget build (BuildContext context) {
    final AdWidget mediumWidget = AdWidget(ad: articleMedium);
    final AdWidget adManagerBannerWidget = AdWidget(ad: adManagerBannerAd);
    final AdWidget inArticleWidget = AdWidget(ad: inArticleAds);


    return Consumer<DeepLinkNewsDetailsProvider>(
        builder: ( context,  deepProvider, child) {
          HomeNewsModel? newsModel = deepProvider.getNewsDetails();
          // return Consumer<DetailsProvider>(
          return Consumer(
              builder: ( context,  detailsProvider, child) {
                return Scaffold (
                    appBar: AppBar (
                      leading: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                            // _showInterstitialAd();
                          },
                          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.headline1!.color,)
                      ),

                      actions: <Widget>[
                        Visibility(
                          visible: deepProvider.isLoadSuccessful==true,
                          // child: IconButton (
                          //   onPressed: () {
                          //     FlutterShare.share(
                          //       title: 'Punch News' ,
                          //       text: '${newsModel.title!.rendered}' .replaceAll (r"\n" , "\n" )
                          //           .replaceAll ( r"\r" , "" ).replaceAll ( r"\'" , "'" ).replaceAll ( "<p>" , "" ).replaceAll ("&#8217;" , "'" )
                          //           .replaceAll ("&#038;" , "&" ).replaceAll ("&#8216;" , "‘" ),
                          //       linkUrl:'https:// punchng.com/' '${newsModel.slug} ',
                          //       // chooserTitle: 'Something for chooser title',
                          //     );
                          //
                          //     // Share.share( '${newsModel!.title!.rendered}'
                          //     //     .replaceAll (r"\n" , "\n" ).replaceAll ( r"\r" , "" )
                          //     //     .replaceAll ( r"\'" , "'" ).replaceAll ( "<p>" , "" )
                          //     //     .replaceAll ("&#8217;" , "'" ).replaceAll ("&#038;" , "&" )
                          //     //     .replaceAll ("&#8216;" , "‘" ).replaceAll("&#8211;", "-"),
                          //     //   subject: 'Look what I made!',
                          //     //
                          //     // );
                          //   } ,
                          //   icon:  Icon (
                          //     Icons.share ,color: Theme.of(context).textTheme.headline1!.color,
                          //   ) ,
                          // ),
                          child:                         IconButton (
                            onPressed: () {
                              FlutterShare.share(
                                title: 'Punch News' ,
                                text: '${newsModel.title!.rendered}'
                                    .replaceAll (r"\n" , "\n" ).replaceAll ( r"\r" , "" )
                                    .replaceAll ( r"\'" , "'" ).replaceAll ( "<p>" , "" )
                                    .replaceAll ("&#8217;" , "'" ).replaceAll ("&#038;" , "&" )
                                    .replaceAll ("&#8216;" , "‘" ).replaceAll("&#8211;", "-"),
                                linkUrl:'https://punchng.com/' '${newsModel.slug} ',
                                // chooserTitle: 'Something for chooser title',
                              );

                              // Share.share( '${widget.newsModel!.title!.rendered}'
                              //     .replaceAll (r"\n" , "\n" ).replaceAll ( r"\r" , "" )
                              //     .replaceAll ( r"\'" , "'" ).replaceAll ( "<p>" , "" )
                              //     .replaceAll ("&#8217;" , "'" ).replaceAll ("&#038;" , "&" )
                              //     .replaceAll ("&#8216;" , "‘" ).replaceAll("&#8211;", "-"),
                              //   subject: 'Look what I made!',
                              // );

                              print("share text "  '${newsModel.title!.rendered}');
                              print("link url " 'https://punchng.com/' '${newsModel.slug}');

                            } ,
                            icon:  Icon (
                                Icons.share ,
                                color: Theme.of(context).textTheme.bodyText1!.color
                            ) ,
                          ) ,

                        ) ,
                      ] ,
                    ) ,

                    body: deepProvider.loading==true?
                    const Center (
                      child: CircularProgressIndicator ( backgroundColor:mainColor,) ,
                    )
                    : ListView (
                      padding: const EdgeInsets.symmetric ( horizontal: 10 ) ,
                      children: <Widget>[
                        Stack (
                          alignment: Alignment.bottomCenter ,
                          children: <Widget>[
                            ClipRRect (
                              borderRadius: const BorderRadius.all (
                                Radius.circular ( 10.0 ) , ) ,
                              child: CachedNetworkImage (
                                imageUrl: '${newsModel.xFeaturedMediaLarge}' ,
                                placeholder: (context , url) =>
                                const Center (
                                  child: CircularProgressIndicator (color: mainColor, ) , ) ,
                                errorWidget: (context , url , error) =>
                                Image.asset ( 'assets/punchLogo.png' ) ,
                                // Ico n ( Icons.close ) ,
                                fit: BoxFit.contain ,
                              ) ,
                            ),
                          ] ,
                        ) ,

                        const SizedBox ( height: 5 ) ,

                        Column (
                          mainAxisSize: MainAxisSize.max ,
                          crossAxisAlignment: CrossAxisAlignment.end ,
                          children: <Widget>[
                           const SizedBox ( height: 9 , ) ,
                            Align(
                              alignment: Alignment.topRight,
                              child: Container (
                                padding: const EdgeInsets.symmetric( vertical: 5 ) ,
                                child: Column(
                                  children: [
                                    Row (
                                      children: <Widget>[
                                        Container (
                                          padding: const EdgeInsets.only ( left: 0 ) ,
                                          child: Icon ( Icons.person ,
                                            color: Theme.of ( context ).primaryColor,
                                            size: 12.0 ,
                                          ) ,
                                        ) ,
                                        Expanded (
                                          child: Container (
                                              padding: const EdgeInsets.only ( left: 5 ) ,
                                              child: Text (
                                                '${newsModel.xAuthor}',
                                                style: TextStyle (color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 12 ) ,
                                                overflow: TextOverflow.ellipsis ,
                                                maxLines: 2 ,
                                              )
                                          ) ,
                                        ) ,
                                      ] ,
                                    ),
                                  ],
                                ) ,
                              ),
                            ) ,

                            const SizedBox  ( height: 9 , ) ,

                            Row (
                              children: [
                                SizedBox (
                                  height: 25 ,
                                  child: ListView.builder (
                                    scrollDirection: Axis.horizontal ,
                                    itemCount: 1 ,
                                    shrinkWrap: true ,
                                    itemBuilder: (BuildContext context , int index) {
                                      return
                                        Container (
                                          padding: const EdgeInsets.symmetric ( horizontal: 5 , vertical: 3 ) ,
                                          margin: const EdgeInsets.only ( right: 5.0 ) ,
                                          decoration: BoxDecoration ( borderRadius: BorderRadius.circular ( 5 ) ,
                                            color: mainColor ,
                                          ) ,
                                          child: Center (
                                            child: GestureDetector (
                                              onTap: () {
                                              } ,
                                              child:  Text (
                                                newsModel.categoriesString![0].replaceAll("&amp;", "&"),
                                                style: const TextStyle (fontSize: 10 , color: Colors.white,
                                                ) ,
                                              ) ,
                                            ) ,
                                          ) ,
                                        );
                                    } ,
                                  ) ,
                                ) ,
                                const Spacer ( ) ,

                                Container (
                                  padding: const EdgeInsets.only ( left: 5 ) ,
                                  child: Text (
                                      Jiffy('${newsModel.date}').fromNow(),
                                      // Constants.readTimestamp('${newsModel.date}'),
                                      maxLines: 2 ,
                                      style: TextStyle (fontSize: 12, color: Theme.of(context).textTheme.bodyText1!.color,
                                      ) ) ,
                                ) ,

                              ] ,
                            ) ,
                            const SizedBox ( height: 5 ) ,

                            Material (
                                type: MaterialType.transparency ,
                                child: Html(
                                  data:  '${newsModel.title!.rendered}',
                                  style: {
                                    "body": Style(
                                        fontSize: const FontSize(20.0),
                                        fontWeight: FontWeight.w400,
                                        color:Theme.of(context).textTheme.bodyText1!.color
                                    ),
                                  },
                                )
                            ) ,
                          ] ,
                        ) ,
                        Divider ( color: Theme.of ( context ).textTheme.caption!.color ) ,

                        const SizedBox ( height: 10 ) ,

                        //FOR AD MANAGER UNITS
                        adShown?  Center(
                            child: SizedBox(
                              width: 300,
                              height: 250,
                              child: adManagerBannerWidget,
                            ))
                            : Container(height: 0),


                        const SizedBox ( height: 5 ) ,

                        //NEWS DETAILS BODY
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: newsModel.articleSplit!.length,
                            itemBuilder: (BuildContext context , int index) {
                              if (index != 0 && index % 5 == 0) {
                                return getAd();
                              } else {
                                return Html (
                                  data: newsModel.articleSplit![index].toString(),
                                  style: {
                                    "body": Style(
                                        fontSize: const FontSize(18),
                                        fontWeight: FontWeight.w400,
                                        color:Theme.of(context).textTheme.bodyText1!.color
                                    ),
                                  },
                                );
                              }
                            },

                            // itemBuilder: (BuildContext context , int index) {
                            //   if (index != 0 && index % 5 == 0) {
                            //     return getAd();
                            //   } else  {
                            //     Html(
                            //       data: newsModel.articleSplit![index]
                            //           .toString(),
                            //       style: {
                            //         "body": Style(
                            //             fontSize: const FontSize(18),
                            //             fontWeight: FontWeight.w400,
                            //             color: Theme
                            //                 .of(context)
                            //                 .textTheme
                            //                 .bodyText1!
                            //                 .color
                            //         ),
                            //       },
                            //     );
                            // }
                            // },
                            separatorBuilder: ( context, index) {
                           return Container();

                            }
                            //   return index != 0 && index % 5 == 0
                            //       ? Container(
                            //     alignment: Alignment.center,
                            //     child: inArticleWidget,
                            //     color: Colors.blue,
                            //     height: 100,
                            //   )
                            //       : Container(height: 10);
                            // }
                        ),


                       const SizedBox(height: 15),

                        SizedBox (
                          child: mediumWidget ,
                          width: MediaQuery.of ( context ).size.width ,
                          height: 250,
                        ) ,

                        const SizedBox(height: 15),

                      ] ,
                    )
                );
              });
        },
    );

  }

}

