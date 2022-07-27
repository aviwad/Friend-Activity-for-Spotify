//
//  WebviewLogin.swift
//  Friend Activity for Spotify
//
//  Created by Avi Wadhwa on 2022-07-21.
//

import SwiftUI
//import WKView
import WebKit

struct GoogleView : UIViewRepresentable {
    
    let request: URLRequest
    var navigationState : NavigationState
    
    
    func makeUIView(context: Context) -> WKWebView  {
        let webView = navigationState.webView
        webView.navigationDelegate = navigationState
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Mobile/15E148 Safari/604.1"
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}


struct GoogleViewLogin: View {
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
    @StateObject var navigationState = NavigationState()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let removeEverythingBesidesGoogleScript = "var elements = document.querySelectorAll('[data-testid=\"login-form\"]'); for (let element of elements) { element.style.display = \"none\"; }; elements = document.querySelectorAll('[data-testid=\"phone-login\"]'); for (let element of elements) { element.style.display = \"none\"; }; elements = document.querySelectorAll('[data-testid=\"apple-login\"]'); for (let element of elements) { element.style.display = \"none\"; };elements = document.querySelectorAll('[data-testid=\"facebook-login\"]'); for (let element of elements) { element.style.display = \"none\"; };"
    var body: some View {
        VStack {
            //WebView(request: URLRequest(url: URL(string: "https://www.whatismybrowser.com/detect/what-is-my-user-agent/")!), navigationState: navigationState)
            GoogleView(request: URLRequest(url: URL(string: "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!), navigationState: navigationState)
                .onReceive(timer) { _ in
                    navigationState.webView.evaluateJavaScript(removeEverythingBesidesGoogleScript) { (response, error) in
                        print("logged timer for javascript run")
                        if (error != nil) {
                            print("logged timer for javascript error: \(error)")
                        }
                        if (response != nil) {
                            print("logged timer over")
                            print("logged \(response.debugDescription) and error \(String(describing: error?.localizedDescription))")
                            self.timer.upstream.connect().cancel()
                        }
                    }
                 }
            /*if (navigationState.url?.absoluteString.starts(with: "https://accounts.google.com")) {
                UIApplication.shared.open(navigationState.url, options: [:])
            }*/
           /* else if (navigationState.url?.absoluteString == "https://open.spotify.com/#_=_" && FriendActivityBackend.shared.loggedOut == true) {
                let hi = checkIfLoggedIn()
                Text("hi")
            }*/
                
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
