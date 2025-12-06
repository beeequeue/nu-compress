# TODO: compress dir gz

# Compress a directory to a tar archive with zstd
export def "compress dir zst" [
  # zstd compression level, 0-19.
  # Defaults to 12
  --level(-l): int = 12
  # Use zstd long distance matching. May improve compression ratio for large (4mb+) files.
  --long(-L)
  # zstd compression threads.
  # Defaults to half of (sys cpu)
  --threads(-t): int
  # Path of directory to compress
  directory: path
] {
  if ($directory | path type) != "dir" {
    error make { msg: "Path is not a directory" }
  }

  let actual_threads = if $threads != null {
    $threads
  } else {
    ((sys cpu | length) / 1.25) | math ceil
  }

  let name: string = $"($directory | path basename).tar.zst"
  let long_flag = if $long != null { "--long" } else { "" }

  do {
    cd ($directory | path dirname | path expand)

    $env.ZSTD_CLEVEL = ($level | into int)
    $env.ZSTD_NBTHREADS = ($actual_threads | into int)
    tar -I zstd -cf $name ($directory | path basename)
  }
}

# TODO: compress dir bzip2
# TODO: compress dir bzip3