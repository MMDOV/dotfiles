# دات‌فایل‌های شخصی لینوکس

> [!IMPORTANT]
> این مخزن برای ورک‌استیشن شخصی من روی Arch Linux، سخت‌افزار خودم و روند کاری خودم تنظیم شده است. می‌تواند به‌عنوان مرجع برای Hyprland، اتوماسیون Bash و مدیریت محیط دسکتاپ مفید باشد، اما قبل از اجرا روی سیستم دیگر باید بررسی شود.

این مخزن یک مجموعه فنی از دات‌فایل‌ها برای یک دسکتاپ Wayland بر پایه Hyprland است. در اینجا تنظیمات ماژولار دسکتاپ، قوانین Hyprland با Lua، اسکریپت‌های نصب پکیج، ابزارهای کمکی محلی، مدیریت session در tmux و تم‌های GTK/Qt/SDDM در یک setup قابل بازتولید کنار هم قرار گرفته‌اند.

## تصاویر

### دسکتاپ Hyprland

![تصویر دسکتاپ Hyprland](assets/screenshots/Hyprland_Desktop.png)

### دسکتاپ Hyprland ۲

![تصویر دسکتاپ Hyprland ۲](assets/screenshots/Nvim_btop.png)

### ادیتور Neovim

![تصویر ادیتور Neovim](assets/screenshots/Nvim_Editor.png)

### Dolphin

![تصویر Dolphin](assets/screenshots/Dolphin.png)

## نمای کلی معماری

این مخزن حول یک نسخه کنترل‌شده از محیط کاربری لینوکس سازمان‌دهی شده است:

- `dotfiles/config/` معادل `~/.config/` است و تنظیمات Hyprland، Waybar، Neovim، Yazi، ترمینال‌ها، input method، اعلان‌ها و برنامه‌ها را نگه می‌دارد.
- `dotfiles/local/` معادل `~/.local/` است و desktop entry ها و لانچرهای سطح کاربر را نگه می‌دارد.
- `dotfiles/system/` شامل تنظیمات سیستمی مخصوص Arch مثل `pacman.conf` و `makepkg.conf` است.
- `install/core/` ماژول‌های نصب برای پکیج‌های پایه، درایورها، PipeWire، NetworkManager، Hyprland، Neovim، tmux، ابزارهای گیمینگ و extras را نگه می‌دارد.
- `install/desktop/` شامل راه‌اندازی display manager و تم است.
- `scripts/utils/` ابزارهای هماهنگ‌کننده برای sync کردن config ها، نصب پکیج، به‌روزرسانی repo و workflow های Obsidian/brain را نگه می‌دارد.
- `scripts/helpers/` شامل ابزارهای مستقل برای VPN routing، file manager ها، Steam/Lutris، Yazi، مرورگرها، mount کردن و دیالوگ‌های GUI است.
- `themes/`، `assets/` و `tmux/` شامل asset های تصویری، screenshot ها، تم‌های SDDM/Qt، تنظیمات tmux و اسکریپت‌های ساخت session هستند.

## مهاجرت Hyprland به Lua

تنظیمات Hyprland در حال مهاجرت به ساختار ماژولار Lua داخل `dotfiles/config/hypr/` است. به‌جای نگه داشتن تمام رفتار compositor در یک فایل static بزرگ، فایل `hyprland.lua` به‌عنوان entrypoint عمل می‌کند و ماژول‌های جداگانه را import می‌کند:

- `hyprland/general.lua` مانیتورها، رفتار input، gesture ها، layout پیش‌فرض، border ها، blur، shadow و استایل group ها را تعریف می‌کند.
- `hyprland/rules.lua` جای‌گذاری کلی workspace ها و رفتارهای مشترک window ها را تعریف می‌کند و سپس rule های مخصوص هر برنامه را load می‌کند.
- `hyprland/execs.lua` orchestration شروع session را از طریق hook مربوط به `hyprland.start` ثبت می‌کند؛ مثل سرویس launcher، input method، تاریخچه clipboard، authentication agent، network applet، ترمینال، مرورگر، file manager و workspace های مرتبط با VPN.
- `hyprland/keybinds.lua` ماژول‌های keybind مربوط به مدیریت window، کلیدهای لپ‌تاپ، کنترل playback و shortcut های برنامه‌ها را ترکیب می‌کند.
- `hyprland/apps/*.lua` قوانین پیشرفته window را بر اساس دامنه برنامه جدا می‌کند: مرورگرها، Steam/game ها، Discord/Vesktop، TeamSpeak، Spotify، ترمینال‌ها، VPN client ها، QEMU، MPV، picture-in-picture، popup های RTL، دیالوگ‌های پیشرفت Dolphin/Thunar و پنجره‌های Zenity/Tkinter.

این ساختار Lua تنظیمات دسکتاپ را نسبت به config ساده Hyprland قابل‌برنامه‌نویسی‌تر می‌کند. با function call هایی مثل `hl.window_rule`، `hl.workspace_rule`، `hl.bind` و `hl.exec_cmd` می‌شود routing logic، matcher های قابل استفاده مجدد، اندازه و موقعیت پویا، special workspace ها، جای‌گذاری startup، tag ها، opacity، pin شدن، حالت floating و workspace های وابسته به مانیتور را دقیق‌تر تعریف کرد.

نمونه‌هایی از مدل routing:

- workspace های `1-3` روی پنل لپ‌تاپ `eDP-1` قرار می‌گیرند و workspace های `4-7` به مانیتور خارجی `HDMI-A-1` اختصاص داده می‌شوند.
- پنجره‌های مرورگر به‌صورت tiled روی workspace `2` می‌روند، در حالی که web app های موسیقی به workspace `6` فرستاده می‌شوند.
- game ها و پنجره‌های Steam به workspace `1` می‌روند و opacity کامل و رفتار مناسب بازی می‌گیرند.
- ابزارهای ارتباطی مثل Discord، Vesktop و TeamSpeak به workspace `5` هدایت می‌شوند.
- ابزارهای VPN tag می‌شوند و به special workspace با نام `special:vpn` می‌روند.
- پنجره‌های picture-in-picture tag، float، pin و resize می‌شوند و در موقعیت قابل پیش‌بینی روی صفحه قرار می‌گیرند.

## Orchestration با Bash

روند setup عمداً ماژولار است و به‌صورت یک installer تک‌فایلی بزرگ نوشته نشده:

- `install/setup.sh` مقدار `REPO_ROOT` را تشخیص می‌دهد، ترتیب اجرای ماژول‌ها را تعریف می‌کند، از `--dry-run`، `--only` و `--skip` پشتیبانی می‌کند و هر ماژول نصب را از `install/core/` یا `install/desktop/` اجرا می‌کند.
- ماژول‌های نصب بر اساس مسئولیت جدا شده‌اند تا نصب پکیج، سرویس‌ها، اجزای دسکتاپ و setup برنامه‌ها مستقل‌تر تست شوند.
- `scripts/utils/update-config.sh` درخت config های track شده را به مقصد runtime کپی می‌کند و در صورت امکان Hyprland را reload می‌کند.
- `scripts/utils/install.sh` وجود `paru` را تضمین می‌کند، پکیج درخواستی را نصب می‌کند و سپس پوشه config متناظر را کپی می‌کند.

این ساختار باعث می‌شود مخزن هم برای bootstrap سیستم جدید کاربرد داشته باشد و هم برای sync روزمره config ها.

## دستورهای اصلی

کلون کردن مخزن:

```bash
git clone https://github.com/MMDOV/dotfiles.git ~/personal
cd ~/personal
```

پیش‌نمایش setup بدون اعمال تغییر:

```bash
./install/setup.sh --dry-run
```

اجرای کامل setup:

```bash
./install/setup.sh
```

اجرای فقط چند ماژول مشخص:

```bash
./install/setup.sh --only hyprland,nvim,tmux
```

رد کردن چند ماژول:

```bash
./install/setup.sh --skip drivers,sddm
```

sync کردن همه config ها بعد از ویرایش:

```bash
./scripts/utils/update-config.sh
```

sync کردن فقط یک پوشه config، مثلا Neovim:

```bash
./scripts/utils/update-config.sh config nvim
```

## اعتبارسنجی

تست رسمی برای این مخزن تعریف نشده، چون بیشتر شامل تنظیمات سیستم است؛ اما چند بررسی عملی وجود دارد:

```bash
find scripts install -name '*.sh' -print0 | xargs -0 bash -n
hyprctl reload
```

بررسی‌های دستی پیشنهادی:

- قبل از نصب روی سیستم جدید، `./install/setup.sh --dry-run` را اجرا کنید.
- بعد از تغییرات Lua یا تنظیمات compositor، Hyprland را reload کنید.
- برنامه مرتبط را باز کنید تا workspace routing و window rule ها بررسی شوند.
- بعد از تغییرات Waybar، tmux یا Neovim همان ابزار را restart یا reload کنید.
- اسکریپت‌هایی را که از `sudo` استفاده می‌کنند، پکیج نصب می‌کنند، سرویس فعال می‌کنند یا فایل‌های `~/.config`، `~/.local` و `/etc` را بازنویسی می‌کنند با دقت بررسی کنید.

## نکته‌ها

- این setup برای Arch Linux نوشته شده و وجود `pacman`، `paru`، systemd، Wayland و Hyprland را فرض می‌کند.
- بعضی اسکریپت‌ها سرویس‌هایی مثل SDDM و NetworkManager را فعال می‌کنند.
- بعضی مسیرها و انتخاب‌های workspace عمداً شخصی و وابسته به سخت‌افزار هستند.
- نسخه انگلیسی در [`README.md`](README.md) موجود است.
