import SwiftUI

struct DonghuaCard: View {
    let donghua: Donghua
    var size: CardSize = .medium
    
    enum CardSize {
        case small, medium, large, hero
        
        var width: CGFloat {
            switch self {
            case .small: return 120
            case .medium: return 140
            case .large: return 160
            case .hero: return UIScreen.main.bounds.width - 32
            }
        }
        
        var height: CGFloat {
            switch self {
            case .small: return 180
            case .medium: return 210
            case .large: return 240
            case .hero: return 500
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster Image
            AsyncImage(url: donghua.displayImage) { phase in
                switch phase {
                case .empty:
                    shimmerPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    failurePlaceholder
                @unknown default:
                    shimmerPlaceholder
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Gradient overlay
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.7)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(alignment: .bottomLeading) {
                // Status badge
                if donghua.status != .unknown {
                    statusBadge
                        .padding(8)
                }
            }
            .overlay(alignment: .topTrailing) {
                // Rating badge
                if let rating = donghua.rating, rating > 0 {
                    ratingBadge(rating)
                        .padding(8)
                }
            }
            
            if size != .hero {
                // Title
                Text(donghua.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(width: size.width, alignment: .leading)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    private var shimmerPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: size.width, height: size.height)
            .shimmer()
    }
    
    private var failurePlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundStyle(.gray)
        }
        .frame(width: size.width, height: size.height)
    }
    
    private var statusBadge: some View {
        Text(donghua.status.rawValue)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
    
    private func ratingBadge(_ rating: Double) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(String(format: "%.1f", rating))
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundStyle(.yellow)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// Shimmer effect
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            DonghuaCard(
                donghua: Donghua(
                    id: "1",
                    title: "Battle Through The Heavens",
                    alternativeTitle: nil,
                    imageUrl: "https://example.com/image.jpg",
                    detailUrl: "",
                    rating: 9.2,
                    status: .ongoing,
                    type: .donghua,
                    synopsis: nil,
                    genres: [],
                    releaseDay: nil,
                    studio: nil,
                    totalEpisodes: nil
                ),
                size: .medium
            )
        }
    }
}
