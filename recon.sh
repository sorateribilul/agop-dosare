#!/usr/bin/env bash
#
# agop-dosare recon tool
# Simple interactive HTTP recon helper for authorized bug bounty targets.
#
# Usage: ./recon.sh [domeniu]
#   - daca nu dai domeniul ca argument, ti-l cere interactiv.
#   - seteaza BB_HEADER ca sa schimbi valoarea trimisa in header-ul
#     X-Bug-Bounty (unele programe cer autoidentificare in trafic).

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

BB_HEADER="${BB_HEADER:-agopx@hackerone.com}"

print_banner() {
  printf "${GREEN}"
  cat <<'EOF'
   _____  _____  ____  _____
  / _ \ \/ / _ \|  _ \|  ___|
 |  __/>  <|  __/ |_) | |__
  \___/_/\_\\___|____/|_____|
EOF
  printf "${RESET}"
  printf "${CYAN}"
  printf '=%.0s' $(seq 1 60)
  printf "\n"
  printf "${RESET}"
}

prompt_domain() {
  printf "${YELLOW}[?] Introduceti domeniul sau tinta de scanat (ex: abercrombie.com): ${RESET}"
  read -r domain
  printf '%s' "$domain"
}

sanitize_domain() {
  local raw="$1"
  raw="${raw#http://}"
  raw="${raw#https://}"
  raw="${raw%%/*}"
  printf '%s' "$raw"
}

run_recon() {
  local domain="$1"
  local url="https://${domain}"

  echo
  echo "== Target: ${domain} =="
  echo "== Header trimis: X-Bug-Bounty: ${BB_HEADER} =="
  echo

  curl -sS -i -H "X-Bug-Bounty: ${BB_HEADER}" "$url" || {
    echo "Cererea catre ${url} a esuat (verifica domeniul / conexiunea)." >&2
    exit 1
  }
  echo
}

main() {
  print_banner

  local raw_domain="${1:-}"
  if [[ -z "$raw_domain" ]]; then
    raw_domain="$(prompt_domain)"
    echo
  fi

  if [[ -z "$raw_domain" ]]; then
    echo "Nu ai introdus niciun domeniu. Iesire." >&2
    exit 1
  fi

  local domain
  domain="$(sanitize_domain "$raw_domain")"

  run_recon "$domain"
}

main "$@"
