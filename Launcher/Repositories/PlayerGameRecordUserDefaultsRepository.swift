import Foundation

// 引入全局 JSONCodableHelper 工具类

class PlayerGameRecordUserDefaultsRepository {
    private let recordsKey = "playerGameRecords"

    func fetchAll() -> [PlayerGameRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
            let records = JSONCodableHelper.decode(
                [PlayerGameRecord].self,
                from: data
            )
        else {
            return []
        }
        return records
    }

    func fetchAll(for playerId: UUID) -> [PlayerGameRecord] {
        fetchAll().filter { $0.playerId == playerId }
    }

    func saveAll(_ records: [PlayerGameRecord]) {
        if let data = JSONCodableHelper.encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    func add(_ record: PlayerGameRecord) {
        var records = fetchAll()
        records.append(record)
        saveAll(records)
    }

    func update(_ record: PlayerGameRecord) {
        var records = fetchAll()
        if let idx = records.firstIndex(where: { $0.id == record.id }) {
            records[idx] = record
            saveAll(records)
        }
    }

    func delete(recordId: UUID) {
        var records = fetchAll()
        records.removeAll { $0.id == recordId }
        saveAll(records)
    }
}
