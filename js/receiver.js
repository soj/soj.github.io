const context = cast.framework.CastReceiverContext.getInstance();
const playerManager = context.getPlayerManager();


/** LOAD interceptor **/
playerManager.setMessageInterceptor(
    cast.framework.messages.MessageType.LOAD,
    request => {
        castDebugLogger.info('MyAPP.LOG', 'Intercepting LOAD request');

        castDebugLogger.warn('MyAPP.LOG', 'Playable URL: ' + request.media.contentId);

        if (request.media.customData && request.media.customData.adTagUrl) {

            castDebugLogger.warn('MyAPP.LOG', 'Ad Tag: ' + request.media.customData.adTagUrl);

            request.media.vmapAdsRequest = {
                adTagUrl: request.media.customData.adTagUrl
            };    
        }

        return request;
    });

/** Debug Logger **/
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();

// Enable debug logger and show a warning on receiver
// NOTE: make sure it is disabled on production
castDebugLogger.setEnabled(true);

playerManager.addEventListener(
    cast.framework.events.category.CORE,
    event => {
        castDebugLogger.info('EVENT.CORE', event);
    });

// Set verbosity level for custom tags
castDebugLogger.loggerLevelByTags = {
    'EVENT.CORE': cast.framework.LoggerLevel.DEBUG,
    'MyAPP.LOG': cast.framework.LoggerLevel.WARNING
};

// Update playback config licenseUrl according to provided value in load request.
context.getPlayerManager().setMediaPlaybackInfoHandler((loadRequest, playbackConfig) => {
    if (loadRequest.media.customData && loadRequest.media.customData.adTagUrl) {
      playbackConfig.licenseUrl = loadRequest.media.customData.adTagUrl;
    }
    return playbackConfig;
  });

if (context.start() != null) {
    let loadRequestData = new cast.framework.messages.LoadRequestData();
    loadRequestData.autoplay = true;
    playerManager.load(loadRequestData);
}
