import SwiftUI

struct PlayerProfileView: View {
    let player: Player?

    // 临时数据，后续会从 Player 模型中获取
    private let playTime = "128小时"
    private let favoriteVersion = "1.20.1"
    private let uuid = "550e8400-e29b-41d4-a716-446655440000"

    var body: some View {
        if let player = player {
            VStack(spacing: 20) {
                // 头像和名称部分
                VStack(spacing: 12) {
                    AsyncImage(
                        url: URLConfig.Resources.Minecraft.playerAvatar(
                            name: player.name
                        )
                    ) { image in
                        image
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    }

                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.medium)
                }

                // 玩家信息部分
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(title: "UUID", value: uuid)
                    InfoRow(title: "游戏时长", value: playTime)
                    InfoRow(title: "常用版本", value: favoriteVersion)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 皮肤预览部分
                VStack(alignment: .leading, spacing: 8) {
                    Text("皮肤预览")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    AsyncImage(
                        url: URLConfig.Resources.Minecraft.playerSkin(
                            name: player.name
                        )
                    ) { image in
                        image
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(height: 200)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 200)
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .frame(minWidth: 400, minHeight: 600)
        } else {
            ContentUnavailableView {
                Label(
                    "未选择玩家",
                    systemImage: "person.crop.circle.badge.questionmark"
                )
            } description: {
                Text("请从侧边栏选择一个玩家")
            }
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
//
//#Preview {
//    PlayerProfileView(player: Player(id: UUID(), name: "Steve"))
//}
