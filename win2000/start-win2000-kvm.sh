
#!/usr/bin/env bash
set -euo pipefail

VM_NAME="Windows2000"
DISK="$HOME/VM/$VM_NAME/windows2000.qcow2"

if [[ ! -f "$DISK" ]]; then
    echo "Диск не найден: $DISK"
    exit 1
fi

echo "Windows 2000 — KVM compatibility mode"
echo "CPU: qemu64"
echo "RAM: 512 MB"
echo "ACPI: disabled"
echo "APIC: disabled"
echo "VNC: 127.0.0.1:5901"

exec qemu-system-i386 \
    -name "$VM_NAME" \
    -machine pc,accel=kvm \
    -enable-kvm \
    -cpu qemu64 \
    -m 512 \
    -smp 1 \
    -no-acpi \
    -no-hpet \
    -drive "file=$DISK,format=qcow2,if=ide,index=0" \
    -boot order=c \
    -vga cirrus \
    -display none \
    -vnc 0.0.0.0:1 \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0
