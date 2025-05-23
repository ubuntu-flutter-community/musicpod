class PageIDs {
  static const settings = 'settings';
  static const homePage = 'homePage';
  static const localAudio = 'localAudio';
  static const podcasts = 'podcasts';
  static const radio = 'radio';
  static const customContent = 'newCustomContent';
  static const likedAudios = 'likedAudios';
  static const searchPage = 'searchPageId';

  static const replacers = {homePage, localAudio, podcasts, radio};

  static const permanent = {
    homePage,
    searchPage,
    likedAudios,
    localAudio,
    podcasts,
    radio,
    settings,
    customContent,
  };
}
