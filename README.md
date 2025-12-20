# nu-compress

This is a library for easily compressing various directories and file types implemented in nushell!

It's effectively just a wrapper around other tools like `ffmpeg` or `zstd` to hopefully reduce the amount of times I have to copy, paste, and modify my previous commands to be slightly different.

## Dependencies (available in PATH)

- `ffmpeg`: `>=7`(?)
  - `compress image *`
  - `compress video *`
- `zstd`: `^1`
  - `compress * zst`
- `bzip3`: `^1`
  - `compress * bz3`

## Usage

1. Install the project (files) somewhere somehow (todo)
1. Run `use compress`
1. Run a compress command

## Commands

For usage, see the help info for the commands:

### Images

```nushell
compress image av1 --help
```

### Videos

```nushell
compress video av1 --help
```

### Files

<!-- Either compresses a file directly or creates a compressed tar file if multiple files are specified. -->

```nushell
compress file zst --help
```

```nushell
compress file bz3 --help
```

### Directories

Creates a compressed tar file containing the specified directory.

```nushell
compress dir zst --help
```

```nushell
compress dir bz3 --help
```
