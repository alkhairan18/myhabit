# Notification Manual Testing Checklist (PRD §14)

- [ ] Android 8–12: schedule reminder 2 minutes ahead ? notification fires on time.
- [ ] Android 13+: context sheet shown before `POST_NOTIFICATIONS` system dialog; if denied, app stays functional without crash.
- [ ] `specificDays` habit: notification only fires on selected weekdays.
- [ ] Reboot device (`adb reboot`) ? `ScheduledNotificationBootReceiver` keeps reminders scheduled.
- [ ] Battery saver / OEM background restriction active ? verify fallback to `inexactAllowWhileIdle` when exact alarm permission is off.

