const context = cast.framework.CastReceiverContext.getInstance();
const playerManager = context.getPlayerManager();
const mediaElement = document.getElementsByTagName("cast-media-player")[0].getMediaElement();
const streamManager = new google.ima.cast.dai.api.StreamManager(mediaElement);
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();

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

        if (request.media.customData && request.media.customData.adTagUrl) {
            request.media.vmapAdsRequest = {
                adTagUrl: request.media.customData.adTagUrl
            };
            return request;    
        } else {
          return streamManager.requestStream(request, getStreamRequest(request))
          .then((request) => {
            return Promise.resolve(request);
            })
          .catch((error) => {
            return Promise.resolve(request);
            });
        }
  });

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
 * Shows the video controls so users can resume after stream is paused.
 */
 function onStreamPause() {
  console.log('paused');
  if (isAdBreak) {
    videoElement.controls = true;
    adUiDiv.style.display = 'none';
  }
}

/**
 * Hides the video controls if resumed during an ad break.
 */
function onStreamPlay() {
  console.log('played');
  if (isAdBreak) {
    videoElement.controls = false;
    adUiDiv.style.display = 'block';
  }
}

/**
if (context.start() != null) {
    let loadRequestData = new cast.framework.messages.LoadRequestData();
    loadRequestData.autoplay = true;
    playerManager.load(loadRequestData);
}
**/
