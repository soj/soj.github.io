const castContext = cast.framework.CastReceiverContext.getInstance();
const playerManager = castContext.getPlayerManager();
const queueManager = playerManager.getQueueManager();
const streamManager = new google.ima.cast.dai.api.StreamManager();
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();
const playbackConfig = new cast.framework.PlaybackConfig();
//const castReceiverOptions = new cast.framework.CastReceiverOptions();

const getStreamRequest = (requestData) => {
  let streamRequest = null;
  // Live stream only
  if (requestData.assetKey) {
    streamRequest = new google.ima.cast.dai.api.LiveStreamRequest();
    streamRequest.assetKey = requestData.assetKey;
  }
  if (streamRequest) {
    if (requestData.ApiKey) {
      streamRequest.ApiKey = requestData.ApiKey;
    }
    if (requestData.authToken) {
      streamRequest.authToken = requestData.authToken;
    }
    if (requestData.senderCanSkip) {
      streamRequest.senderCanSkip = requestData.senderCanSkip;
    }
    if (requestData.adTagParameters) {
      streamRequest.adTagParameters = requestData.adTagParameters;
    }
    if (requestData.licenseUrl) {
      playbackConfig.licenseUrl = requestData.licenseUrl;
    }
  }
  return streamRequest;
};

playerManager.setMessageInterceptor(
  cast.framework.messages.MessageType.LOAD, (request) => {
    if (!request.media) {
      return;
    }
    // Do not modify queue entries containing Ad Requests
    if (request.media.vmapAdsRequest) {
      return request;
    }
    // Only modify requests containing a DAI Live stream assetKey
    if (request.media.customData.assetKey) {
      request.media.hlsSegmentFormat = cast.framework.messages.HlsSegmentFormat.TS;

      const streamRequest = getStreamRequest(request.media.customData);
      return streamManager.requestStream(request, streamRequest)
        .then((request) => {
          return Promise.resolve(request);
        })
        .catch((error) => {
          // this.broadcast('Stream request failed.');
          return Promise.resolve(request);
        });
    } else {
      // VOD with adTagUrl value in the customData object
      if (request.media.customData && request.media.customData.adTagUrl) {
        request.media.vmapAdsRequest = {
          adTagUrl: request.media.customData.adTagUrl
        };    
      }
      return request;
    }
  });

castDebugLogger.setEnabled(true);
castDebugLogger.showDebugLogs(false);
castDebugLogger.loggerLevelByTags = {
  'EVENT.CORE': cast.framework.LoggerLevel.DEBUG,
  'MyAPP.LOG': cast.framework.LoggerLevel.WARNING
};

// castReceiverOptions.useShakaForHls = true;


// playbackConfig.licenseUrl = '';
// playbackConfig.protectionSystem = cast.framework.ContentProtection.WIDEVINE;
// playbackConfig.licenseRequestHandler = requestInfo => {
//   requestInfo.withCredentials = false;
// };

// playbackConfig.shakaConfig = { abr: { enabled: true, restrictions: { maxBandwidth: 500000 } } };

//castReceiverOptions.playbackConfig = playbackConfig;

// castContext.start(castReceiverOptions);

castContext.start({useShakaForHls: true, shakaVersion:'4.3.4'});