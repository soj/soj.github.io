const context = cast.framework.CastReceiverContext.getInstance();
const playerManager = context.getPlayerManager();
const mediaElement = document.getElementsByTagName("cast-media-player")[0].getMediaElement();
const streamManager = new google.ima.cast.dai.api.StreamManager(mediaElement);
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();

let adsLoader;
let adDisplayContainer;
let adsManager;

// Preroll ad tag
const TEST_AD_TAG = 'https://pubads.g.doubleclick.net/gampad/ads?' +
    'iu=/21775744923/external/single_ad_samples&sz=640x480&' +
    'cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&' +
    'output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=';


const getStreamRequest = (request) => {
  const imaRequestData = request.media.customData;
  let streamRequest = null;
  if (imaRequestData.assetKey) {
    // Live stream
    streamRequest = new google.ima.cast.dai.api.LiveStreamRequest();
    streamRequest.assetKey = imaRequestData.assetKey;
  }
  if (streamRequest && imaRequestData.ApiKey) {
    streamRequest.ApiKey = imaRequestData.ApiKey;
  }
  if (streamRequest && imaRequestData.senderCanSkip) {
    streamRequest.senderCanSkip = imaRequestData.senderCanSkip;
  }

  return streamRequest;
};

playerManager.setMessageInterceptor(
    cast.framework.messages.MessageType.LOAD, (request) => {

        request.media.hlsSegmentFormat = cast.framework.messages.HlsSegmentFormat.TS;

        // if (request.media.customData && request.media.customData.adTagUrl) {
        //     request.media.vmapAdsRequest = {
        //         adTagUrl: request.media.customData.adTagUrl
        //     };
        //     return request;    
        // } else {
          // return streamManager.requestStream(request, getStreamRequest(request))
          // .then((request) => {
          //   return Promise.resolve(request);
          //   })
          // .catch((error) => {
          //   return Promise.resolve(request);
          //   });
          requestAdddd("123")
//        }
  });


  function requestAdddd(qqq) {
    // Client side ads setup.
  adDisplayContainer = new google.ima.AdDisplayContainer(mediaElement);
  // Must be done as the result of a user action on mobile
  adDisplayContainer.initialize();

  adsLoader = new google.ima.AdsLoader(adDisplayContainer);
  adsLoader.addEventListener(
    google.ima.AdsManagerLoadedEvent.Type.ADS_MANAGER_LOADED,
    onAdsManagerLoaded, false);
  adsLoader.addEventListener(
    google.ima.AdErrorEvent.Type.AD_ERROR, onAdError, false);

  requestPreroll(TEST_AD_TAG);
  }

/** LOAD interceptor **/
/**
playerManager.setMessageInterceptor(
    cast.framework.messages.MessageType.LOAD,
    request => {
//        castDebugLogger.info('MyAPP.LOG', 'Intercepting LOAD request');
//        castDebugLogger.warn('MyAPP.LOG', 'Playable URL: ' + request.media.contentId);
//        castDebugLogger.warn('MyAPP.LOG', 'The Event type: ' + request.type);

        if (request.media.customData && request.media.customData.adTagUrl) {

//            castDebugLogger.warn('MyAPP.LOG', 'Ad Tag: ' + request.media.customData.adTagUrl);

            request.media.vmapAdsRequest = {
                adTagUrl: request.media.customData.adTagUrl
            };    
        }

        return request;
    });
**/

//const castDebugLogger = cast.debug.CastDebugLogger.getInstance();

// Enable debug logger and show a warning on receiver
// NOTE: make sure it is disabled on production
castDebugLogger.setEnabled(true);

// Show debug overlay
castDebugLogger.showDebugLogs(false);

/** Debug Logger **/
// Set verbosity level for custom tags
castDebugLogger.loggerLevelByTags = {
    'EVENT.CORE': cast.framework.LoggerLevel.DEBUG,
    'MyAPP.LOG': cast.framework.LoggerLevel.WARNING
};

playerManager.addEventListener(
    cast.framework.events.category.CORE,
    event => {
        castDebugLogger.info('EVENT.CORE', event);
    });

context.start();

/**
 * Requests a preroll ad using the client side SDK.
 * @param {string} adTagUrl
 */
 function requestPreroll(adTagUrl) {
  const adsRequest = new google.ima.AdsRequest();
  adsRequest.adTagUrl = adTagUrl;
  adsRequest.linearAdSlotWidth = 640;
  adsRequest.linearAdSlotHeight = 400;
  adsLoader.requestAds(adsRequest);
}

/**
 * Handles the adsManagerLoaded event (client side ads).
 * @param {!google.ima.dai.api.AdsManagerLoadedEvent} adsManagerLoadedEvent
 */
 function onAdsManagerLoaded(adsManagerLoadedEvent) {
  adsManager = adsManagerLoadedEvent.getAdsManager(mediaElement);
  adsManager.addEventListener(google.ima.AdErrorEvent.Type.AD_ERROR, onAdError);
  adsManager.addEventListener(
      google.ima.AdEvent.Type.CONTENT_PAUSE_REQUESTED, function(e) {
        console.log('Content pause requested.');
      });
  adsManager.addEventListener(
      google.ima.AdEvent.Type.CONTENT_RESUME_REQUESTED, function(e) {
        console.log('Content resume requested.');
        requestLiveStream(TEST_ASSET_KEY, null);
      });
  try {
    adsManager.init(640, 360, google.ima.ViewMode.NORMAL);
    adsManager.start();
  } catch (adError) {
    // An error may be thrown if there was a problem with the VAST response.
  }
}

/**
 * Handles an ad error (client side ads).
 * @param {!google.ima.dai.api.AdErrorEvent} adErrorEvent
 */
 function onAdError(adErrorEvent) {
  console.log(adErrorEvent.getError());
  if (adsManager) {
    adsManager.destroy();
  }
}


/**
if (context.start() != null) {
    let loadRequestData = new cast.framework.messages.LoadRequestData();
    loadRequestData.autoplay = true;
    playerManager.load(loadRequestData);
}
**/
