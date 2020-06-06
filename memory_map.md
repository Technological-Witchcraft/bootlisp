This is an OS-specific memory map. x86-specific things are marked as "reserved".

| Start     | End       | Size     | Name         |
| --------- | --------- | -------- | ------------ |
| `0x00000` | `0x004FF` | 1.25KiB  | Reserved     |
| `0x00500` | `0x074FF` | 28KiB    | Prelude      |
| `0x07500` | `0x07BFF` | 1.75KiB  | System Info  |
| `0x07C00` | `0x07DFF` | 512B     | Interpreter  |
| `0x07E00` | `0x08DFF` | 4KiB     | Input Buffer |
| `0x08E00` | `0x7FFFF` | 476.5KiB | Heap         |
| `0x80000` | `0xFFFFF` | 512KiB   | Reserved     |
