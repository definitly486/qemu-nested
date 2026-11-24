
#!/usr/bin/env bash
set -euo pipefail

VM_NAME="Windows2000"
VM_DIR="$HOME/VM/$VM_NAME"
DISK="$VM_DIR/windows2000.qcow2"

RAM=512

if [[ ! -f "$DISK" ]]; then
    echo "ОШИБКА: виртуальный диск не найден:"
    echo "$DISK"
    exit 1
fi

echo "======================================"
echo "       Windows 2000 SP3 Russian"
echo "======================================"
echo "Режим       : Запуск установленной ОС"
echo "Диск        : $DISK"
echo "Память      : ${RAM} MB"
echo "Процессор   : Pentium III"
echo "Виртуализация: KVM"
echo "Видеокарта  : Cirrus"
echo "Сеть        : RTL8139"
echo "VNC         : 127.0.0.1:5901"
echo "ISO         : НЕ ПОДКЛЮЧЕН"
echo "======================================"

exec qemu-system-i386 \
    -name "$VM_NAME" \
    -machine pc,accel=kvm \
    -enable-kvm \
    -cpu pentium3 \
    -m "$RAM" \
    -smp 1 \
    -drive "file=$DISK,format=qcow2,if=ide,index=0" \
    -boot order=c \
    -vga cirrus \
    -display none \
    -vnc 127.0.0.1:1 \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0
