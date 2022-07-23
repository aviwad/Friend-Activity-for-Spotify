//
//  WebviewLogin.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-07-21.
//

import SwiftUI
//import WKView
import WebKit

class NavigationState : NSObject, ObservableObject {
    @Published var url : URL?
    let webView = WKWebView()
}
extension NavigationState : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url = webView.url
    }
}


struct WebView : UIViewRepresentable {
    
    let request: URLRequest
    var navigationState : NavigationState
    
    func makeUIView(context: Context) -> WKWebView  {
        let webView = navigationState.webView
        webView.navigationDelegate = navigationState
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct WebviewLogin: View {
    init() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }
    func checkIfLoggedIn() {
        FriendActivityBackend.shared.tabSelection = 1
        FriendActivityBackend.shared.loggedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("dispatch queue is working")
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                cookies.forEach { cookie in
                    if (cookie.name == "sp_dc") {
                        FriendActivityBackend.shared.keychain["spDcCookie"] = cookie.value
                        Task {
                            await FriendActivityBackend.shared.GetAccessToken()
                            await FriendActivityBackend.shared.GetFriendActivity()
                        }
                    }
                }
            }
            //print(cookies)
            //let newCookies = HTTPCookieStorage.shared.cookies
            //newCookies!.forEach { cookie in
              //  print(cookie.name)
            //}
        }
    }
    @StateObject var navigationState = NavigationState()
    var body: some View {
        VStack {
            WebView(request: URLRequest(url: URL(string: "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!), navigationState: navigationState)
            if (navigationState.url?.absoluteString == "https://open.spotify.com/" && FriendActivityBackend.shared.loggedOut == true) {
                let hi = checkIfLoggedIn()
                Text("hi")
            }
        }/*{ (onNavigationAction) in
            switch onNavigationAction {
            case .didRecieveAuthChallenge(let webView, let challenge, let disposition, let credential):
                if(webView.url.unsafelyUnwrapped.absoluteString == "https://open.spotify.com/" && FriendActivityBackend.shared.loggedOut == true) {
                    FriendActivityBackend.shared.loggedOut = false
                    //WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                        
                   // }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        print("dispatch queue is working")
                        let cookies = WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                            cookies.forEach { cookie in
                                if (cookie.name == "sp_dc") {
                                    FriendActivityBackend.shared.spDcCookie = cookie.value
                                    Task {
                                        do {
                                            try await FriendActivityBackend.shared.GetAccessToken()
                                            try await FriendActivityBackend.shared.GetFriendActivity()
                                            
                                        }
                                        catch {
                                            
                                        }
                                    }
                                }
                            }
                        }
                        //print(cookies)
                        //let newCookies = HTTPCookieStorage.shared.cookies
                        //newCookies!.forEach { cookie in
                          //  print(cookie.name)
                        //}
                    }
                    //webView.stopLoading()
                }
            default:
                print("lol")
            }
        }*/
                            
    }
}

struct WebviewLogin_Previews: PreviewProvider {
    static var previews: some View {
        WebviewLogin()
    }
}
