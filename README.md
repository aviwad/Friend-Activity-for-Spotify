# Friend Activity for Spotify
iOS app &amp; widget for viewing what your Spotify friends are listening to. Made purely in SwiftUI. 

Watch what your friends are listening to & add it to your homescreen. Tap on each friend to open the playlist/album/artist/song in the Spotify app/website.

Features:
- Dynamically update list of friends in homescreen (every 2 minutes, smooth animations)
- UI is the same as the official Spotify desktop UI, but remodeled to work on mobile (context menu instead of links)
- Pure SwiftUI, efficient and fast
- Pull to refresh
- Context menu beneath each friend, letting you pick which song/album/artist to open in Spotify
- Airplane mode detection
- Enables login through official Spotify website (cookies are read and stored)
- Cookies stored securely in Keychain
- Widget automatically updates every 15 minutes (watch your friends' Spotify activity from your homescreen!)
- iPad & macOS Catalyst support (rudimentary)

In beta right now, hence debug and errors can be seen everywhere

Credits:
- [@Apple](https://github.com/apple) for [Swift](https://github.com/apple/swift) and SwiftUI
- [@valeriangalliat](https://github.com/valeriangalliat) for [spotify-buddylist](https://github.com/valeriangalliat/spotify-buddylist) (pseudocode taken from here)
- [@markiv](https://github.com/markiv) for [SwiftUI-Shimmer](https://github.com/markiv/SwiftUI-Shimmer) for the shimmer animation of first load of homescreen
- [@Sketch](https://github.com/sketch-hq) for Sketch (for designing the app icon)
- [@kishikawakatsumi](https://github.com/kishikawakatsumi) for [KeychainAccess](https://github.com/kishikawakatsumi/keychainaccess) (for storing spDcCookie and accessToken of Spotify securely between app and widget)
