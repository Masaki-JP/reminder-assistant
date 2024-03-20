import Foundation
import EventKit

class ReminderCreateManager {
    private let eventStore = EKEventStore()

    func requestFullAccessToReminders() async throws {
        do {
            try await eventStore.requestFullAccessToReminders()
        } catch {
            throw ReminderCreateManagerError.requestFullAccessFailed
        }
    }

    func create(
        title: String,
        deadline: Date,
        notes: String? = nil,
        calendarIdentifier: String? = nil
    ) throws {
        guard canAccessReminderApp()
        else { throw ReminderCreateManagerError.authorizationStatusIsNotFullAccess }
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .init(identifier: "Asia/Tokyo")!, from: deadline)
        reminder.addAlarm(EKAlarm(absoluteDate: deadline))
        if let calendarIdentifier {
            guard isExistingList(calendarIdentifier)
            else { throw ReminderCreateManagerError.specifiedListIsNotFound }
        } else {
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
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
        guard let defaultList = eventStore.defaultCalendarForNewReminders()
        else { throw ReminderCreateManagerError.getDefaultListFailed }
        return defaultList
    }

    private func canAccessReminderApp() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        return status == .fullAccess ? true : false
    }

    private func isExistingList(_ calendarIdentifier: String) -> Bool {
        eventStore.calendars(for: .reminder).contains { $0.calendarIdentifier == calendarIdentifier }
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
    }
}
