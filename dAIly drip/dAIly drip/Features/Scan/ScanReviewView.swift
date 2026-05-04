import PhotosUI
import SwiftUI

struct ScanReviewView: View {
    @State private var viewModel = ScanReviewViewModel()
    @EnvironmentObject private var closetRepository: ClosetRepository
    private let suggestions = ["White Turtleneck", "Dark Wash Denim"]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                DAIlyDripTopBar(leading: .close)
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.stackLg) {
                        canvas
                        results
                    }
                    .padding(.horizontal, Spacing.containerMargin)
                    .padding(.top, Spacing.stackMd)
                    .padding(.bottom, 160)
                }
            }

            saveBar
        }
        .background(AppColor.background)
        .confirmationDialog(
            "Add a photo",
            isPresented: $viewModel.isSourceDialogPresented,
            titleVisibility: .visible
        ) {
            Button("Take Photo") { viewModel.chooseCamera() }
            Button("Choose from Library") { viewModel.chooseLibrary() }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(
            isPresented: $viewModel.isLibraryPresented,
            selection: $viewModel.photoPickerItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraPicker { image in
                viewModel.setCapturedImage(image)
            }
            .ignoresSafeArea()
        }
        .onChange(of: viewModel.photoPickerItem) { _, newItem in
            viewModel.handlePickerSelection(newItem)
        }
        .sheet(item: $viewModel.editingField) { field in
            switch field {
            case .type:      TypeEditorView(viewModel: viewModel)
            case .seasons:   SeasonsEditorView(viewModel: viewModel)
            case .occasions: OccasionsEditorView(viewModel: viewModel)
            case .color:     ColorEditorView(viewModel: viewModel)
            }
        }
        .alert("Categorization Failed", isPresented: analyzeErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.analyzeError ?? "Try a different photo.")
        }
    }

    private var analyzeErrorBinding: Binding<Bool> {
        Binding {
            viewModel.analyzeError != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.analyzeError = nil
            }
        }
    }

    private var canvas: some View {
        Button {
            viewModel.presentSourceDialog()
        } label: {
            Color.clear
                .aspectRatio(3.0/4.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(AppColor.surfaceContainer)
                            VStack(spacing: Spacing.stackSm) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 56, weight: .ultraLight))
                                    .foregroundStyle(AppColor.outline)
                                Text("Tap to add a photo")
                                    .appFont(.labelMd)
                                    .foregroundStyle(AppColor.outline)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .ambientShadow(blur: 30, y: 10, opacity: 0.04)
                .overlay(alignment: .topTrailing) {
                    if viewModel.isAnalyzingImage {
                        AIPulseIndicator(label: "AI Analysis Active")
                            .padding(Spacing.stackMd)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a photo of your item")
        .accessibilityHint("Opens camera or photo library")
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: Spacing.stackMd) {
            HStack(alignment: .firstTextBaseline) {
                Text("AI Detected")
                    .appFont(.headlineMd)
                    .foregroundStyle(AppColor.onSurface)
                Spacer()
                Text("4 Attributes")
                    .appFont(.labelMd)
                    .foregroundStyle(AppColor.secondary)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.gutter),
                    GridItem(.flexible(), spacing: Spacing.gutter),
                ],
                spacing: Spacing.gutter
            ) {
                AttributeCard(
                    label: "Type",
                    values: [viewModel.draftType.displayName],
                    onEdit: { viewModel.beginEdit(.type) }
                )
                AttributeCard(
                    label: "Season",
                    values: viewModel.draftSeasons.map(\.displayName).sorted(),
                    onEdit: { viewModel.beginEdit(.seasons) }
                )
                AttributeCard(
                    label: "Occasion",
                    values: viewModel.draftOccasions.map(\.displayName).sorted(),
                    onEdit: { viewModel.beginEdit(.occasions) }
                )
                AttributeCard(
                    label: "Color",
                    values: [viewModel.draftColor.name],
                    swatch: Color(hex: hex(viewModel.draftColor.hex)),
                    onEdit: { viewModel.beginEdit(.color) }
                )
            }
            .opacity(viewModel.isAnalyzingImage ? 0.35 : 1)
            .allowsHitTesting(!viewModel.isAnalyzingImage)
            .overlay {
                if viewModel.isAnalyzingImage {
                    VStack(spacing: Spacing.stackSm) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppColor.primary)
                            .scaleEffect(1.2)
                        Text("Analyzing your item…")
                            .appFont(.labelMd)
                            .foregroundStyle(AppColor.secondary)
                    }
                    .padding(.horizontal, Spacing.stackLg)
                    .padding(.vertical, Spacing.stackMd)
                    .background(
                        AppColor.surfaceContainerLowest.opacity(0.92),
                        in: RoundedRectangle(cornerRadius: Radius.md)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(AppColor.outlineVariant, lineWidth: 1)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Analyzing your item")
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isAnalyzingImage)

            Divider()
                .background(AppColor.outlineVariant)
                .padding(.top, Spacing.stackMd)

            HStack(alignment: .top, spacing: Spacing.stackSm) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(AppColor.secondary)
                Text("Suggested matching items: \(suggestions.joined(separator: ", "))")
                    .appFont(.bodySm)
                    .italic()
                    .foregroundStyle(AppColor.secondary)
            }
        }
    }

    private var saveBar: some View {
        VStack {
            PrimaryButton(
                title: "Save to Closet",
                leadingSystemImage: "tray.and.arrow.down.fill"
            ) {
                let item = viewModel.makeClosetItem(ownerId: closetRepository.userProfile.id)
                closetRepository.addClosetItem(item)
            }
        }
        .padding(.horizontal, Spacing.containerMargin)
        .padding(.top, Spacing.stackLg)
        .padding(.bottom, Spacing.stackMd)
        .background(
            LinearGradient(
                colors: [AppColor.background.opacity(0), AppColor.background.opacity(0.95), AppColor.background],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func hex(_ string: String) -> UInt32 {
        var trimmed = string
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        return UInt32(trimmed, radix: 16) ?? 0xE3D5C1
    }
}

#Preview {
    ScanReviewView()
        .environmentObject(ClosetRepository())
}
