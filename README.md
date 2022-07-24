# Friend Activity for Spotify
iOS app &amp; widget for viewing what your Spotify friends are listening to. Made purely in SwiftUI. 

Watch what your friends are listening to & add it to your homescreen. Tap on each friend to open the playlist/album/artist/song in the Spotify app/website.

<p float="center">
<img src="https://user-images.githubusercontent.com/25706524/180601231-9bc22e29-fc03-4c5e-9089-d4d7c0c88bcc.png" height="400" />
<img src="https://user-images.githubusercontent.com/25706524/180601248-d5073e0c-251d-41d0-bd91-ac11592306e7.png" height="400" />
<img src="https://user-images.githubusercontent.com/25706524/180601251-737ca05c-ce98-4e4f-84d7-b9c1fefb3618.png" height="400" />
<img src="https://user-images.githubusercontent.com/25706524/180601253-280c6a2d-4095-4a6e-a349-d4d8dd20b70e.png" height="400" />
</p> 

Private profile pictures and names of friends removed in above screenshots.
                                                                                                                                                                                                                                                 
## Features:
- Dynamically update list of friends in homescreen (every 2 minutes, smooth animations)
- No ads.
- UI is the same as the official Spotify desktop UI, but remodeled to work on mobile (context menu instead of links)
- Pure SwiftUI, efficient and fast
- Pull to refresh
- Context menu beneath each friend, letting you pick which song/album/artist to open in Spotify
- Airplane mode detection
- Enables login through official Spotify website (cookies are read and stored)
- Cookies stored securely in Keychain
- Widget automatically updates every 15 minutes (watch your friends' Spotify activity from your homescreen!)
- iPad & macOS Catalyst support (rudimentary)
- Friend profile pictures stored in cache and loaded asynchronously (using NukeUI) 

In beta right now, hence debug and errors can be seen everywhere
  
## Installation:
- Open in Xcode
                                                                                                                         
## Credits:
- [@Apple](https://github.com/apple) for [Swift](https://github.com/apple/swift) and SwiftUI
- [@JulietaUla](https://github.com/JulietaUla) for the [Montesrrat font](https://github.com/JulietaUla/Montserrat) (used extensively within the app)
- [@kishikawakatsumi](https://github.com/kishikawakatsumi) for [KeychainAccess](https://github.com/kishikawakatsumi/keychainaccess) (for storing spDcCookie and accessToken of Spotify securely between app and widget)
- [@markiv](https://github.com/markiv) for [SwiftUI-Shimmer](https://github.com/markiv/SwiftUI-Shimmer) for the shimmer animation of first load of homescreen
- [@kean](https://github.com/kean) for [Nuke](https://github.com/kean/Nuke) (used to display images asynchronously in Widget and app)
- [@Sketch](https://github.com/sketch-hq) for Sketch (for designing the app icon)
- [@valeriangalliat](https://github.com/valeriangalliat) for [spotify-buddylist](https://github.com/valeriangalliat/spotify-buddylist) (pseudocode taken from here)
