#!/bin/bash

LOG='/var/log/pascals_pc.log'
MAC_ADDRESS="4c:cc:6a:4a:4d:63"
IP_ADDRESS="192.168.178.100"
SHELLY_SCREENS="192.168.178.90"
USERNAME='pascal'

date >> $LOG
echo "$*" >> $LOG
whoami >> $LOG
case "${1}" in
        on|ON)
                echo "PC on" >> $LOG
                sudo etherwake $MAC_ADDRESS &>> $LOG

                while ! timeout 1 ping -c 1 -n $IP_ADDRESS &> /dev/null ; do :; done

                echo "" >> $LOG
                exit 0
                ;;

        off|OFF)
                echo "PC off" >> $LOG

                echo "timeout 3 ssh $USERNAME@$IP_ADDRESS cmd.exe /C shutdown /h " >> $LOG
                timeout 3 ssh $USERNAME@$IP_ADDRESS cmd.exe /C shutdown /h >> $LOG 2>&1

                echo "" >> $LOG
                ;;

        reboot|REBOOT)
                echo "PC reboot" >> $LOG

                echo "timeout 3 ssh $USERNAME@$IP_ADDRESS cmd.exe /C shutdown /r " >> $LOG
                timeout 3 ssh $USERNAME@$IP_ADDRESS cmd.exe /C shutdown /r >> $LOG 2>&1
                echo "" >> $LOG
                ;;

        status|STATUS)
                if timeout 1 ping -c 1 -n $IP_ADDRESS &>/dev/null ; then
                        echo "ON"
                        echo $'ON\n' >> $LOG
                        exit 0
                else
                        echo "OFF"
                        echo $'OFF\n' >> $LOG
                        exit 1
                fi
                ;;

        screens|SCREENS)
                TURN="on"
                case "${3}" in
                        "")
                                ;&
                        on|ON)
                                TURN="on"
                                ;;
                        off|OFF)
                                TURN="off"
                                ;;
                        *)
                                echo "Unrecognized options $*"
                                echo "Use pascals_pc screens <0|1|all> [<on|off>]"
                               ;;
                esac


                case "${2}" in
                        0|1)
                                curl "http://$SHELLY_SCREENS/relay/${2}/?turn=$TURN" >> $LOG 2>&1
                                echo "" >> $LOG
                                ;;
                        "")
                                ;&
                        all|ALL)
                                curl "http://$SHELLY_SCREENS/relay/0/?turn=$TURN" >> $LOG 2>&1
                                echo "" >> $LOG
                                curl "http://$SHELLY_SCREENS/relay/1/?turn=$TURN" >> $LOG 2>&1
                                echo "" >> $LOG
                                ;;
                        *)
                                echo "Unrecognized options $*"
                                echo "Use pascals_pc screens <0|1|all> [<on|off>]"
                                ;;
                esac
                ;;

        *)
                echo
                echo "Usage: pascals_pc <on|off|reboot|status|screens>"
                echo
                exit 1
                ;;
esac

exit 0
