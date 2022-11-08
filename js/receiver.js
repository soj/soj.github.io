const castContext = cast.framework.CastReceiverContext.getInstance();
const playerManager = castContext.getPlayerManager();
const queueManager = playerManager.getQueueManager();
const streamManager = new google.ima.cast.dai.api.StreamManager();
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();

const deepCopy = (original) => {
  return JSON.parse(JSON.stringify(original));
};

const insertNextInQueue = (newEntry) => {
  const currentIndex = queueManager.getCurrentItemIndex();
  const queue = queueManager.getItems();
  if (currentIndex >= queue.length) {
    queueManager.insertItems([newEntry]);
    return;
  }
  const nextItem = queue[currentIndex + 1];
  queueManager.insertItems([newEntry], nextItem.itemId);
};

var savedMediaInformation;

/**
 * When a queue item finishes playback, if it contained both a VMAP tag and a DAI assetKey,
 * create a new queue item, next in the queue, containing the DAI assetKey, but not the VMAP request.
 * finally, to clean up, remove the current queue itemm.
 **/
playerManager.addEventListener(cast.framework.events.EventType.MEDIA_FINISHED, (e) => {
  const queueItem = queueManager.getCurrentItem();
  const media = queueItem.media;
  //const media = savedMediaInformation;
  if (!media.vmapAdsRequest) {
    return;
  }
  if (!media.customData.assetKey) {
    return;
  }
  const newMedia = deepCopy(media);
  newMedia.vmapAdsRequest = null;

  const daiQueueItem = new cast.framework.messages.QueueItem();
  daiQueueItem.media = newMedia;
  insertNextInQueue(daiQueueItem);
  queueManager.removeItems([queueItem.itemId]);
});

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
    if (requestData.senderCanSkip) {
      streamRequest.senderCanSkip = requestData.senderCanSkip;
    }
  }
  return streamRequest;
};

/**
 * During the LOAD request only modify items without VMAP ad requests.
 **/
playerManager.setMessageInterceptor(
  cast.framework.messages.MessageType.LOAD, (request) => {
    if (!request.media) {
      return;
    }
    // Do not modify queue entries containing Ad Requests
    if (request.media.vmapAdsRequest) {
      savedMediaInformation = request.media;
      return request;
    }
    // Only modify requests containing a DAI Live stream assetKey
    if (request.media.customData.assetKey) {
      request.media.contentType = null;
      request.media.streamType = chrome.cast.media.LIVE;

      const streamRequest = getStreamRequest(request.media.customData);
      return streamManager.requestStream(request, streamRequest)
        .then((request) => {
          return Promise.resolve(request);
        })
        .catch((error) => {
          this.broadcast('Stream request failed.');
          return Promise.resolve(request);
        });
    }
  });

castDebugLogger.setEnabled(true);
castDebugLogger.showDebugLogs(true);
castDebugLogger.loggerLevelByTags = {
  'EVENT.CORE': cast.framework.LoggerLevel.DEBUG,
  'MyAPP.LOG': cast.framework.LoggerLevel.WARNING
};

castContext.start();