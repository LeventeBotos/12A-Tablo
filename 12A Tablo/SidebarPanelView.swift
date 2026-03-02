import SwiftUI

struct SidebarPanelView: View {
    @Binding var selection: SidebarItem?
    let studentCount: Int
    let teacherCount: Int

    private var totalCount: Int { studentCount + teacherCount }

    var body: some View {
        List(selection: $selection) {
            headerSection
            navigationSection
            statsSection
            classInfoSection
        }
        .scrollContentBackground(.hidden)
        .listStyle(.sidebar)
        .background(Color(nsColor: .controlBackgroundColor).ignoresSafeArea())
    }

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("12.A Dashboard")
                    .font(.system(.title2, design: .rounded).weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("Osztalytablo iranyitopult")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }

    private var navigationSection: some View {
        Section("Navigacio") {
            navRow("Tablo", systemImage: "square.grid.2x2.fill", item: .tablo)
            navRow("Kartyak", systemImage: "rectangle.grid.3x2.fill", item: .cards)
            navRow("Osztaly Info", systemImage: "person.3.fill", item: .classInfo)
            navRow("Evjarat 2018-2026", systemImage: "calendar", item: .years)
        }
    }

    private var statsSection: some View {
        Section("Statisztika") {
            statRow("Kartya osszesen", value: "\(totalCount)")
            statRow("Diakok", value: "\(studentCount)")
            statRow("Tanarok", value: "\(teacherCount)")
        }
    }

    private var classInfoSection: some View {
        Section("Osztaly Adatok") {
            infoRow("Evfolyam: 12.A", systemImage: "graduationcap.fill")
            infoRow("Osztalyfonok: Csorba Maria", systemImage: "person.crop.circle.badge.checkmark")
            infoRow("Tagozat: Informatika", systemImage: "building.2.fill")
        }
    }

    private func navRow(_ title: String, systemImage: String, item: SidebarItem) -> some View {
        NavigationLink(value: item) {
            Label(title, systemImage: systemImage)
        }
        .tag(item)
    }

    private func statRow(_ label: String, value: String) -> some View {
        LabeledContent(label) {
            Text(value)
                .font(.system(.body, design: .rounded).weight(.semibold))
        }
    }

    private func infoRow(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
    }
}
