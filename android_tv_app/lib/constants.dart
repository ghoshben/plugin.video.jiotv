class JioConstants {
  // Image roots
  static const imgPublic = 'https://jioimages.cdn.jio.com/imagespublic/';
  static const imgCatchup = 'https://jiotv.catchup.cdn.jio.com/dare_images/images/';
  static const imgCatchupShows = 'https://jiotv.catchup.cdn.jio.com/dare_images/shows/';

  // API endpoints
  static const featuredSrc = 'https://tv.media.jio.com/apis/v1.6/getdata/featurednew?start=0&limit=30&langId=6';
  static const channelsSrc = 'https://jiotvapi.cdn.jio.com/apis/v3.0/getMobileChannelList/get/?langId=6&devicetype=phone&os=android&usertype=JIO&version=343';
  static const getChannelUrl = 'https://tv.media.jio.com/apis/v2.0/getchannelurl/getchannelurl?langId=6&userLanguages=All';
  static const catchupSrc = 'https://jiotvapi.cdn.jio.com/apis/v1.3/getepg/get?offset={offset}&channel_id={channelId}&langId=6';
  static const dictionaryUrl = 'https://jiotvapi.cdn.jio.com/apis/v1.3/dictionary/dictionary?langId=6';

  // Sample image configuration for genres and languages
  static const imgConfig = {
    'Genres': {
      'Sports': {
        'tvImg': imgPublic + 'logos/langGen/Sports_1579245819981.jpg',
      },
      'Movies': {
        'tvImg': imgPublic + 'logos/langGen/movies_1579517470920.jpg',
      },
      'News': {
        'tvImg': imgPublic + 'logos/langGen/news_1579517470920.jpg',
      },
    },
    'Languages': {
      'Hindi': {
        'tvImg': imgPublic + 'logos/langGen/Hindi_1579245819981.jpg',
      },
      'English': {
        'tvImg': imgPublic + 'logos/langGen/English_1579245819981.jpg',
      },
      'Tamil': {
        'tvImg': imgPublic + 'logos/langGen/Tamil_1579245819981.jpg',
      },
    }
  };
}

