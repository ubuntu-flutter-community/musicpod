final specialNotes = <String, String>{
  '3.0.0':
      'It finally happened - MusicPod 3.0.0 is out! But it has a few breaking changes:\n\n'
      '1. As mentioned in the last release notes, the way MusicPod stores data on your device has been completely reworked with SQLite (drift). This means that:\n'
      '- you need to re-import and re-create your local audio library\n'
      '- re-import your podcasts or look them up again in the search\n'
      '- re-import your radio stations or look them up again in the search\n'
      '- your local audio library is now only parsed once (except you rescan manually in the settings) and then read from database which should significantly speed up the launch time of the app on Windows\n\n'
      '2. The sidebar player has been removed since this layout was making the UI code too complicated to stay performant on all the different platforms\n\n'
      'Additionally:\n'
      '1. Many thanks to the wonderful people who helped me with the translation of the app - it is now available in many more languages!\n'
      '2. A big thanks to my sponsors! You people are awesome and the reason I can continue working on this project for free! :)\n'
      '3. Have fun with MusicPod 3.0.0+!',
};
