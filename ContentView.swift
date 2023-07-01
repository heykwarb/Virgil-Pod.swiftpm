import SwiftUI

struct ContentView: View {
    @ObservedObject var player = playerModel()
    
    @State var albumTitle = "Yeezus"
    @State var songTitle = "On Sight"
    @State var albumCover = "yeezus cover"
    
    @State var songLengthSec: CGFloat = 156
    @State var songDuration: CGFloat = 47
    
    @State var timerChange = true
    @State var timerSize: Font = .title3
    
    @State var playButton = "play.fill"
    @State var isPlaying = false
    
    var screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                ZStack{
                    if player.albumArt != nil{
                        Image(uiImage: player.albumArt!)
                            .resizable()
                            .scaledToFill()
                            .opacity(1)
                            .frame(width: screenSize.width)
                    }
                    
                    VStack(alignment: .center){
                        Spacer()
                        Button(action:{
                            player.showPicker.toggle()
                        }){
                            VStack(alignment: .leading){
                                TitleView(genre: "Artist", title: $player.artistName)
                                
                                TitleView(genre: "Album", title: $player.albumtitle)
                                
                                TitleView(genre: "Song", title: $player.songTitle)
                            }
                        }
                        .sheet(isPresented: $player.showPicker, onDismiss: {
                            player.picker()
                        }, content: {
                            MusicPicker(collection: $player.collection, isPicked: $player.isPicked)
                        })
                        
                        HStack{
                            Text("\(player.cPTime) : \(player.pDuration)")
                                .font(timerSize)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .gesture(
                            LongPressGesture(minimumDuration: 1)
                                .onEnded(){_ in
                                    withAnimation(){
                                        ///timerChange = true
                                        ///timerSize = .title3
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged(){value in
                                    if timerChange{
                                        songDuration += -(value.startLocation.x - value.location.x)/songLengthSec
                                        if songDuration <= 0 {
                                            songDuration = 0
                                        }else if songDuration >= songLengthSec{
                                            songDuration = songLengthSec
                                        }
                                    }
                                }
                                .onEnded(){_ in
                                    withAnimation(){
                                        ///timerChange = false
                                        ///timerSize = .body
                                    }
                                }
                        )
                        
                        HStack{
                            Spacer()
                            
                            Button(action: {
                                
                            }){
                                ButtonView(symbolName: "backward.fill")
                            }
                            .padding()
                            
                            Button(action: {
                                player.playButton()
                            }){
                                ButtonView(symbolName: player.playbackStateImage)
                            }
                            .padding()
                            
                            Button(action: {
                                
                            }){
                                ButtonView(symbolName: "forward.fill")
                            }
                            .padding()
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    ///.ignoresSafeArea()
                    
                    .background(.thinMaterial)
                }
                .navigationTitle("\"NOW PLAYING\"")
                .onAppear(perform: {
                    player.getMediaInfo()
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct TitleView: View {
    var genre: String
    @Binding var title: String
    
    var body: some View{
        VStack(alignment: .leading){
            Text(genre)
                ///.font(.caption)
                .font(.custom("Baskerville", size: 16))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundColor(.secondary)
            Text("\"\(title)\"")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .textCase(.uppercase)
                .foregroundColor(.red)
        }
        .padding()
    }
}

struct ButtonView: View {
    var symbolName: String
    
    var body: some View{
        Image(systemName: symbolName)
            .font(.title)
            .foregroundColor(.red)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .white.opacity(0.6), radius: 2, x: 0, y: -2)
            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
    }
}
