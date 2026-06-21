import SwiftUI

struct ContinueWatchingCard: View {
    let history: WatchHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail with progress
            AsyncImage(url: URL(string: history.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 240, height: 135)
            .clipped()
            .overlay(alignment: .center) {
                // Play icon
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 10)
            }
            .overlay(alignment: .bottom) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.gray.opacity(0.5))
                        
                        Rectangle()
                            .fill(.red)
                            .frame(width: geo.size.width * history.progress)
                    }
                    .frame(height: 4)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(history.donghuaTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text("Episode \(history.episodeNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(Int(history.progress * 100))% ditonton")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            .padding(8)
            .frame(width: 240, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ContinueWatchingCard(
            history: WatchHistory(
                donghuaId: "1",
                donghuaTitle: "Battle Through The Heavens",
                imageUrl: "",
                episodeId: "204",
                episodeNumber: 204,
                episodeTitle: "Episode 204",
                currentTime: 650,
                duration: 1200,
                completed: false
            )
        )
        .padding()
    }
}
