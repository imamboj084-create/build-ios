import SwiftUI

struct HeroSection: View {
    let donghua: Donghua
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink(value: donghua) {
            ZStack(alignment: .bottom) {
                // Background Image
                AsyncImage(url: donghua.displayImage) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 500)
                .clipped()
                
                // Gradient Overlay
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        Color.black.opacity(0.8),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    // Genres
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(donghua.genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Title
                    Text(donghua.displayTitle)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 10)
                    
                    // Synopsis
                    if let synopsis = donghua.synopsis {
                        Text(synopsis)
                            .font(.subheadline)
                            .lineLimit(3)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Play Button
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Tonton")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Info Button
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                            Text("Info")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        if let rating = donghua.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                        }
                        
                        Text(donghua.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.3))
                            .clipShape(Capsule())
                        
                        Text(donghua.type.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 0))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HeroSection(
            donghua: Donghua(
                id: "1",
                title: "Battle Through The Heavens Season 5",
                alternativeTitle: "Doupo Cangqiong",
                imageUrl: "",
                detailUrl: "",
                rating: 9.2,
                status: .ongoing,
                type: .donghua,
                synopsis: "INI ADALAH LANJUTAN DARI DONGHUA OYEN EPISODE 52. Cerita tentang Xiao Yan yang berlatih untuk menjadi kultivator terkuat di benua Dou Qi.",
                genres: ["Action", "Adventure", "Fantasy", "Martial Arts"],
                releaseDay: "Minggu",
                studio: "Tencent",
                totalEpisodes: 204
            )
        )
    }
}
