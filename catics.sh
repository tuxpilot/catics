#!/bin/bash

# Made by Tuxpilot
# Creation date : 23/03/2020

## This Script is to be used on a bare new Debian Server installed from a template  in order to customize it


# We let the user enter the new hostname for that debian
echo -e "Hello, welcome to the after template installation customization script."

echo -e "\n\n Please enter a new Hostname for that Debian:"

read new_hostname
# We search for every file in /etc/ that contains the actual name of the Debian, and we change the content of every file, specifically the part where the old name is and replace it with the new name
  # the search is made through a grep that returns only the name of the file containing the actual hostname of the template, and for everyone of these file  we use SED to change the content we want inside the file

  # we present the user the list of all the modifications that are about to happen if "y" or "Y" is entered.  Any other choice result in an exit code
  echo -e "\n\n You are about to change the name of that server from ${HOSTNAME} to ${new_hostname}"
  echo -e "Do you wish to continue? [Y/n]"

  read continue_choice

  # if the user entered the choice "y" or "Y"  corresponding to YEs, then we continue to the modifications inside the /etc/network/interfaces
  if [[ "${continue_choice}" == *"y"* || "${continue_choice}" == *"Y"* ]]
    then  grep -i -l $HOSTNAME /etc/* -R | while IFS= read -r file_content_to_change; do sed -i "s/${HOSTNAME}/${new_hostname}/g" "${file_content_to_change}"; done
    # If the user entered any other choice than "y" or "Y" standing for YES   then  it means the user doesn't want to continue   so we end the script without making any modifications.
    else  echo -e "We cannot continue if you refuse. Come back when ready. Bye."
          exit 1
  fi


#We prepare the variables and go to the chapter where we customize
inside_selected_interface=0
interfaces='/etc/network/interfaces'
echo -e "\n\n Now We will customize the IP Adress, and the Hostname of that server"


# we retrieve the list of all the available IPV4 network interfaces
available_network_interfaces=$(ip -o -4 a | tr -s ' ' | awk -F ' ' '{ print $2 }')

# we let the user choose what interface he want to change by entering the name of the interface
echo -e "Please select the interface you wish to modify by entering its name completely\n For example: eth0 or ens8   etc."
echo -e "${available_network_interfaces} \n\n"

read selected_interface

# we let the user enter manually the new IP and CIDR for the interface once the server will reboot
echo -e "Please Enter the IP/CIDR you want for that Server once it'll reboot"
echo -e "For example : 192.168.1.1/24"

read new_ip_cidr


# we let the user enter manually the new Gateway for this interface
echo -e "Please select the Gateway for that interface"

read new_gateway


# we let the user enter manually the DNS server for that interface
echo -e "Please select the DNS server for that interface"
echo -e "Reminder : you can use public DNS like  1.1.1.1 or 1.0.0.1 or 8.8.8.8 or 8.8.4.4"

read dns_server


# we present the user the list of all the modifications that are about to happen if "y" or "Y" is entered.  Any other choice result in an exit code
echo -e "\n\n For the interface ${selected_interface}  \n You will give the IPV4 : ${new_ip_cidr} \n With the gateway ${new_gateway}  \n And the DNS server ${dns_server}"
echo -e "Do you wish to continue? [Y/n]"

read continue_choice

# if the user entered the choice "y" or "Y"  corresponding to YEs, then we continue to the modifications inside the /etc/network/interfaces
if [[ "${continue_choice}" == *"y"* || "${continue_choice}" == *"Y"* ]]
# For every line inside the /etc/network/interfaces  file   we read it line by line, and then
  then  while IFS= read -r iface_file_line
  # if the current read line is containing the syntaxe   'iface //name of the interface we selected//' then we know we are in the current block concerning the interface we are looking to customize and we pass the variable inside_selected_interface to 1 for further double checking before modification
          do  if [[ "${iface_file_line}" == *"iface ${selected_interface}"* ]]
                then  inside_selected_interface=1
                      echo "OK"
              fi

              # if the current read line is inside the block of the current interface we want to customize, and the line contains 'address',   then we are modifying the whole line with the new data
              if [[ "${iface_file_line}" == *"address "* && "${inside_selected_interface}" == "1" ]]
                then  sed -i "s|${iface_file_line}|address ${new_ip_cidr}|g" "${interfaces}"
              fi

              # if the current read line is inside the block of the current interface we want to customize, and the line contains 'gateway',   then we are modifying the whole line with the new data
              if [[ "${iface_file_line}" == *"gateway "* && "${inside_selected_interface}" == "1" ]]
              then  sed -i "s|${iface_file_line}|gateway ${new_gateway}|g" "${interfaces}"
              fi

              # if the current read line is inside the block of the current interface we want to customize, and the line contains 'dns-nameservers',   then we are modifying the whole line with the new data
                # Also we get the variable "inside_selected_interface"  because in a default /etc/network/interfaces file,  the last line of the block concerning each interface is ending with the field  "dns-nameservers"
                # So we pass the variable "inside_selected_interface" to 0 to make sure the script doesn't modify any other line concerning any other interface
              if [[ "${iface_file_line}" == *"dns-nameservers "* && "${inside_selected_interface}" == "1" ]]
                then  sed -i "s|${iface_file_line}|dns-nameservers ${dns_server}|g" "${interfaces}"
                      inside_selected_interface=0
              fi
        # we end the while read loop and precise the name of the file we want to modify
      done < "${interfaces}"

  # If the user entered any other choice than "y" or "Y" standing for YES   then  it means the user doesn't want to continue   so we end the script without making any modifications.
  else  echo -e "We cannot continue if you refuse. Come back when ready. Bye."
        exit 1
fi
