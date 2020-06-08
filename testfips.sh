#!/usr/bin/env bash

set -e

get_nist_ciphers() {
  mapfile -t CIPHERS_FIPS < ./data/fips_approved.txt
}

get_nist_deprecated_ciphers() {
  mapfile -t CIPHERS_FIPS_DEPRECATED < ./data/fips_deprecated.txt
}

get_server_ciphers() {
  ./testssl.sh/testssl.sh -E -q $ENDPOINT | grep -o 'TLS_\w*' | tr -d '\t' | sort -u
}

is_fips_cipher() {
  for fips_cipher in ${CIPHERS_FIPS[@]}; do
    if [ "$1" = "$fips_cipher" ]; then
      return 0
    fi
  done

  return 1
}

is_fips_deprecated() {
  for fips_cipher in ${CIPHERS_FIPS_DEPRECATED[@]}; do
    if [ "$1" = "$fips_cipher" ]; then
      return 0
    fi
  done

  return 1
}

print_title() {
  format='\e[107m\e[30m'
  end='\e[0m'

  echo -e "${format}${1}${end}"
}

print_pass() {
  color='\e[32m'
  end='\e[0m'

  echo -e "${color}${1}${end}"
}

print_warn() {
  color='\e[33m'
  end='\e[0m'

  echo -e "${color}${1}${end}"
}

print_fail() {
  color=$'\e[31m'
  end=$'\e[0m'

  echo -e "${color}${1}${end}"
}

print_list_title() {
  echo -e "\e[4m${1}\e[24m"
}

print_list() {
  list=("$@")
  for entry in "${list[@]}"; do
    echo -e "${entry}"
  done
  echo -e ""
}

command_help() {
  echo "Usage:"
  echo "    run <endpoint> <report file> - run a test against the provided endpoint"
  echo "    list-approved - prints the list of NIST FIPS 140-2 approved ciphers in IANA format"
  echo "    list-deprecated - prints the list of NIST FIPS 140-2 deprecated ciphers in IANA format"
  echo "    help - print the usage information"
}

command_list_approved() {
  get_nist_ciphers

  print_list_title "NIST FIPS 140-2 Approved Ciphers:"
  print_list "${CIPHERS_FIPS[@]}"
}

command_list_deprecated() {
  get_nist_deprecated_ciphers

  print_list_title "NIST FIPS 140-2 Deprecated Ciphers:"
  print_list "${CIPHERS_FIPS_DEPRECATED[@]}"
}

command_run() {
  # Parameters
  ENDPOINT=$1
  REPORT_FILE=""

  if [ ! -z "$2" ]; then
    REPORT_FILE="$(pwd)/$2"
  fi

  # print message that the script is running
  print_title "Start $(date) -->> $ENDPOINT <<--"

  echo -e "\e[2mNote: Implementing the proper cipher suites does not mean your endpoint is FIPS 140-2 complaint or validated. You must also using NIST validated cryptography modules and running NIST validated operating systems.\e[22m\n\n"

  # Server Cipher List
  SERVER_CIPHERS=$(get_server_ciphers)

  # FIPS Approved Cipher List
  get_nist_ciphers

  # FIPS Deprecated Cipher List
  get_nist_deprecated_ciphers

  # Store results in arrays
  RESULT_PASSED=()
  RESULT_WARN=()
  RESULT_FAILED=()
  OUTPUT_TEXT=""

  for cipher in ${SERVER_CIPHERS[@]}; do

    if is_fips_cipher $cipher; then

      if is_fips_deprecated $cipher; then
        RESULT_WARN+=("$cipher")
      else
        RESULT_PASSED+=("$cipher")
      fi

    else
      RESULT_FAILED+=("$cipher")
    fi

  done

  if [ ${#RESULT_PASSED[@]} -gt 0 ]; then
    print_list_title "Approved Ciphers:"
    print_list "${RESULT_PASSED[@]}"
  fi

  if [ ${#RESULT_WARN[@]} -gt 0 ]; then
    print_list_title "Deprecated Ciphers:"
    print_list "${RESULT_WARN[@]}"
  fi

  if [ ${#RESULT_FAILED[@]} -gt 0 ]; then
    print_list_title "Unapproved Ciphers:"
    print_list "${RESULT_FAILED[@]}"
  fi

  TOTAL_APPROVED_COUNT=$((${#RESULT_PASSED[@]} + ${#RESULT_WARN[@]}))

  print_list_title "Summary Findings:"
  echo -e "- $ENDPOINT implements $TOTAL_APPROVED_COUNT of ${#CIPHERS_FIPS[@]} NIST FIPS 140-2 approved ciphers."
  echo -e "- $ENDPOINT implements ${#RESULT_WARN[@]} of the ${#CIPHERS_FIPS_DEPRECATED[@]} deprecated ciphers by NIST, please update before the transition period ends."
  echo -e "- $ENDPOINT implements ${#RESULT_FAILED[@]} unapproved ciphers from NIST."
  echo -e "\n"

  if [ ${#RESULT_FAILED[@]} -eq 0 ] && [ ${#RESULT_WARN[@]} -eq 0 ]; then
    print_pass "$ENDPOINT implements only NIST approved ciphers."
  elif [ ${#RESULT_FAILED[@]} -eq 0 ] && [ ${#RESULT_WARN[@]} -gt 0 ]; then
    print_warn "$ENDPOINT passed the NIST FIPS 140-2 cipher suite check but implements some deprecated algorithms. Please see NIST Special Publication 800-131A Revision 2."
  else
    print_fail "$ENDPOINT implements ciphers that are not approved by NIST."
  fi

  echo -e ""

  if [ ! -z "$REPORT_FILE" ]; then

    if [ ! -f "$REPORT_FILE" ]; then
      echo -e "API Endpoint, Approved Ciphers, Deprecated Ciphers, Unapproved Ciphers" > $REPORT_FILE
    fi

    echo -e "\e[2mAppending CSV report to $REPORT_FILE...\e[22m \n"
    echo -e "$ENDPOINT,${RESULT_PASSED[@]},${RESULT_WARN[@]},${RESULT_FAILED[@]}" >> $REPORT_FILE
  fi

  print_title "Done $(date) -->> $ENDPOINT <<--"
}

# main run command
case "$1" in
    run)
      shift
      command_run "$@"
      exit 0
      ;;

    list-approved)
      command_list_approved $2
      exit 0
      ;;

    list-deprecated)
      command_list_deprecated $2
      exit 0
      ;;

    help)
      command_help
      exit 1
      ;;

    *)
      command_help
      exit 1
esac

