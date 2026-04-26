#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/Superb_Extract-and_pack_dtb/WorkDir"
DTB_DIR="$SCRIPT_DIR/Superb_Extract-and_pack_dtb/dtb"
OUTPUT_IMAGE="$SCRIPT_DIR/Superb_Extract-and_pack_dtb/your_new_file.img"

ensure_requirements() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] python3 is required but not installed."
    exit 1
  fi

  if ! command -v dtc >/dev/null 2>&1; then
    echo "[ERROR] Device Tree Compiler (dtc) is required but not installed."
    echo "Install example (Debian/Ubuntu): sudo apt install device-tree-compiler"
    exit 1
  fi

  mkdir -p "$WORK_DIR/bin"
  cat > "$WORK_DIR/bin/dtc" <<'DTCWRAP'
#!/usr/bin/env bash
exec dtc "$@"
DTCWRAP
  chmod +x "$WORK_DIR/bin/dtc"
}

print_main_menu() {
  cat <<'MENU'

Linux DTB Tool - choose an action:
  1) Unpack image (extract DTB + DTS files)
  2) Pack image   (rebuild DTB from DTS and write into new image)
  3) Clean work files
  4) Exit
MENU
}

run_unpack() {
  echo
  echo "[UNPACK] Basic instructions:"
  echo "  - Enter the path to your source image (boot.img, kernel image, etc.)."
  echo "  - The file will be copied to WorkDir/work.img."
  echo "  - Extracted DTB/DTS files will be written to Superb_Extract-and_pack_dtb/dtb/."
  echo "  - Edit .dts files there before running PACK."

  read -r -p "Image path: " input_image
  if [[ ! -f "$input_image" ]]; then
    echo "[ERROR] File not found: $input_image"
    return 1
  fi

  cp -f "$input_image" "$WORK_DIR/work.img"
  (cd "$WORK_DIR" && python3 extract-dtb.py work.img)

  echo "[DONE] Unpack complete. Edit DTS files in: $DTB_DIR"
}

run_pack() {
  echo
  echo "[PACK] Basic instructions:"
  echo "  - Make sure you already ran UNPACK and edited DTS files in dtb/."
  echo "  - This action recompiles DTS -> DTB and injects them using saved offsets."
  echo "  - Output file will be: Superb_Extract-and_pack_dtb/your_new_file.img"

  if [[ ! -f "$WORK_DIR/work.img" ]]; then
    echo "[ERROR] Missing $WORK_DIR/work.img. Run UNPACK first."
    return 1
  fi

  if [[ ! -f "$WORK_DIR/dtb_offsets.txt" ]]; then
    echo "[ERROR] Missing $WORK_DIR/dtb_offsets.txt. Run UNPACK first."
    return 1
  fi

  if [[ ! -d "$DTB_DIR" ]]; then
    echo "[ERROR] Missing $DTB_DIR. Run UNPACK first."
    return 1
  fi

  (cd "$WORK_DIR" && python3 pack-dtb.py)
  echo "[DONE] Pack complete: $OUTPUT_IMAGE"
}

run_clean() {
  echo
  echo "[CLEAN] Basic instructions:"
  echo "  - Removes temporary work image, offsets file, extracted dtb/ folder, and output image."
  echo "  - Use this when you want a fresh start."

  rm -f "$WORK_DIR/work.img" "$WORK_DIR/dtb_offsets.txt" "$OUTPUT_IMAGE"
  rm -rf "$DTB_DIR"

  echo "[DONE] Work files cleaned."
}

main() {
  ensure_requirements

  while true; do
    print_main_menu
    read -r -p "Select [1-4]: " choice

    case "$choice" in
      1) run_unpack ;;
      2) run_pack ;;
      3) run_clean ;;
      4) echo "Bye."; exit 0 ;;
      *) echo "Invalid choice. Please select 1, 2, 3, or 4." ;;
    esac
  done
}

main "$@"
