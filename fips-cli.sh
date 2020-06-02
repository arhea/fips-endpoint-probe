#!/bin/bash -e

usage() {
  cat << EOF
usage: $0 <url> <path>

URL: <hostname>:<port>
Path: /

EOF
}

# Parameters
TEST_ENDPOINT="$1"
TEST_PATH="$2"

# List all of the ciphers available in OpenSSL
CIPHERS_ALL=$(openssl ciphers 'ALL' | tr ':' '\n')

# FIPS Ciphers
CIPHERS_FIPS=$(openssl ciphers 'TLSv1.2+FIPS:kRSA+FIPS:!SSLv3:!eNULL:!aNULL' | tr ':' '\n')

# show warnings for all TLS 1.0 and 1.1 ciphers
CIPHERS_FIPS_TLS_DEPRECATED=()

# show warnings for tls 1.0 ciphers
CIPHERS_FIPS_TLS_DEPRECATED+=$(openssl ciphers -v 'TLSv1' | tr ':' '\n')

# SSLv3 has been deprecated by the IETF
CIPHERS_FIPS_TLS_DEPRECATED+=$(openssl ciphers -v 'SSLv3' | tr ':' '\n')

# show warnings for NIST deprecated ciphers
CIPHERS_FIPS_NIST_DEPRECATED=( "AES128-CCM" "AES256-CCM" "AES128-CCM8" "AES256-CCM8" "AES128-SHA" "AES256-SHA" "AES128-SHA256" "AES256-SHA256" "AES128-GCM-SHA256" "AES256-GCM-SHA384" )

print_info() {
  color=$'\e[1;34m'
  end=$'\e[0m'

  printf "\360\237\222\244 ${color}- ${1} - ${2}${end}\n"
}

print_expected() {
  color=$'\e[1;90m'
  end=$'\e[0m'

  printf "\342\234\224 ${color}- ${1}${end}\n"
}

print_pass() {
  color=$'\e[1;32m'
  end=$'\e[0m'

  printf "\342\234\205 ${color}- ${1}${end}\n"
}

print_fail() {
  color=$'\e[1;31m'
  end=$'\e[0m'

  printf "\342\235\214 ${color}- ${1} - ${2}${end}\n"
}

print_warn() {
  color=$'\e[1;33m'
  end=$'\e[0m'

  printf "\342\232\240 ${color}- ${1} - ${2}${end}\n"
}

# test cipher against the provided endpoint
test_cipher() {
  (echo "GET $TEST_PATH" ; sleep 1) | openssl s_client -connect $TEST_ENDPOINT -cipher $1 > /dev/null 2>&1
}

# check if a cipher is a fips cipher
is_fips_cipher() {
  for fips_cipher in ${CIPHERS_FIPS[@]}; do
    if [ "$1" = "$fips_cipher" ]; then
      return 0
    fi
  done

  return 1
}

is_fips_tls_deprecated() {
  for fips_cipher in ${CIPHERS_FIPS_TLS_DEPRECATED[@]}; do
    if [ "$1" = "$fips_cipher" ]; then
      return 0
    fi
  done

  return 1
}

is_fips_nist_deprecated() {
  for fips_cipher in ${CIPHERS_FIPS_NIST_DEPRECATED[@]}; do
    if [ "$1" = "$fips_cipher" ]; then
      return 0
    fi
  done

  return 1
}

run_endpoint_tests() {
  for cipher in ${CIPHERS_ALL[@]}; do

    if is_fips_cipher $cipher; then

      # if it is a FIPS cipher make sure it is supported
      if test_cipher $cipher; then

        if is_fips_tls_deprecated $cipher; then
          print_warn $cipher "FedRAMP discourages the use of TLS versions 1.1 and 1.0 connections, these should be moved to TLS 1.2 or greater."
        elif is_fips_nist_deprecated $cipher; then
          print_warn $cipher "NIST Special Publication 800-52 revision 2 Appendix D, this cipher is not recommended, but are permitted until 2023 under FedRAMP during a transition period."
        else
          print_pass $cipher
        fi

      else
        print_info $cipher "FIPS 140-2 supports $cipher, but is not required."
      fi

    else

      # if it is not a FIPS cipher make sure it is not supported
      if test_cipher $cipher; then

        if is_fips_nist_deprecated $cipher; then
          print_expected $cipher
        else
          print_fail $cipher "Expected $cipher to fail on a FIPS 140-2 compliant endpoint."
        fi

      else
        print_expected $cipher
      fi

    fi

  done
}

run_endpoint_tests
