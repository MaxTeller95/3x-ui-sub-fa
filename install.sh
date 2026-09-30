#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  3x-ui-sub-fa - فارسی کردن صفحه‌ی سابسکریپشن 3x-ui (بدون تغییر زبان پنل)
#
#  نصب و روشن کردن:
#      bash <(curl -fsSL https://raw.githubusercontent.com/MaxTeller95/3x-ui-sub-fa/main/install.sh)
#
#  گزینه‌ها (بعد از دستور بالا):
#      --no-jalali     تقویم پنل بماند (پیش‌فرض: تاریخ شمسی)
#      --no-stamp      بدون مهر «منقضی شده / حجم تمام شده»
#      --always        هر بار فارسی (پیش‌فرض: یک بار برای هر مرورگر؛ بعدش دکمه‌ی زبان صفحه کار می‌کند)
#      --no-enable     فقط نصب؛ روشن نکن
#      --uninstall     خاموش کردن و حذف کامل
# ------------------------------------------------------------------------------
set -euo pipefail

REPO=MaxTeller95/3x-ui-sub-fa
RAW="https://raw.githubusercontent.com/$REPO/main"
BIN=/usr/local/sbin/xui-sub-fa
FILES="xui-sub-fa xui-sub-fa.path xui-sub-fa.service"

red() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
inf() { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()  { printf '\033[32m✔\033[0m %s\n' "$*"; }

ENABLE=1 UNINSTALL="" OPTS=()
for a in "$@"; do
  case "$a" in
    --no-enable) ENABLE="" ;;
    --uninstall) UNINSTALL=1 ;;
    --no-jalali|--no-stamp|--always) OPTS+=("$a") ;;
    -h|--help) sed -n '2,15p' "$0" 2>/dev/null || true; exit 0 ;;
    *) red "گزینه‌ی ناشناخته: $a"; exit 1 ;;
  esac
done

[ "$(id -u)" -eq 0 ] || { red "با root اجرا کنید (sudo bash ...)"; exit 1; }

if [ -n "$UNINSTALL" ]; then
  [ -x "$BIN" ] && "$BIN" off || true
  systemctl disable --now xui-sub-fa.path 2>/dev/null || true
  rm -f "$BIN" /etc/systemd/system/xui-sub-fa.path /etc/systemd/system/xui-sub-fa.service /etc/xui-sub-fa.json
  rm -rf /usr/local/share/xui-sub-fa /etc/systemd/system/xui-sub-fa.service.d
  systemctl daemon-reload
  ok "حذف شد؛ صفحه‌ی خود پنل برگشت"
  exit 0
fi

# ---------------------------------------------------------------- پیش‌نیازها
pkg() {   # نصب یک بسته با مدیر بسته‌ی سیستم
  if command -v apt-get >/dev/null; then apt-get update -qq && apt-get install -y -qq "$1" >/dev/null
  elif command -v dnf >/dev/null; then dnf install -y -q "$2"
  elif command -v yum >/dev/null; then yum install -y -q "$2"
  else red "$1 را دستی نصب کنید"; exit 1; fi
}
if ! command -v python3 >/dev/null || ! python3 -c 'import sqlite3' 2>/dev/null; then
  inf "نصب python3"; pkg python3 python3
fi

# ---------------------------------------------------------------- دریافت
here=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo /nonexistent)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
for f in $FILES; do
  if [ -f "$here/$f" ]; then cp "$here/$f" "$tmp/$f"                  # از روی clone
  else curl -fsSL "$RAW/$f" -o "$tmp/$f" || { red "دریافت $f نشد"; exit 1; }
  fi
done
python3 -m py_compile "$tmp/xui-sub-fa" 2>/dev/null || { red "فایل دریافتی خراب است"; exit 1; }
rm -rf "$tmp/__pycache__"

# ---------------------------------------------------------------- تشخیص پنل و دیتابیس
# همان‌طور که خود x-ui می‌بیند: محیط پروسه‌ی در حال اجرا، بعد تنظیمات سرویس، بعد پیش‌فرض
python3 "$tmp/xui-sub-fa" detect | sed 's/^/    /'
eval "$(python3 "$tmp/xui-sub-fa" detect --shell)"
[ -f "$XUI_BIN_FOUND" ] || { red "x-ui پیدا نشد (اگر جای دیگری است XUI_BIN را تنظیم کنید)"; exit 1; }
grep -qa subThemeDir "$XUI_BIN_FOUND" || { red "این نسخه‌ی 3x-ui تنظیم Sub Theme Directory ندارد؛ اول پنل را آپدیت کنید"; exit 1; }
if [ "$XUI_KIND" = postgres ] && ! command -v psql >/dev/null; then
  inf "پنل از PostgreSQL استفاده می‌کند؛ نصب psql"; pkg postgresql-client postgresql
fi

# ---------------------------------------------------------------- نصب
install -m 755 "$tmp/xui-sub-fa" "$BIN"
install -m 644 "$tmp/xui-sub-fa.path" "$tmp/xui-sub-fa.service" /etc/systemd/system/
sed -i "s|^PathChanged=.*|PathChanged=$XUI_BIN_FOUND|" /etc/systemd/system/xui-sub-fa.path
rm -rf /etc/systemd/system/xui-sub-fa.service.d
systemctl daemon-reload
ok "نصب شد: $BIN ($("$BIN" --version))"

# ---------------------------------------------------------------- روشن کردن
if [ -n "$ENABLE" ]; then
  "$BIN" on ${OPTS[@]+"${OPTS[@]}"}
  ok "صفحه‌ی سابسکریپشن فارسی شد. لینک اشتراک یکی از کاربران را در مرورگر باز کنید."
else
  inf "برای روشن کردن: xui-sub-fa on"
fi
cat <<'EOF'

  xui-sub-fa status     وضعیت
  xui-sub-fa off        برگشت به صفحه‌ی خود پنل
  xui-sub-fa refresh    ساختن دوباره (بعد از آپدیت پنل خودکار انجام می‌شود)
EOF
