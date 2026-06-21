import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("autoPlayNextEpisode") private var autoPlayNextEpisode = true
    @AppStorage("videoQuality") private var videoQuality = "Auto"
    @AppStorage("downloadQuality") private var downloadQuality = "720p"
    
    @State private var cacheSize: String = "0 MB"
    @State private var showClearCacheAlert = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                // Playback Settings
                Section("Pemutaran") {
                    Toggle("Auto Play Episode Berikutnya", isOn: $autoPlayNextEpisode)
                    
                    Picker("Kualitas Video", selection: $videoQuality) {
                        Text("Auto").tag("Auto")
                        Text("1080p").tag("1080p")
                        Text("720p").tag("720p")
                        Text("480p").tag("480p")
                        Text("360p").tag("360p")
                    }
                }
                
                // Download Settings
                Section("Download") {
                    Picker("Kualitas Download", selection: $downloadQuality) {
                        Text("1080p").tag("1080p")
                        Text("720p").tag("720p")
                        Text("480p").tag("480p")
                    }
                }
                
                // Notifications
                Section("Notifikasi") {
                    Toggle("Aktifkan Notifikasi", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if enableNotifications {
                        NavigationLink("Atur Jadwal Notifikasi") {
                            NotificationScheduleView()
                        }
                    }
                }
                
                // Storage
                Section("Penyimpanan") {
                    HStack {
                        Text("Cache")
                        Spacer()
                        Text(cacheSize)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Hapus Cache") {
                        showClearCacheAlert = true
                    }
                    .foregroundStyle(.red)
                }
                
                // About
                Section("Tentang") {
                    HStack {
                        Text("Versi")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Tentang Anichin") {
                        showAbout = true
                    }
                    
                    Link("Kunjungi Anichin.moe", destination: URL(string: "https://anichin.moe")!)
                    
                    Button("Beri Rating") {
                        // Open app store rating
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                }
            }
            .task {
                await calculateCacheSize()
            }
            .alert("Hapus Cache", isPresented: $showClearCacheAlert) {
                Button("Batal", role: .cancel) {}
                Button("Hapus", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("Yakin ingin menghapus semua cache?")
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = try? await NotificationService.shared.requestAuthorization()
            if granted == false {
                enableNotifications = false
            }
        }
    }
    
    private func calculateCacheSize() async {
        let size = await CacheManager.shared.getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        cacheSize = formatter.string(fromByteCount: size)
    }
    
    private func clearCache() {
        Task {
            await CacheManager.shared.clearImageCache()
            await CacheManager.shared.clearFileCache()
            await calculateCacheSize()
        }
    }
}

struct NotificationScheduleView: View {
    @AppStorage("notifyMonday") private var notifyMonday = true
    @AppStorage("notifyTuesday") private var notifyTuesday = true
    @AppStorage("notifyWednesday") private var notifyWednesday = true
    @AppStorage("notifyThursday") private var notifyThursday = true
    @AppStorage("notifyFriday") private var notifyFriday = true
    @AppStorage("notifySaturday") private var notifySaturday = true
    @AppStorage("notifySunday") private var notifySunday = true
    
    var body: some View {
        List {
            Section("Notifikasi Jadwal Harian") {
                Toggle("Senin", isOn: $notifyMonday)
                Toggle("Selasa", isOn: $notifyTuesday)
                Toggle("Rabu", isOn: $notifyWednesday)
                Toggle("Kamis", isOn: $notifyThursday)
                Toggle("Jum'at", isOn: $notifyFriday)
                Toggle("Sabtu", isOn: $notifySaturday)
                Toggle("Minggu", isOn: $notifySunday)
            }
        }
        .navigationTitle("Jadwal Notifikasi")
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo/Icon
                    Image(systemName: "tv.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Anichin")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Versi 1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Aplikasi streaming donghua dengan subtitle Indonesia")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Text("Dibuat untuk penggemar donghua di Indonesia")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fitur")
                            .font(.headline)
                        
                        FeatureRow(icon: "play.circle.fill", title: "Streaming Unlimited")
                        FeatureRow(icon: "arrow.down.circle.fill", title: "Download untuk Offline")
                        FeatureRow(icon: "heart.fill", title: "Bookmark Favorit")
                        FeatureRow(icon: "clock.fill", title: "Track History")
                        FeatureRow(icon: "bell.fill", title: "Notifikasi Episode Baru")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    Text("© 2024 Anichin App\nSemua konten dari Anichin.moe")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding(.vertical, 32)
            }
            .gradientBackground()
            .navigationTitle("Tentang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Bookmark.self], inMemory: true)
}
