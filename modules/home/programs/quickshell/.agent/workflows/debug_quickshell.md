# Debugging Quickshell

If Quickshell widgets or services are behaving unexpectedly, you can check the systemd user journal for logs.

## Check Logs

Run the following command to see the latest 50 lines of logs:

```bash
journalctl --user -u quickshell -n 50 --no-pager
```

To follow the logs in real-time:

```bash
journalctl --user -u quickshell -f
```

## Common Issues

### TypeErrors in QML
If you see errors like `TypeError: Cannot read property 'layout' of undefined`, it usually means a variable (like `focusedWindow`) is null/undefined when accessed.
- **Fix**: Add checks like `if (variable && variable.property) { ... }`.

### Configuration Load Failures
If you see `Failed to load configuration`, look at the `caused by ...` lines immediately following it.
- **Fix**: Open the file mentioned (e.g., `Battery.qml`) at the specified line number and check for syntax errors or duplicate property assignments.
