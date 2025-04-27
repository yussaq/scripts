#!/bin/bash

# Script untuk menambahkan watermark pada semua file PDF dalam folder dan subfolder
# Menggunakan pdftk untuk menambahkan watermark
# Pastikan pdftk terinstal
# Usage: ./watermark.sh /path/to/sumber /path/to/output
# Memberi izin agar file script watermark.sh bisa dijalankan : chmod +x watermark.sh 
# yussaq.nf@gmail.com

# Cek apakah pdftk terinstal
if ! command -v pdftk &> /dev/null; then
    echo "pdftk tidak ditemukan. Silakan instal pdftk terlebih dahulu."
    exit 1
fi
# Cek apakah watermark.pdf ada
if [ ! -f "watermark.pdf" ]; then
    echo "File watermark.pdf tidak ditemukan. Pastikan file watermark.pdf ada di direktori yang sama dengan script ini."
    exit 1
fi
# Cek apakah watermark.pdf adalah file PDF
if ! file --mime-type -b "watermark.pdf" | grep -q 'application/pdf'; then
    echo "File watermark.pdf bukan file PDF yang valid."
    exit 1
fi
# Cek apakah pdftk dapat membaca file PDF
if ! pdftk "watermark.pdf" dump_data &> /dev/null; then
    echo "pdftk tidak dapat membaca file watermark.pdf. Pastikan file tersebut adalah PDF yang valid."
    exit 1
fi

# Cek apakah argumen diberikan
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 /path/to/sumber /path/to/output"
    exit 1
fi

SOURCE_DIR=$(realpath "$1")
OUTPUT_ROOT=$(realpath "$2")

# Cek apakah direktori valid
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: '$SOURCE_DIR' is not a valid directory."
    exit 1
fi

mkdir -p "$OUTPUT_ROOT"

# Proses semua file PDF dalam folder dan subfolder, kecuali folder hasil
find "$SOURCE_DIR" -type f -name "*.pdf" ! -path "$OUTPUT_ROOT/*" | while read -r file; do
    # Ambil path relatif dari sumber
    relative_path=$(realpath --relative-to="$SOURCE_DIR" "$file")
    base=$(basename "$file")
    dir=$(dirname "$relative_path")

    # Buat direktori tujuan sesuai struktur relatif di dalam folder hasil
    output_dir="$OUTPUT_ROOT/$dir"
    mkdir -p "$output_dir"

    final="$output_dir/$base"

    echo "Menambahkan watermark: $relative_path"

    # Tambah watermark
    pdftk "$file" stamp watermark.pdf output "$final"

done

echo "Selesai! Hasil disimpan di: $OUTPUT_ROOT"
