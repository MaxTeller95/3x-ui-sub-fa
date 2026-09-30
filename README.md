# 3x-ui-sub-fa

صفحه‌ی سابسکریپشن **3x-ui** را فارسی می‌کند، **بدون این‌که زبان خود پنل عوض شود**، و روی اشتراک‌هایی که تمام
شده‌اند یک مهر قرمز می‌زند.

- **همان صفحه‌ی خود پنل** (حلقه‌ی مصرف، حالت تیره، QR، افزودن یک‌لمسی به اپ‌ها و ...): قالب از داخل خود باینری
  x-ui ساخته می‌شود، پس ظاهرش دقیقاً همان است و با آپدیت پنل هم همان می‌ماند
- **فارسی** برای هر مرورگر یک بار؛ بعد از آن دکمه‌ی زبان خود صفحه کار می‌کند (با `--always` همیشه فارسی)
- **تاریخ شمسی** وقتی صفحه فارسی است؛ تقویم خود پنل دست نمی‌خورد
- **مهر قرمز** وسط صفحه: «منقضی شده»، «حجم تمام شده» یا «غیرفعال»؛ هر ۳۰ ثانیه تازه می‌شود
- اپ‌ها (v2rayNG، Hiddify، Streisand و ...) مثل قبل فقط کانفیگ می‌گیرند؛ این فقط صفحه‌ای است که مرورگر می‌بیند
- بدون ری‌استارت پنل؛ بعد از آپدیت پنل، خودش دوباره ساخته می‌شود

## نصب

روی سرور پنل، با root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MaxTeller95/3x-ui-sub-fa/main/install.sh)
```

بعد لینک اشتراک یکی از کاربران را در مرورگر باز کنید.

گزینه‌ها را بعد از همان دستور بنویسید:

| گزینه | کار |
|---|---|
| `--no-jalali` | تاریخ‌ها با تقویم پنل بمانند |
| `--no-stamp` | بدون مهر |
| `--always` | هر بار فارسی، حتی اگر کاربر زبان را عوض کرده باشد |
| `--no-enable` | فقط نصب، روشن نکن |
| `--uninstall` | خاموش کردن و حذف کامل |

مثال: `bash <(curl -fsSL https://raw.githubusercontent.com/MaxTeller95/3x-ui-sub-fa/main/install.sh) --no-stamp`

## دستورها

```bash
xui-sub-fa status          # کدام صفحه نمایش داده می‌شود و آیا با نسخه‌ی پنل جور است
xui-sub-fa status --sub LINK   # امتحان با لینک اشتراک یک کاربر مشخص (یا فقط subId)
xui-sub-fa on [گزینه‌ها]    # روشن کردن یا عوض کردن گزینه‌ها (--no-jalali --no-stamp --always و برعکس‌شان --jalali --stamp --once)
xui-sub-fa refresh         # ساختن دوباره (بعد از آپدیت پنل خودکار انجام می‌شود)
xui-sub-fa off             # برگشت به صفحه‌ی خود پنل
```

## پیش‌نیاز

- 3x-ui نسخه‌ی 3 که تنظیم **Sub Theme Directory** دارد (تنظیمات ← اشتراک). نصب‌کننده خودش چک می‌کند.
- سرویس اشتراک در پنل روشن باشد. `python3` اگر نباشد نصب می‌شود.
- نصب معمولی پنل (`/usr/local/x-ui/x-ui` و `/etc/x-ui/x-ui.db`). اگر جای دیگری است:
  `XUI_BIN=/path/x-ui XUI_DB=/path/x-ui.db bash <(curl ...)`

## چطور کار می‌کند

زبان صفحه‌ی اشتراک در 3x-ui از زبان پنل جداست (کوکی `subLang` در مرورگر کاربر) و پیش‌فرضش زبان گوشی است؛
برای همین گوشی انگلیسی صفحه را انگلیسی می‌بیند. 3x-ui می‌تواند صفحه را از یک قالب بسازد (Sub Theme Directory).
این ابزار صفحه‌ی اصلی را از باینری x-ui برمی‌دارد و سه چیز کوچک به آن اضافه می‌کند: انتخاب فارسی، تقویم شمسی
و مهر. بعد تنظیم را روی پوشه‌ی `/usr/local/share/xui-sub-fa` می‌گذارد و یک اشتراک واقعی را امتحان می‌کند؛
اگر قالب نمایش داده نشد تنظیم قبلی را برمی‌گرداند.

نام فایل‌های اسکریپت صفحه با هر نسخه‌ی پنل عوض می‌شود؛ `xui-sub-fa.path` با عوض شدن باینری x-ui قالب را
دوباره می‌سازد.

| فایل | جا |
|---|---|
| ابزار | `/usr/local/sbin/xui-sub-fa` |
| قالب ساخته‌شده | `/usr/local/share/xui-sub-fa/index.html` |
| گزینه‌ها | `/etc/xui-sub-fa.json` |
| ساخت خودکار بعد از آپدیت | `xui-sub-fa.path`، `xui-sub-fa.service` |

---

## English

Makes the **3x-ui** subscription page Persian without touching the panel's own language, and
stamps expired, used-up or disabled subscriptions in red. The template is built from the panel's
own page inside the x-ui binary, so it looks exactly the same; added are only a Persian language
cookie (once per browser, or `--always`), Jalali dates while Persian (`--no-jalali` to keep the
panel's calendar) and the stamp (`--no-stamp`). Apps still get only the configs. No panel restart;
`xui-sub-fa.path` rebuilds the template when the x-ui binary changes, since the page's asset names
change per release. Needs 3x-ui 3.x with the "Sub Theme Directory" setting.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MaxTeller95/3x-ui-sub-fa/main/install.sh)
xui-sub-fa status | on [--no-jalali] [--no-stamp] [--always] | refresh | off
```

License: MIT. 3x-ui itself is GPL-3.0; this repository contains none of its code - the page is
read from the installed panel at run time.
