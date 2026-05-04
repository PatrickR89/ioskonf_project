import SwiftUI

/// A simple horizontal flow layout: children take their intrinsic width and
/// wrap to the next row when the proposed width is exhausted.
struct FlowLayout: Layout {
    var spacing: CGFloat = Spacing.stackSm
    var lineSpacing: CGFloat = Spacing.stackSm

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let totalHeight = rows.reduce(0) { $0 + $1.height }
            + CGFloat(max(0, rows.count - 1)) * lineSpacing
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for offset in row.indices.indices {
                let subviewIndex = row.indices[offset]
                let size = row.sizes[offset]
                subviews[subviewIndex].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var sizes: [CGSize] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            var current = rows[rows.count - 1]
            let needsNewRow = !current.indices.isEmpty
                && current.width + spacing + size.width > maxWidth
            if needsNewRow {
                rows.append(Row())
                current = rows[rows.count - 1]
            }
            if !current.indices.isEmpty { current.width += spacing }
            current.indices.append(index)
            current.sizes.append(size)
            current.width += size.width
            current.height = max(current.height, size.height)
            rows[rows.count - 1] = current
        }
        return rows
    }
}
