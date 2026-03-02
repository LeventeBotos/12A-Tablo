//
//  ContentView.swift
//  12A Tablo
//
//  Created by Levente Botos on 2026. 03. 02..
//

import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .tablo
    private let members = ClassMember.samples

    private var studentCount: Int {
        members.filter { $0.role == .student }.count
    }

    private var teacherCount: Int {
        members.filter { $0.role == .teacher }.count
    }

    var body: some View {
        NavigationSplitView {
            SidebarPanelView(
                selection: $selection,
                studentCount: studentCount,
                teacherCount: teacherCount
            )
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 340)
        } detail: {
            detailView(for: selection)
        }
//        .background(Color.black.ignoresSafeArea())
        .navigationSplitViewStyle(.balanced)
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem?) -> some View {
        switch item ?? .tablo {
        case .tablo:
            MainBoardView(members: members)
        case .cards:
            PlaceholderDetailView(
                title: "Kartyak",
                subtitle: "A kartyanezet hamarosan elerheto lesz."
            )
        case .classInfo:
            PlaceholderDetailView(
                title: "Osztaly Info",
                subtitle: "Az osztaly reszletes adatai itt jelennek meg."
            )
        case .years:
            PlaceholderDetailView(
                title: "Evjarat 2018-2026",
                subtitle: "Az evjarat tortenete es merfoldkovei itt lesznek."
            )
        }
    }
}

enum SidebarItem: String, Hashable, CaseIterable, Identifiable {
    case tablo
    case years
    case classInfo
    case cards

    var id: String { rawValue }
}

private enum MemberRole {
    case student
    case teacher
}

private struct ClassMember: Identifiable {
    let id: Int
    let name: String
    let role: MemberRole
    let subject: String?
    let imageURL: URL?

    var subtitle: String {
        subject ?? ""
    }

    static let samples: [ClassMember] = {
        // 30 students are rendered in the lower grid.
        let studentNames = [
            "Barta Adam", "Kiss Levente", "Nagy Aron", "Toth Bence", "Farkas David",
            "Molnar Patrik", "Varga Noel", "Szabo Martin", "Kovacs Gergely", "Lakatos Mark",
            "Horvath Balint", "Papp Peter", "Szalai Botond", "Juhasz Zoltan", "Fodor Krisztian",
            "Dani Bence", "Gulyas Daniel", "Kelemen Mate", "Veres Zsombor", "Boros Roland",
            "Kadar Nimrod", "Barna Hunor", "Csaszar Soma", "Gyori Attila", "Pintar Akos",
            "Sipos Lorand", "Karolyi Tibor", "Kadar David", "Major Adam", "Dobi Lehel"
        ]

        // 18 teachers are split across left/right blocks around the title.
        let teacherData: [(String, String)] = [
            ("Szabo Erika", "Magyar nyelv es irodalom"),
            ("Fekete Anna", "Tortenelem"),
            ("Miklosi Peter", "Matematika"),
            ("Kovacs Monika", "Angol nyelv"),
            ("Horvath Laszlo", "Informatika"),
            ("Benedek Judit", "Biologia"),
            ("Tamasi Gabor", "Fizika"),
            ("Nemes Katalin", "Kemiai ismeretek"),
            ("Kiss Zoltan", "Foldrajz"),
            ("Balogh Peter", "Testneveles"),
            ("Vincze Eszter", "Rajz es vizualis kultura"),
            ("Puskas Imre", "Enek-zene"),
            ("Bodnar Anna", "Nemet nyelv"),
            ("Csorba Maria", "Osztalyfonoki"),
            ("Lukacs Gyorgy", "Etika"),
            ("Toldi Zsuzsa", "Francia nyelv"),
            ("Hegedus Andras", "Gazdasagi ismeretek"),
            ("Gonda Rita", "Fenntarthatosag")
        ]

        let teachers = teacherData.enumerated().map { index, teacher in
            ClassMember(
                id: index + 1,
                name: teacher.0,
                role: .teacher,
                subject: teacher.1,
                imageURL: URL(string: "https://picsum.photos/seed/12A-T-\(index + 1)/560/720")
            )
        }

        let students = studentNames.enumerated().map { index, studentName in
            ClassMember(
                id: teacherData.count + index + 1,
                name: studentName,
                role: .student,
                subject: nil,
                imageURL: URL(string: "https://picsum.photos/seed/12A-S-\(index + 1)/560/720")
            )
        }

        return teachers + students
    }()
}

private struct MainBoardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let members: [ClassMember]

    private var titleTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var titleBackgroundColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.86) : Color.white.opacity(0.84)
    }

    private var titleShadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.46) : .black.opacity(0.14)
    }

    private var boardBackgroundColor: Color {
        colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : Color(nsColor: .underPageBackgroundColor)
    }

    var body: some View {
        GeometryReader { geometry in
            // Split members once so both groups can be positioned independently.
            let teachers = members.filter { $0.role == .teacher }
            let students = members.filter { $0.role == .student }
            let layout = separatedLayout(
                in: geometry.size,
                teacherCount: teachers.count,
                studentCount: students.count
            )
            let teacherEntries = Array(zip(teachers, layout.teacherPositions))
            let studentEntries = Array(zip(students, layout.studentPositions))

            ZStack {
                boardBackgroundColor.ignoresSafeArea()

                ForEach(teacherEntries.indices, id: \.self) { index in
                    let entry = teacherEntries[index]
                    MemberCard(member: entry.0, imageHeight: layout.imageHeight)
                        .frame(width: layout.cardWidth, height: layout.cardHeight)
                        .position(entry.1)
                }

                VStack(spacing: max(2, layout.titleFontSize * 0.04)) {
                    Text("12.A")
                        .font(.system(size: layout.titleFontSize, weight: .black, design: .rounded))
                        .foregroundStyle(titleTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)

                    Text("2018 - 2026")
                        .font(.system(size: layout.subtitleFontSize, weight: .heavy, design: .rounded))
                        .foregroundStyle(titleTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                }
                .frame(width: layout.titleWidth)
                .background(titleBackgroundColor)
                .shadow(color: titleShadowColor, radius: 10, x: 0, y: 5)
                .position(layout.titlePosition)

                ForEach(studentEntries.indices, id: \.self) { index in
                    let entry = studentEntries[index]
                    MemberCard(member: entry.0, imageHeight: layout.imageHeight)
                        .frame(width: layout.cardWidth, height: layout.cardHeight)
                        .position(entry.1)
                }
            }
        }
    }

    private func separatedLayout(in size: CGSize, teacherCount: Int, studentCount: Int) -> SeparatedLayout {
        let horizontalPadding: CGFloat = size.width < 980 ? 10 : 18
        let topPadding: CGFloat = size.height < 760 ? 10 : 16
        let bottomPadding: CGFloat = size.height < 760 ? 8 : 12
        let spacing: CGFloat = size.width < 980 ? 6 : 10
        let teacherRowSpacing: CGFloat = spacing + (size.width < 980 ? 3 : 5)
        let sectionGap: CGFloat = size.height < 760 ? 8 : 14

        // Teachers are displayed in two mirrored blocks around the center title.
        let leftCount = Int(ceil(Double(teacherCount) / 2.0))
        let rightCount = max(0, teacherCount - leftCount)

        let centerGap = max(160, min(size.width * 0.28, 290))
        let teacherBlockWidth = max(120, (size.width - (horizontalPadding * 2) - centerGap) / 2)
        let centerGapLeftEdge = horizontalPadding + teacherBlockWidth
        let centerGapRightEdge = centerGapLeftEdge + centerGap
        let studentAreaWidth = size.width - (horizontalPadding * 2)

        // Find the largest card size that allows both teacher + student sections to fit.
        var finalCardWidth: CGFloat = 48
        var finalCardHeight: CGFloat = 76
        var teacherColumns = 1
        var teacherRows = 1
        var studentColumns = 1

        let perSideCount = max(leftCount, rightCount)

        for width in stride(from: CGFloat(118), through: CGFloat(48), by: -1) {
            let cardHeight = width * 1.08 + 24

            let studentColumnCount = max(1, min(max(1, studentCount), Int((studentAreaWidth + spacing) / (width + spacing))))
            let studentColumnSpacing: CGFloat
            if studentColumnCount > 1 {
                let freeSpace = studentAreaWidth - (CGFloat(studentColumnCount) * width)
                studentColumnSpacing = max(0, freeSpace / CGFloat(studentColumnCount - 1))
            } else {
                studentColumnSpacing = 0
            }

            let studentColumnCenters = (0..<studentColumnCount).map { column in
                horizontalPadding + (width / 2) + CGFloat(column) * (width + studentColumnSpacing)
            }
            let leftAlignedColumns = studentColumnCenters.filter { $0 <= centerGapLeftEdge - (width / 2) }.count
            let rightAlignedColumns = studentColumnCenters.filter { $0 >= centerGapRightEdge + (width / 2) }.count
            let alignedColumnsPerSide = min(leftAlignedColumns, rightAlignedColumns)

            let tCols = max(1, min(max(1, perSideCount), alignedColumnsPerSide))
            let tRows = max(1, Int(ceil(Double(max(1, perSideCount)) / Double(tCols))))
            let teacherHeight = CGFloat(tRows) * cardHeight + CGFloat(max(0, tRows - 1)) * teacherRowSpacing

            let sCols = studentColumnCount
            let sRows = max(1, Int(ceil(Double(max(1, studentCount)) / Double(sCols))))
            let studentHeight = CGFloat(sRows) * cardHeight + CGFloat(max(0, sRows - 1)) * spacing

            let neededHeight = topPadding + teacherHeight + sectionGap + studentHeight + bottomPadding
            if neededHeight <= size.height {
                finalCardWidth = width
                finalCardHeight = cardHeight
                teacherColumns = tCols
                teacherRows = tRows
                studentColumns = sCols
                break
            }
        }

        let teacherBlockHeight = CGFloat(teacherRows) * finalCardHeight + CGFloat(max(0, teacherRows - 1)) * teacherRowSpacing
        let teacherTop = topPadding
        let titlePosition = CGPoint(x: size.width / 2, y: teacherTop + (teacherBlockHeight / 2))
        let titleFontSize: CGFloat = size.height < 760 ? 60 : 78
        let subtitleFontSize: CGFloat = max(22, titleFontSize * 0.44)
        let titleWidth: CGFloat = max(130, centerGap - (size.width < 980 ? 18 : 28))

        let studentColumnSpacing: CGFloat
        if studentColumns > 1 {
            let freeSpace = studentAreaWidth - (CGFloat(studentColumns) * finalCardWidth)
            studentColumnSpacing = max(0, freeSpace / CGFloat(studentColumns - 1))
        } else {
            studentColumnSpacing = 0
        }
        let studentColumnCenters = (0..<studentColumns).map { column in
            horizontalPadding + (finalCardWidth / 2) + CGFloat(column) * (finalCardWidth + studentColumnSpacing)
        }

        let leftAlignedCenters = studentColumnCenters.filter { $0 <= centerGapLeftEdge - (finalCardWidth / 2) }
        let rightAlignedCenters = studentColumnCenters.filter { $0 >= centerGapRightEdge + (finalCardWidth / 2) }
        let leftTeacherCenters = Array(leftAlignedCenters.prefix(teacherColumns))
        let rightTeacherCenters = Array(rightAlignedCenters.suffix(teacherColumns))

        func blockPositions(count: Int, xCenters: [CGFloat], topY: CGFloat, rowSpacing: CGFloat) -> [CGPoint] {
            guard count > 0 else { return [] }
            guard !xCenters.isEmpty else { return [] }
            let columns = xCenters.count
            return (0..<count).map { index in
                let row = index / columns
                let column = index % columns
                let x = xCenters[column]
                let y = topY + (finalCardHeight / 2) + CGFloat(row) * (finalCardHeight + rowSpacing)
                return CGPoint(x: x, y: y)
            }
        }

        let teacherPositions = blockPositions(
            count: leftCount,
            xCenters: leftTeacherCenters,
            topY: teacherTop,
            rowSpacing: teacherRowSpacing
        ) + blockPositions(
            count: rightCount,
            xCenters: rightTeacherCenters,
            topY: teacherTop,
            rowSpacing: teacherRowSpacing
        )

        // Students use the same horizontal bounds as the teacher section.
        let studentTop = teacherTop + teacherBlockHeight + sectionGap
        let studentStartX = horizontalPadding

        var studentPositions: [CGPoint] = []
        studentPositions.reserveCapacity(studentCount)
        for index in 0..<studentCount {
            let row = index / studentColumns
            let column = index % studentColumns
            let x = studentStartX + (finalCardWidth / 2) + CGFloat(column) * (finalCardWidth + studentColumnSpacing)
            let y = studentTop + (finalCardHeight / 2) + CGFloat(row) * (finalCardHeight + spacing)
            studentPositions.append(CGPoint(x: x, y: y))
        }

        return SeparatedLayout(
            titlePosition: titlePosition,
            titleFontSize: titleFontSize,
            subtitleFontSize: subtitleFontSize,
            titleWidth: titleWidth,
            cardWidth: finalCardWidth,
            cardHeight: finalCardHeight,
            imageHeight: max(36, finalCardHeight - 30),
            teacherPositions: teacherPositions,
            studentPositions: studentPositions
        )
    }

}

private struct MemberCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let member: ClassMember
    let imageHeight: CGFloat

    private var compact: Bool {
        imageHeight < 88
    }

    private var cardFillColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.06)
    }

    private var cardStrokeColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.16) : Color.black.opacity(0.16)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.70) : .secondary
    }

    private var placeholderGradientColors: [Color] {
        colorScheme == .dark
            ? [Color.white.opacity(0.10), Color.white.opacity(0.03)]
            : [Color.black.opacity(0.08), Color.black.opacity(0.02)]
    }

    private var placeholderIconColor: Color {
        colorScheme == .dark ? .white.opacity(0.78) : .black.opacity(0.56)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.48) : .black.opacity(0.12)
    }

    var body: some View {
        VStack(spacing: compact ? 3 : 5) {
            AsyncImage(url: member.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    LinearGradient(
                        colors: placeholderGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: member.role == .teacher ? "person.crop.square" : "person.fill")
                            .font(.system(size: compact ? 18 : 24, weight: .medium))
                            .foregroundStyle(placeholderIconColor)
                    )
                }
            }
            .frame(height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 1) {
                Text(member.name)
                    .font(.system(size: compact ? 9 : 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                if member.role == .teacher {
                    Text(member.subtitle)
                        .font(.system(size: compact ? 8 : 10, weight: .medium, design: .rounded))
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
            }
        }
        .padding(compact ? 6 : 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardFillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(cardStrokeColor, lineWidth: 1)
                )
        )
        .shadow(color: shadowColor, radius: 8, x: 0, y: 5)
    }
}

private struct SeparatedLayout {
    let titlePosition: CGPoint
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let titleWidth: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let imageHeight: CGFloat
    let teacherPositions: [CGPoint]
    let studentPositions: [CGPoint]
}

private struct PlaceholderDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String

    private var placeholderBackgroundColor: Color {
        colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : Color(nsColor: .underPageBackgroundColor)
    }

    var body: some View {
        ZStack {
            placeholderBackgroundColor.ignoresSafeArea()

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)

                Text(subtitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.72) : Color.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(24)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
