#!/usr/bin/env bash
# Kernel-side recorder for how a Hyprland process dies when auditd sees nothing.
#
# auditd only sees signals sent through syscalls (kill, tgkill, ...) and core-
# dumping faults. A process can also die from a signal the kernel generates
# itself (SIGPIPE, SIGKILL from the OOM killer or a cgroup, SIGALRM, ...), which
# leaves no audit record. This uses the kernel's own trace events instead:
# they fire only for tasks named "Hyprland", so the cost is negligible, and
# the ring buffer lives in kernel memory (not /run, so it cannot fill the tmpfs).
#
# Usage: sudo hyprland-signal-trace.sh enable|show|disable|install-service|remove-service
# The trace setting lives in kernel memory and is lost on reboot, so run
# `install-service` once: it re-enables the recorder at every boot.
# `enable` refuses to restart a recording that is already running, because
# restarting clears the buffer (and with it the evidence of the last crash).
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run with sudo" >&2
    exit 1
fi

T=/sys/kernel/tracing
[[ -d $T ]] || mount -t tracefs nodev "$T"

put() { # put VALUE FILE
    if ! printf '%s\n' "$1" >"$T/$2"; then
        echo "FAILED writing '$1' to $2" >&2
        exit 1
    fi
}

clear_triggers() {
    local ev line
    for ev in signal/signal_generate sched/sched_process_exit; do
        while IFS= read -r line; do
            [[ $line == stacktrace* ]] || continue
            put "!${line/:unlimited/}" "events/$ev/trigger"
        done <"$T/events/$ev/trigger"
    done
}

case "${1:-}" in
enable)
    if [[ $(cat "$T/tracing_on") == 1 && $(cat "$T/events/signal/signal_generate/enable") == 1 ]] &&
        grep -q 'if comm' "$T/events/signal/signal_generate/trigger"; then
        echo "already recording; not clearing the buffer. Use 'show' to read it."
        exit 0
    fi
    put 0 tracing_on
    clear_triggers
    put 0 events/enable
    put '' trace
    put 16384 buffer_size_kb

    # A signal is generated for a task named Hyprland (comm = the target's name).
    # The stacktrace trigger records the kernel call chain that generated it:
    # a syscall from another process, a pipe write, the OOM killer, a fault, ...
    put 'comm == "Hyprland"' events/signal/signal_generate/filter
    put 'stacktrace if comm == "Hyprland"' events/signal/signal_generate/trigger
    put 1 events/signal/signal_generate/enable

    # A Hyprland task exits (any thread, any cause).
    put 'comm == "Hyprland"' events/sched/sched_process_exit/filter
    put 'stacktrace if comm == "Hyprland"' events/sched/sched_process_exit/trigger
    put 1 events/sched/sched_process_exit/enable

    put 1 tracing_on
    echo "recording; read it after a crash with: sudo $0 show"
    ;;
show)
    # signal_generate: sig=9 KILL, 13 PIPE, 14 ALRM, 15 TERM, 6 ABRT, 11 SEGV, 1 HUP
    # pid= is the target task, code= says who made it (0 = sent by a user
    # process via kill(), -6 = tkill/tgkill, 0x80 = sent by the kernel, 1 = fault).
    cat "$T/trace"
    ;;
disable)
    put 0 tracing_on
    clear_triggers
    put 0 events/signal/signal_generate/enable
    put 0 events/sched/sched_process_exit/enable
    put 0 events/signal/signal_generate/filter
    put 0 events/sched/sched_process_exit/filter
    ;;
install-service)
    self=$(readlink -f "${BASH_SOURCE[0]}")
    cat >/etc/systemd/system/hyprland-signal-trace.service <<UNIT
[Unit]
Description=Record signals sent to and exits of Hyprland (kernel trace events)

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$self enable

[Install]
WantedBy=multi-user.target
UNIT
    systemctl daemon-reload
    systemctl enable --now hyprland-signal-trace.service
    ;;
remove-service)
    systemctl disable --now hyprland-signal-trace.service || true
    rm -f /etc/systemd/system/hyprland-signal-trace.service
    systemctl daemon-reload
    ;;
*)
    echo "usage: $0 enable|show|disable|install-service|remove-service" >&2
    exit 2
    ;;
esac
