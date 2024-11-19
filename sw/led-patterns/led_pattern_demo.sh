#!/bin/bash
HPS_LED_CONTROL="/sys/devices/platform/ff200000.led_patterns/hps_led_control"
BASE_PERIOD="/sys/devices/platform/ff200000.led_patterns/base_period"
LED_REG="/sys/devices/platform/ff200000.led_patterns/led_reg"

OG_SPEED=$(cat $BASE_PERIOD)

echo "software control pattern for 2.56 seconds!"
echo 1 > $HPS_LED_CONTROL

for i in {0..255}; do
    echo $i > $LED_REG
    sleep 0.001
done

echo "hardware control with pattern speed slowly changing..."
echo 1 > $BASE_PERIOD
echo 0 > $HPS_LED_CONTROL

for i in {1..10..2}; do 
    echo $i > $BASE_PERIOD
    sleep 1
done

echo $OG_SPEED > $BASE_PERIOD