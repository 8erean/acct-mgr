#!/bin/bash

# Add/Remove Users and/or Groups
add_rem() {
clear
echo "Comments: >" $alert
echo "
Add/Remove User
***************

1) Add User
2) Remove User
3) List Users

M) Main Menu
X) Exit Program

"
read -p "Please choose option...>" addrm_opt

      if [ $addrm_opt = "1" ]; then
        read -p "Enter first name...> " addrm_first
        read -p "Enter last name...> " addrm_last
        addrm_name="$addrm_first $addrm_last"
        addrm_chk=$(grep "$addrm_name" /etc/passwd | awk -F: '{print $5}' | cut -d "," -f1)
        if [ "$addrm_name" != "$addrm_chk" ]; then
          echo "User $addrm_name is good to use"
          read -p "Enter username for $addrm_name...> " addrm_username
          /usr/sbin/useradd -c "$addrm_name" -m -s /bin/bash -d /home/$addrm_username -U $addrm_username
          alert="User $addrm_username successfully added"
          sleep 3
          add_rem
        elif [ "$addrm_name" = "$addrm_chk" ]; then
          echo "User $addrm_name is already in use"
          alert="User $addrm_name is already in use"
          sleep 2
          add_rem
        else
          echo "Bad Check: Something went wrong!"
        fi
      elif [ $addrm_opt = "2" ]; then
        read -p "Enter the username to remove...>" addrm_username
        read -p "Confirm to remove user $addrm_username? [y/n]" rem_conf
        case $rem_conf in
          y|Y) userdel -r $addrm_username
               alert="$addrm_username successfully removed."
               sleep 2
               add_rem
               ;;
          n|N) add_rem ;;
          *) alert="Invalid Option: $rem_conf"
             sleep 2
             add_rem
             ;;
        esac
      elif [[ "$addrm_opt" = "3" ]]; then
        var1=$(cat /etc/passwd | awk -F: '{print $1}')
        echo $var1
        read -p "Enter any key to continue "
        add_rem
      elif [[ "$addrm_opt" = [mM] ]]; then
        main
      elif [[ "$addrm_opt" = [xX] ]]; then
        exit
      else
        alert="Invalid Option: $addrm_opt"
        read -p "Press enter to continue"
        add_rem
      fi
}

###################################################################
# Change Default Shell function
###################################################################
def_shell() {

clear
echo "Comments: >" $alert

echo "
Default Shell Change
********************

Available Shells:
-----------------------
| bash    zsh    tcsh |
| xiki    csh    ksh  |
-----------------------

C) Change Default Shell
M) Main Menu
X) Exit Program

"
read -p "Please choose option...>" def_shell_opt

if [[ "$def_shell_opt" = [cC] ]]; then
  read -p "Enter the username or ...>" def_shell_user
  read -p "Enter the desired default shell...>" shell
  current_shell=$(cat /etc/passwd | grep ^$def_shell_user | awk -F: '{print $7}')
  echo "Current shell is $current_shell"

# Shell variables had to be single and double quoted for shell expansion
# Had to use commas as sed separators because of the backslashes in my vars
  sed -i '/'"$def_shell_user"'/s,'"$current_shell"',\/bin/'"$shell"',g' /etc/passwd
  echo "Default shell changed from $current_shell to /bin/$shell"
  new_shell=$(cat /etc/passwd | grep ^$def_shell_user | awk -F: '{print $1,$7}')
  alert=$new_shell
  read -p "Press enter to continue"
  def_shell
elif [[ "$def_shell_opt" = [mM] ]]; then
  main
elif [[ "$def_shell_opt" = [xX] ]]; then
  exit
else
  alert="Invalid Option: $def_shell_opt"
  sleep 2
  def_shell
fi
}

##########################################################################
# Password Reset Tool
##########################################################################
reset_pass() {

clear
echo "Comments: >" $alert

echo "
Password Reset Tool
*******************

1) Check User Password Status
2) Change Password
3) Remove Password

M) Main Menu
X) Exit Program

"
read -p "Please choose option...>" reset_pass_opt

case $reset_pass_opt in
  1)    echo
        read -p "Enter username...>" uzr
        passwd -S $uzr
        read -p "Press enter to continue"
        reset_pass
        ;;
  2)    echo
        read -p "Enter username...>" uzr
        passwd $uzr
        read -p "Press enter to continue"
        reset_pass
        ;;
  3)    echo
        read -p "Enter username...>" uzr
        passwd -d $uzr
        read -p "Press enter to continue"
        reset_pass
        ;;
  m|M)  main ;;
  x|X)  clear
        exit ;;
  *)    echo
        alert="Invalid Option: $reset_pass_opt"
        reset_pass
        ;;
esac
}

##########################################################################
# Lock or Unlock User Accounts
##########################################################################
acct_lock() {

  clear
  echo "Comments: >" $alert

  echo "
  User Account Lock Tool
  **********************

  1) Lock User Account
  2) Unlock User Account

  M) Main Menu
  X) Exit Program

  "
  read -p "Please choose option...>" acct_lock_opt

  case $acct_lock_opt in
    1)    echo
          read -p "Enter username...>" uzr
          chage -E 0 $uzr
          read -p "Press enter to continue"
          acct_lock
          ;;
    2)    echo
          read -p "Enter username...>" uzr
          chage -E -1 $uzr
          read -p "Press enter to continue"
          acct_lock
          ;;
    m|M)  main ;;
    x|X)  clear
          exit ;;
    *)    echo
          alert="Invalid Option: $acct_lock_opt"
          acct_lock
          ;;
  esac

}

##########################################################################
# Change Username
##########################################################################
ch_name() {

    clear
    echo "Comments: >" $alert

    echo "
    Change Username Tool
    ********************

    1) Change Username
    2) Change Full Name

    M) Main Menu
    X) Exit Program

    "
    read -p "Please choose option...>" ch_name_opt

    case $ch_name_opt in
      1)    echo
            read -p "Enter current username...>" uzr
            read -p "Enter desired username...>" uzr_new
            usermod -l $uzr_new $uzr
            read -p "Press enter to continue"
            ch_name
            ;;
      2)    echo
            read -p "Enter current username...>" uzr
            echo $uzr
            full_name=$(grep "$uzr" /etc/passwd | awk -F: '{print $5}' | cut -d "," -f1)
            echo "The current Full Name associated is $full_name"
            #break $full_name into $first_name and $last_name
            first_name=$(echo $full_name | gawk '{print $1}')
            last_name=$(echo $full_name | gawk '{print $2}')
            echo $first_name
            echo $last_name
            read -p "Change 1)First 2)Last 3)None?...>" fname_opt
              case $fname_opt in
                1) read -p "Enter new First Name...>" new_first_name
                   sed -i '/'"$uzr"'/s,'"$first_name"','"$new_first_name"',g' /etc/passwd
                   vrfy_name=$(grep "$uzr" /etc/passwd) # | awk -F: '{print $5}' | cut -d "," -f1)
                   echo "First Name successfully updated."
                   echo $vrfy_name
                   read -p "Press enter to continue"
                   ch_name
                   ;;
                2) read -p "Enter new Last Name...>" new_last_name
                   sed -i '/'"$uzr"'/s,'"$last_name"','"$new_last_name"',g' /etc/passwd
                   vrfy_name=$(grep "$uzr" /etc/passwd) # | awk -F: '{print $5}' | cut -d "," -f1)
                   echo "Last Name successfully updated."
                   echo $vrfy_name
                   read -p "Press enter to continue"
                   ch_name
                   ;;
                3) ch_name ;;
                *) echo
                   alert="Invalid Option: $fname_opt"
                   ch_name
                   ;;
              esac
            read -p "Enter desired username...>" uzr_new
            usermod -l $uzr_new $uzr
            read -p "Press enter to continue"
            ch_name
            ;;
      m|M)  main ;;
      x|X)  clear
            exit ;;
      *)    echo
            alert="Invalid Option: $ch_name_opt"
            ch_name
            ;;
    esac

}


##########################################################################
# This is the main options menu
##########################################################################
main() {

clear
alert=" "

echo "
Welcome to the Linux User Account Manager system.
*************************************************

1) Add/Remove User to System
2) Change User Default Shell
3) Reset Password
4) Lock/Unlock User Account
5) Change Username

X) Exit Program

"
read -p "Please choose option...>" main_opt

# Comments abound
	case $main_opt in
		1) add_rem ;;
		2) def_shell ;;
		3) reset_pass ;;
		4) acct_lock ;;
		5) ch_name ;;
		x|X) read -p "Really exit? [y/n] " wish
			case $wish in
				y|Y) clear
					exit ;;
				n|N) main ;;
				*) echo "Invalid Option"
					main ;;
			esac
			;;
		*) echo "Invalid Option"
		   main ;;
	esac
}

#####################################################
# Start of program
#####################################################
# Checking for root status
#####################################################
rooted=$(whoami)
if [[ "$rooted" != "root" ]]; then
  echo "You are not running as root."
  echo "Try: 'sudo acct-mgr'"
else
  main
fi
