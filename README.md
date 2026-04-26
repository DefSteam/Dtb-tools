# DTB Converter

Tools for extracting DTB blobs from an image, editing DTS sources, and packing the result back into a new image.

## Requirements

- Python 3
- `dtc` (Device Tree Compiler)

Example install on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install python3 device-tree-compiler
```

## Linux: single-script workflow

Use the Linux helper script from the repository root:

```bash
./dtb_tool_linux.sh
```

The script provides an interactive menu with built-in instructions for:

1. **Unpack image**
   - Copies your selected image into `Superb_Extract-and_pack_dtb/WorkDir/work.img`
   - Extracts DTB/DTS files into `Superb_Extract-and_pack_dtb/dtb/`
2. **Pack image**
   - Rebuilds DTB files from edited DTS files
   - Produces `Superb_Extract-and_pack_dtb/your_new_file.img`
3. **Clean work files**
   - Removes temporary files (`work.img`, `dtb_offsets.txt`, `dtb/`, and output image)

## Legacy Windows scripts

The original Windows CMD scripts are still available in `Superb_Extract-and_pack_dtb/`:

- `UNPACK_drag_to_me_your_file.cmd`
- `PACK.cmd`
- `CLEAR_work_file.cmd`
