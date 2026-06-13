local mainMod = "SUPER"

-- I know it doesn't make sense but I didn't have any more buttons so browser is shift I I guess
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("uwsm app -- zen-browser"), { locked = true })

hl.bind(mainMod .. " + V", hl.dsp.workspace.toggle_special("vpn"))
