#!/bin/bash

# ==========================
# Program Catatan Keuangan
# ==========================

# Array untuk menyimpan catatan (pemasukan/pengeluaran)
declare -a notes
declare -a amounts

# Warna ANSI supaya output lebih menarik
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Fungsi menampilkan semua catatan
show_notes() {
    if [ ${#notes[@]} -eq 0 ]; then
        echo -e "${YELLOW}Belum ada catatan.${RESET}"
        return
    fi

    echo -e "${CYAN}======= DAFTAR CATATAN =======${RESET}"
    for i in "${!notes[@]}"; do
        local nominal=${amounts[$i]}

        if (( nominal >= 0 )); then
            warna=$GREEN
        else
            warna=$RED
        fi

        echo -e "$((i+1)). ${notes[$i]} -> ${warna}Rp $nominal${RESET}"
    done
    echo -e "${CYAN}==============================${RESET}"
}

# Fungsi menghitung total saldo
total_saldo() {
    local total=0
    for value in "${amounts[@]}"; do
        total=$(( total + value ))
    done

    echo -e "${CYAN}Total Saldo Saat Ini:${RESET} Rp $total"
}

# Fungsi tambah pemasukan
tambah_pemasukan() {
    read -p "Masukkan jumlah: Rp. " jumlah
    if ! [[ "$jumlah" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Harus berupa angka positif.${RESET}"
        return
    fi

    read -p "Keterangan: " ket
    if [ -z "$ket" ]; then
        echo -e "${RED}Keterangan tidak boleh kosong.${RESET}"
        return
    fi

    notes+=("$ket")
    amounts+=("$jumlah")
    echo -e "${GREEN}Pemasukan berhasil ditambahkan. +Rp.$jumlah ${RESET}"
}

# Fungsi tambah pengeluaran
tambah_pengeluaran() {
    read -p "Masukkan jumlah (angka): Rp. " jumlah
    if ! [[ "$jumlah" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Harus berupa angka positif.${RESET}"
        return
    fi

    read -p "Keterangan: " ket
    if [ -z "$ket" ]; then
        echo -e "${RED}Keterangan tidak boleh kosong.${RESET}"
        return
    fi

    notes+=("$ket")
    amounts+=("$((-jumlah))")
    echo -e "${RED}Pengeluaran berhasil ditambahkan. -Rp.$jumlah ${RESET}"
}

# Fungsi hapus catatan
hapus_catatan() {
    show_notes
    if [ ${#notes[@]} -eq 0 ]; then return; fi

    read -p "Pilih nomor yang mau dihapus: " idx

    if ! [[ "$idx" =~ ^[0-9]+$ ]] || (( idx < 1 || idx > ${#notes[@]} )); then
        echo -e "${RED}Nomor tidak valid.${RESET}"
        return
    fi

    local real_idx=$(( idx - 1 ))

    unset notes[$real_idx]
    unset amounts[$real_idx]

    # rapikan index array
    notes=("${notes[@]}")
    amounts=("${amounts[@]}")

    echo -e "${YELLOW}Catatan berhasil dihapus.${RESET}"
}

# ==========================
# Menu utama
# ==========================

while true; do
    echo -e "
${CYAN}===== CATATAN KEUANGAN =====${RESET}
1. Tambah Pemasukan
2. Tambah Pengeluaran
3. Lihat Catatan
4. Total Saldo
5. Hapus Catatan
6. Keluar
"

    read -p "Pilih Nomor (1-6): " pilihan

    case $pilihan in
        1) tambah_pemasukan ;;
        2) tambah_pengeluaran ;;
        3) show_notes ;;
        4) total_saldo ;;
        5) hapus_catatan ;;
        6) echo "Keluar dari program"; exit ;;
        *) echo -e "${RED}Pilihan tidak valid.${RESET}" ;;
    esac

done

