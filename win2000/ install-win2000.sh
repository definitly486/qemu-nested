
#!/usr/bin/env bash
set -euo pipefail

# Windows 2000 SP3 Russian — QEMU

VM_NAME="Windows2000"
VM_DIR="$HOME/VM/$VM_NAME"
ISO="$HOME/Windows 2000.ver.SP3.Russian.iso"
DISK="$VM_DIR/windows2000.qcow2"

RAM="512"
DISK_SIZE="10G"

mkdir -p "$VM_DIR"

# Проверка QEMU
if ! command -v qemu-system-i386 >/dev/null 2>&1; then
    echo "Ошибка: qemu-system-i386 не установлен"
    exit 1
fi

# Проверка ISO
if [[ ! -f "$ISO" ]]; then
    echo "ISO не найден: $ISO"
    echo "Измени переменную ISO в скрипте."
    exit 1
fi

# Создание виртуального HDD
if [[ ! -f "$DISK" ]]; then
    echo "Создание виртуального диска $DISK_SIZE..."
    qemu-img create -f qcow2 "$DISK" "$DISK_SIZE"
fi

MODE="${1:-install}"

case "$MODE" in
    install)
        echo "Запуск установки Windows 2000 SP3..."
        BOOT="-boot order=d,menu=on"
        EXTRA="-win2k-hack"
        CDROM="-drive file=$ISO,media=cdrom,readonly=on"
        ;;
    start)
        echo "Запуск установленной Windows 2000..."
        BOOT="-boot order=c"
        EXTRA=""
        CDROM=""
        ;;
    *)
        echo "Использование:"
        echo "  $0 install  - установка Windows 2000"
        echo "  $0 start    - запуск установленной системы"
        exit 1
        ;;
esac

exec qemu-system-i386 \
    -name "$VM_NAME" \
    -machine pc,accel=kvm \
    -enable-kvm \
    -cpu host \
    -m "$RAM" \
    -smp 1 \
    -drive file="$DISK",format=qcow2,if=ide,index=0 \
    ${CDROM:+$CDROM} \
    $BOOT \
    $EXTRA \
    -vga cirrus \
    -display none \
    -vnc 127.0.0.1:1 \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0

