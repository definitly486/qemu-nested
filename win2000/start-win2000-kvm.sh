
#!/usr/bin/env bash
set -euo pipefail

VM_NAME="Windows2000"
VM_DIR="$HOME/VM/$VM_NAME"

QEMU="qemu-system-i386"
VM_DISK="$VM_DIR/windows2000.qcow2"

RAM="512"
CPUS="1"

PIDFILE="$VM_DIR/qemu.pid"
MONITOR="$VM_DIR/qemu-monitor.sock"

mkdir -p "$VM_DIR"

if [[ ! -f "$VM_DISK" ]]; then
    echo "ОШИБКА: виртуальный диск не найден:"
    echo "$VM_DISK"
    exit 1
fi

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "Windows 2000 уже запущена."
    exit 1
fi

rm -f "$PIDFILE" "$MONITOR"

echo "======================================"
echo "       WINDOWS 2000 SP3 RUSSIAN"
echo "======================================"
echo "QEMU       : $QEMU"
echo "Machine    : PC / KVM"
echo "CPU        : host"
echo "RAM        : $RAM MB"
echo "CPUs       : $CPUS"
echo "Disk       : $VM_DISK"
echo "Disk format: QCOW2"
echo "VGA        : Standard"
echo "Network    : RTL8139"
echo "VNC        : 0.0.0.0:5900"
echo "USB Tablet : enabled"
echo "RTC        : localtime"
echo "======================================"

"$QEMU" \
    -name "$VM_NAME" \
    -machine pc,accel=kvm \
    -cpu host \
    -smp "$CPUS" \
    -m "$RAM" \
    -drive "file=$VM_DISK,format=qcow2,if=ide,index=0" \
    -boot order=c \
    -vga std \
    -display none \
    -vnc "0.0.0.0:0" \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0 \
    -usb \
    -device usb-tablet \
    -rtc base=localtime \
    -no-reboot \
    -daemonize \
    -pidfile "$PIDFILE" \
    -monitor "unix:$MONITOR,server=on,wait=off"

echo
echo "Windows 2000 запущена."
echo "PID: $(cat "$PIDFILE")"
echo "VNC: 192.168.8.104:5900"
echo "Monitor: $MONITOR"
