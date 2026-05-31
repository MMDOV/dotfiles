local homeDir = os.getenv("HOME")
hl.on("hyprland.start", function()
	local dotfilesRoot = os.getenv("DOTFILES_ROOT")
	-- App launcher
	hl.exec_cmd("elephant")
	hl.exec_cmd("walker --gapplication-service")
	-- Input method
	hl.exec_cmd("fcitx5")
	hl.exec_cmd(dotfilesRoot .. "/scripts/thd.sh")
	-- Core components (authentication, lock screen, notification daemon)
	hl.exec_cmd(
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1"
	)
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("dbus-update-activation-environment --all")
	hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd")
	hl.exec_cmd("uwsm app -- nm-applet")
	-- Audio
	hl.exec_cmd("uwsm app -- easyeffects --gapplication-service")
	-- Clipboard: history
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
	-- Cursor
	hl.exec_cmd("uwsm app -- hyprctl setcursor breeze_cursors 24")

	-- Custom execs
	hl.exec_cmd("uwsm app -- vivaldi")
	hl.exec_cmd(
		"uwsm app -- alacritty -e tmux new-session -d \\; run-shell '"
			.. homeDir
			.. "/.local/bin/tmux-sessionizer $HOME' \\; attach",
		{ workspace = "3" }
	)
	hl.exec_cmd("uwsm app -- Telegram", { workspace = "4 silent" })
	hl.exec_cmd("uwsm app -- thunderbird", { workspace = "4 silent" })
	hl.exec_cmd("uwsm app -- teamspeak3", { workspace = "5 silent" })
	hl.exec_cmd("uwsm app -- discord", { workspace = "5 silent" })
	-- hl.exec_cmd("uwsm app -- gio launch " .. homeDir .. "/.local/share/applications/youtube-music.desktop")
	hl.exec_cmd("uwsm app -- spotify-launcher", { workspace = "6 silent" })
	hl.exec_cmd("uwsm app -- dolphin", { workspace = "7 silent" })
	--hl.exec_cmd(
	--	"uwsm app -- alacritty -e '" .. homeDir .. "/Projects/ponisha-automated/run_main.sh'",
	--	{ workspace = "6 silent" }
	--)
	hl.exec_cmd(
		"uwsm app -- alacritty -e '" .. homeDir .. "/clones/mhr-cfw/run.sh'",
		{ workspace = "special:vpn silent" }
	)
	hl.exec_cmd(
		"uwsm app -- alacritty -e '" .. homeDir .. "/clones/MasterHttpRelayVPN/start.sh'",
		{ workspace = "special:vpn silent" }
	)
	-- hl.exec_cmd(
	-- 	"uwsm app -- alacritty -e sudo " .. dotfilesRoot .. "/scripts/helpers/sni_spoof.sh",
	-- 	{ workspace = "special:vpn silent" }
	-- )
	-- hl.exec_cmd("sudo torguard")
	hl.exec_cmd("uwsm app -- sudo hiddify")
	-- hl.exec_cmd("uwsm app -- /opt/v2rayn-bin/v2rayN", { workspace = "special:vpn silent" })
	-- hl.exec_cmd("uwsm app -- /usr/bin/happ", { workspace = "special:vpn silent" })
	-- hl.exec_cmd("uwsm app -- steam")
end)
