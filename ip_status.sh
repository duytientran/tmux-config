#!/bin/bash

wan_tmp="/tmp/wan_ip"
update_time=900 # Time in seconds to cache the wan ip for
tick_file="/tmp/tmux_ip_tick"

function lan_ip {
  echo "$(/sbin/ifconfig 2>/dev/null | grep 'inet '|grep -v '127.0.0.1'| awk '{print $2}'|cut -d':' -f2)"
}

function grab_wan_ip {
  ip="$(curl ifconfig.me 2>/dev/null)"
  echo "$ip" > $wan_tmp
}

function wan_ip {
  if [[ -f $wan_tmp ]]; then 
    wan_file_written=$(date +%s -r $wan_tmp)
    now=$(date +%s)
    wan_file_age=$((now-wan_file_written))
    if [[ $wan_file_age -gt $update_time ]]; then
      grab_wan_ip
    fi
  else
    grab_wan_ip
  fi
  cat $wan_tmp
}

if [[ -f "$tick_file" ]]; then
  rm "$tick_file"
  echo "ⓦ $(wan_ip)"
else
  touch $tick_file
	echo "ⓛ $(lan_ip)"
fi

