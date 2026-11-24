
#!/usr/bin/env bash
set -euo pipefail

VM_NAME="Windows2000"
VM_DIR="$HOME/VM/$VM_NAME"

QEMU="/usr/bin/qemu-system-x86_64"
VM_DISK="$VM_DIR/windows2000.qcow2"

RAM="512"
CPUS="1"

PIDFILE="$VM_DIR/qemu.pid"
MONITOR="$VM_DIR/qemu-monitor.sock"

mkdir -p "$VM_DIR"

# Проверка запущенной машины
is_running() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "${1:-start}" in

start)
    if is_running; then
        echo "Windows 2000 уже запущена. PID: $(cat "$PIDFILE")"
        exit 0
    fi

    if [[ ! -f "$VM_DISK" ]]; then
        echo "ОШИБКА: диск не найден: $VM_DISK"
        exit 1
    fi

    rm -f "$PIDFILE" "$MONITOR"

    echo "======================================"
    echo "       WINDOWS 2000 SP3 RUSSIAN"
    echo "======================================"
    echo "Machine : PC / KVM"
    echo "CPU     : host"
    echo "RAM     : $RAM MB"
    echo "CPUs    : $CPUS"
    echo "Disk    : QCOW2 / IDE"
    echo "VGA     : Standard"
    echo "Network : E1000"
    echo "VNC     : 0.0.0.0:5900"
    echo "USB     : Tablet"
    echo "RTC     : localtime"
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
        -vnc 0.0.0.0:0 \
        -netdev user,id=net0 \
        -device e1000,netdev=net0 \
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
    ;;

stop)
    if ! is_running; then
        echo "Windows 2000 не запущена."
        rm -f "$PIDFILE" "$MONITOR"
        exit 0
    fi

    if ! command -v socat >/dev/null 2>&1; then
        echo "Установи socat: sudo apt install socat"
        exit 1
    fi

    echo "Отправка команды выключения Windows 2000..."

    printf 'system_powerdown\n' | socat - "UNIX-CONNECT:$MONITOR"

    echo "Ожидание выключения (до 60 секунд)..."

    for i in $(seq 1 60); do
        if ! is_running; then
            echo "Windows 2000 остановлена."
            rm -f "$PIDFILE" "$MONITOR"
            exit 0
        fi
        sleep 1
    done

    echo "Windows ещё работает."
    echo "Для принудительной остановки:"
    echo "./start-win2000-kvm.sh force"
    ;;

force)
    if is_running; then
        PID=$(cat "$PIDFILE")
        echo "Принудительная остановка QEMU PID=$PID"
        kill -TERM "$PID"
        sleep 2
    fi

    rm -f "$PIDFILE" "$MONITOR"
    echo "QEMU остановлен."
    ;;

status)
    if is_running; then
        echo "Windows 2000 запущена. PID: $(cat "$PIDFILE")"
    else
        echo "Windows 2000 остановлена."
    fi
    ;;

*)
    echo "Использование:"
    echo "$0 start  - запуск"
    echo "$0 stop   - штатное выключение"
    echo "$0 force  - принудительная остановка"
    echo "$0 status - состояние"
    exit 1
    ;;

esac
