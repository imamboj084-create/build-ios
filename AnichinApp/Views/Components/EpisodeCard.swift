import SwiftUI

struct EpisodeCard: View {
    let episode: Episode
    var thumbnail: String?
    var progress: Double?
    
    var body: some View {
        HStack(spacing: 12) {
            // Episode thumbnail
            AsyncImage(url: thumbnail.flatMap { URL(string: $0) }) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: 140, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .bottom) {
                if let progress = progress, progress > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                            
                            Rectangle()
                                .fill(.red)
                                .frame(width: geo.size.width * progress)
                        }
                        .frame(height: 3)
                    }
                }
            }
            
            // Episode info
            VStack(alignment: .leading, spacing: 4) {
                Text("Episode \(episode.episodeNumber)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(episode.donghuaTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                if let progress = progress, progress > 0 {
                    Text("\(Int(progress * 100))% ditonton")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay {
                Image(systemName: "play.rectangle.fill")
                    .font(.title)
                    .foregroundStyle(.gray)
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 12) {
            EpisodeCard(
                episode: Episode(
                    id: "1",
                    episodeNumber: 204,
                    title: "BTTH Season 5 Episode 204",
                    donghuaId: "btth",
                    donghuaTitle: "Battle Through The Heavens",
                    url: "",
                    releaseDate: nil,
                    thumbnail: nil
                ),
                progress: 0.65
            )
            
            EpisodeCard(
                episode: Episode(
                    id: "2",
                    episodeNumber: 88,
                    title: "Tales of Herding Gods Episode 88",
                    donghuaId: "tohm",
                    donghuaTitle: "Tales of Herding Gods",
                    url: "",
                    releaseDate: nil,
                    thumbnail: nil
                )
            )
        }
        .padding()
    }
}
