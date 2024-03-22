import Foundation
import EventKit

struct ReminderCreateManager {
    private let eventStore = EKEventStore()

    func requestFullAccessToReminders() async throws {
        do {
            try await eventStore.requestFullAccessToReminders()
        } catch {
            throw ReminderCreateManagerError.requestFullAccessFailed
        }
    }

    func create(title: String, deadline: Date, notes: String, destinationListID: String) throws {
        guard canAccessReminderApp()
        else { throw ReminderCreateManagerError.authorizationStatusIsNotFullAccess }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .init(identifier: "Asia/Tokyo")!, from: deadline)
        reminder.addAlarm(EKAlarm(absoluteDate: deadline))

        if destinationListID.isEmpty {
            guard let defaultList = eventStore.defaultCalendarForNewReminders()
            else { throw ReminderCreateManagerError.getDefaultListFailed }
            reminder.calendar = defaultList
        } else {
            let destinationList = try find(id: destinationListID)
            reminder.calendar = destinationList
        }

        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw ReminderCreateManagerError.createFailed
        }
    }

    func getExistingLists() throws -> [EKCalendar] {
        guard canAccessReminderApp()
        else { throw ReminderCreateManagerError.authorizationStatusIsNotFullAccess }
        return eventStore.calendars(for: .reminder)
    }

    func getDefaultList() throws -> EKCalendar {
        guard canAccessReminderApp(),
              let defaultList = eventStore.defaultCalendarForNewReminders()
        else { throw ReminderCreateManagerError.getDefaultListFailed }
        return defaultList
    }

    private func canAccessReminderApp() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        return status == .fullAccess ? true : false
    }

    private func find(id: String) throws -> EKCalendar {
        let lists = eventStore.calendars(for: .reminder)
        if lists.filter({ $0.calendarIdentifier == id }).count == 0 {
            throw ReminderCreateManagerError.specifiedListIsNotFound
        } else if lists.filter({ $0.calendarIdentifier == id }).count == 1 {
            return lists.first!
        } else {
            throw ReminderCreateManagerError.multipleListsWithSameIDFound
        }
    }
}

typealias ReminderCreateManagerError = ReminderCreateManager.ReminderCreateManagerError

extension ReminderCreateManager {
    enum ReminderCreateManagerError: Error {
        case requestFullAccessFailed
        case authorizationStatusIsNotFullAccess
        case createFailed
        case specifiedListIsNotFound
        case getDefaultListFailed
        case multipleListsWithSameIDFound
    }
}
