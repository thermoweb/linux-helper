#!/bin/bash

BLUETOOTH_DEVICE="HyperX Cloud MIX"
PROFILE_A2DP="a2dp_sink"
PROFILE_HEADSET_UNIT="headset_head_unit"

if [ "${1}" == "reset" ] ; then
    sudo rfkill block bluetooth && sleep 0.1 && sudo rfkill unblock bluetooth;
    exit;
fi

sink_name() {
    pacmd list-sinks | grep '\(name:\|alias\)' | grep -B1 "${1}" | head -1 | sed -rn 's/\s*name: <(.*?)>/\1/p'
}

card_name() {
    pacmd list-cards | grep 'name:' | grep "bluez" | sed -rn 's/\s*name: <(.*?)>/\1/p'
}

if [ "${1}" == "" -o "${1}" == "toogle" ] ; then
    SINK_NAME=$(sink_name "$BLUETOOTH_DEVICE")

    if [ "${SINK_NAME}" == "" ] ; then echo "${BLUETOOTH_DEVICE} headset not found."; ${0} reset; sleep 2; exit; fi

    if $(echo "${SINK_NAME}" | grep "${PROFILE_A2DP}" &> /dev/null) ; then
        echo "Detected quality sound output, thats means we can't speak; switch that."
        ${0} speak;
    else
        echo "Quality sound not found, switch to the good sound.";
        ${0} listen;
    fi
fi

if [ "${1}" == "listen" ] ; then
    SINK_NAME=$(sink_name "${BLUETOOTH_DEVICE}")
    if [ "${SINK_NAME}" == "" ] ; then echo "${BLUETOOTH_DEVICE} headset not found."; ${0} reset; sleep 2; exit; fi

    echo "Switching the output to ${SINK_NAME}";
    pacmd set-default-sink "${SINK_NAME}"

    CARD=$(card_name)
    echo "Switching audio profile to ${PROFILE_A2DP}";
    pacmd set-card-profile "${CARD}" "${PROFILE_A2DP}"
    exit;
fi;

if [ "${1}" == "speak" ] ; then
    CARD=$(card_name)
    pacmd set-card-profile "${CARD}" "${PROFILE_HEADSET_UNIT}"

    SOURCE_NAME=$(sink_name "${BLUETOOTH_DEIVCE}")
    if [ "${SOURCE_NAME}" == "" ] ; then echo "${BLUETOOTH_DEVICE} mic not found."; ${0} reset; sleep 2; fi
    echo "Switching audio input to ${SOURCE_NAME}";
    pacmd set-default-source "${SOURCE_NAME}.monitor" || echo 'Try `pacmd list-sources`.';
fi;

####  Resources:
# origin idea here : https://gist.github.com/OndraZizka/2724d353f695dacd73a50883dfdf0fc6


##  Why this is needed
# https://jimshaver.net/2015/03/31/going-a2dp-only-on-linux/

##  My original question
# https://askubuntu.com/questions/1004712/audio-profile-changes-automatically-to-hsp-bad-quality-when-i-change-input-to/1009156#1009156

##  Script to monitor plugged earphones and switch when unplugged (Ubuntu does that, but nice script):
# https://github.com/freundTech/linux-helper-scripts/blob/master/padevswitch/padevswitch
