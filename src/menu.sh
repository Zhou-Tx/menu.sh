#!/bin/bash
set -e

file="$1"
set -- ${@:2}
options=($(cat $file))

init_position() {
  for index in "${!options[@]}"; do
    echo;
  done
  echo -ne "\033[6n"
  read -s -d\[ _
  read -s -d R pos
  option_cnt=${#options[@]}
  tput cup $((${pos%;*} - $option_cnt - 1)) 0
  tput sc
}

select_option() {
  selected=0

  while true; do
    tput rc
    for index in "${!options[@]}"; do
      if [ $index -eq $selected ]; then
        printf "\033[31m> ${options[$index]}\033[0m\n"
      else
        echo "  ${options[$index]}"
      fi
    done

    read -sn1 key
    if [ "$key" == "" ]; then
      break
    fi
    if [ `printf "%d" "'$key"` != 27 ]; then
      continue
    fi

    read -sn1 key
    if [ `printf "%d" "'$key"` != 91 ]; then
      continue
    fi

    read -sn1 key
    case "$key" in
      A)  # 上箭头
        if [ $selected -gt 0 ]; then
          selected=$((selected - 1))
        fi
        ;;
      B)  # 下箭头
        if [ $selected -lt $(( ${#options[@]} - 1 )) ]; then
          selected=$((selected + 1))
        fi
        ;;
    esac
  done
}

init_position && select_option
exec $@ "${options[$selected]}"
