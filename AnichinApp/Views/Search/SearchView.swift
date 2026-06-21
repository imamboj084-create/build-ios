import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filters
                if showFilters {
                    filtersSection
                }
                
                // Results
                if viewModel.isSearching {
                    LoadingView()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    emptyState
                } else {
                    resultsGrid
                }
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea())
            .navigationTitle("Cari Donghua")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Donghua.self) { donghua in
                DetailView(donghua: donghua)
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Cari donghua...", text: $viewModel.searchQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchQuery) { _, _ in
                        Task {
                            await viewModel.search()
                        }
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                withAnimation {
                    showFilters.toggle()
                }
            } label: {
                Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Status Filter
                FilterMenu(
                    title: "Status",
                    selection: $viewModel.selectedStatus,
                    options: DonghuaStatus.allCases
                )
                
                // Type Filter
                FilterMenu(
                    title: "Tipe",
                    selection: $viewModel.selectedType,
                    options: DonghuaType.allCases
                )
                
                // Apply Button
                Button {
                    Task {
                        await viewModel.browse()
                    }
                } label: {
                    Text("Terapkan")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                
                // Reset Button
                Button {
                    viewModel.resetFilters()
                } label: {
                    Text("Reset")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
    }
    
    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                ForEach(viewModel.searchResults) { donghua in
                    NavigationLink(value: donghua) {
                        DonghuaCard(donghua: donghua, size: .small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Tidak ada hasil")
                .font(.headline)
            
            Text("Coba kata kunci lain")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

struct FilterMenu<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        Menu {
            Button("Semua") {
                selection = nil
            }
            
            ForEach(Array(options), id: \.self) { option in
                Button(option.rawValue) {
                    selection = option
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selection?.rawValue ?? title)
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    SearchView()
}
