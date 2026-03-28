#!/bin/bash

# This ID lets you replace or close the same notification window instead of stacking new ones
NOTIFY_ID=1002

# Percentage at which we start warning. 80% is a good balance. High enough to not be annoying
THRESHOLD=80

# Tracks whether the user has chosen to ignore alerts for this session
IGNORE_ALERTS=false

while true; do
  # If the user hit Ignore, stop bothering them until next login
  if [ "$IGNORE_ALERTS" = true ]; then
    break
  fi

  # Grab total and available RAM in MB. "Available" is more accurate than "free" for real usage
  MEM_INFO=$(free -m | awk '/^Mem:/{print $2, $7}')
  TOTAL=$(echo $MEM_INFO | cut -d' ' -f1)
  AVAIL=$(echo $MEM_INFO | cut -d' ' -f2)

  # Calculate how much is actually in use as a percentage
  USED_PERCENT=$(( 100 * (TOTAL - AVAIL) / TOTAL ))

  if [ "$USED_PERCENT" -ge "$THRESHOLD" ]; then
    # Fire a critical notification with an Ignore action
    # -r makes it replace the previous one so they don't pile up
    ACTION=$(notify-send -r $NOTIFY_ID -u critical \
      --action="ignore=Ignore" \
      "⚠️ Memory Alert" \
      "Physical RAM usage is at $USED_PERCENT%. Close apps/tabs now to prevent system instability.")
    
    if [ "$ACTION" = "ignore" ]; then
      # User clicked Ignore. Set the flag and close the notification cleanly
      IGNORE_ALERTS=true
      gdbus call --session --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.CloseNotification $NOTIFY_ID > /dev/null 2>&1
    fi
  
  else
    # RAM is back under the threshold. Close the warning if it's still open
    gdbus call --session --dest org.freedesktop.Notifications \
      --object-path /org/freedesktop/Notifications \
      --method org.freedesktop.Notifications.CloseNotification $NOTIFY_ID > /dev/null 2>&1
  fi

  sleep 3 # Check every 3 seconds. Frequent enough to catch spikes without wasting cycles
done
