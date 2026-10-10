-- Notification cards and history (quickshell/notifd): blur what is behind them.
hl.layer_rule({ match = { namespace = "^notifd(-history)?$" }, blur = true, ignore_alpha = 0.2 })
