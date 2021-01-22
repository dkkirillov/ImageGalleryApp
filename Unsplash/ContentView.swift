//
//  ContentView.swift
//  Unsplash
//
//  Created by Dimitri Kirillov on 21/01/2021.
//

import SwiftUI
import UIKit
import SDWebImageSwiftUI

struct ContentView: View {
    var body: some View {
        Gallery()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Gallery: View {
    
    @State var expand = false
    @State var search = ""
    @State var page = 1
    @State var isSearching = false
    @ObservedObject var randomImages = GetData()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if !self.expand {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unsplash:")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Beautiful Free Images & Pictures")
                            .font(.caption)
                    }
                    .foregroundColor(Color.textLabel)
                }
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        withAnimation {
                            self.expand = true
                        }
                    }
                // Displays TextField when searchbar is activated
                if self.expand {
                    
                    TextField("Search for photos", text: self.$search)
                    
                    if self.search != "" {
                        
                        Button(action: {
                            self.randomImages.Images.removeAll()
                            self.isSearching = true
                            self.page = 1
                            self.searchData()
                            self.hideKeyboard()
                        }) {
                            Text("Search")
                                .fontWeight(.bold)
                                .foregroundColor(Color.textLabel)
                        }
                    }
                    Button(action: {
                        
                        withAnimation {
                            self.expand = false
                            self.hideKeyboard()
                        }
                        self.search = ""
                        
                        if self.isSearching {
                            self.isSearching = false
                            self.randomImages.Images.removeAll()
                            self.randomImages.updateData()
                        }
                        
                    })  {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.textLabel)
                    }
                    .padding(.leading, 10)
                }
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            
            if self.randomImages.Images.isEmpty {
                
                Spacer()
                
                if self.randomImages.noresults {
                    Text("No results found")
                        .foregroundColor(Color.textLabel)
                } else {
                    Indicator()
                }
                
                Spacer()
                
            } else {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    // Collection view
                    VStack(spacing: 15) {
                        ForEach(self.randomImages.Images, id: \.self) { i in
                            
                            HStack(spacing: 20) {
                                ForEach(i) { j in
                                    
                                    AnimatedImage(url: URL(string: j.urls["thumb"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 200)
                                        .cornerRadius(10)
                                        .contextMenu {
                                            // Saving image
                                            Button(action: {
                                                SDWebImageDownloader()
                                                    .downloadImage(with: URL(string: j.urls["full"]!)) { (image, _, _, _) in
                                                        
                                                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                                    }
                                            }) {
                                                HStack {
                                                    Text("Save image")
                                                    Spacer()
                                                    Image(systemName: "square.and.arrow.down")
                                                }
                                                .foregroundColor(Color.textLabel)
                                            }
                                            
                                        }
                                }
                            }
                        }
                        
                        // Geting more pictures
                        if !self.randomImages.Images.isEmpty {
                            if self.isSearching && self.search != "" {
                                HStack {
                                    Text("Page \(self.page)")
                                        .foregroundColor(Color.textLabel)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        self.randomImages.Images.removeAll()
                                        self.page += 1
                                        self.searchData()
                                    }) {
                                        Text("Next")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textLabel)
                                    }
                                }
                                .padding(.horizontal, 25)
                                
                            } else {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.randomImages.Images.removeAll()
                                        self.randomImages.updateData()
                                    }) {
                                        HStack {
                                            Spacer()
                                            Text("Find inspiration")
                                                .fontWeight(.bold)
                                            
                                            Image(systemName: "ellipsis")
                                        }
                                        .foregroundColor(Color.textLabel)
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                        
                    }
                    .padding(.top)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func searchData() {
        let key = "mlCKA-SD6Vn-wyyLc0gs2_VyWqBrXpCvqVAVR6NGxfA"
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        let url = "https://api.unsplash.com/search/photos?page=\(self.page)&query=\(query)&client_id=\(key)"
        self.randomImages.searchData(url: url)
    }
}

struct Indicator: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}


extension Color {
    
    static var textLabel: Color  {
        return Color("textLabel")
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
