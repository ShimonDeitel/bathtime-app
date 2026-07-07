import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var newTitle = ""
    @State private var newNote = ""
    @State private var newValue: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.textSecondary)
                        Text("No events yet")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(Theme.bodyFont.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .listRowBackground(Theme.card)
                            .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Bath Time")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            newTitle = ""
                            newNote = ""
                            newValue = 0
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addSheet
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var addSheet: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("Title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("titleField")
                    TextField("Note (optional)", text: $newNote)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("noteField")
                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("New CareEvent")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                        .accessibilityIdentifier("cancelAddButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = CareEventEntry(title: newTitle.isEmpty ? "Untitled" : newTitle, note: newNote, value: newValue)
                        if store.add(entry) {
                            showAddSheet = false
                        } else {
                            showAddSheet = false
                            showPaywall = true
                        }
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(PurchaseManager())
}
