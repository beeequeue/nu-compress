use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/zstd.nu *

# Compress a directory to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress dir zst foo/bar/ } --result "./foo/bar.tar.zst"
@example "Custom effort" { compress dir zst -l max foo/bar/ } --result "./foo/bar.tar.zst"
export def zst [
  --force(-f)
  # Overwrite existing output file if it exists.
  --effort(-e): string@"nu-complete effort zstd" = "normal"
  # zstd effort: fast (3), normal (12), slow (17), max(19).
  # Defaults to normal
  --long(-L)
  # Use zstd long distance matching. May improve compression ratio for large (4MB+) files.
  --threads(-t): int@"nu-complete thread-count"
  # zstd compression threads.
  # Defaults to 75% of available threads
  globs: glob
  # Path of directory to compress.
]: nothing -> nothing {
  let paths = glob $globs
  for file_path in $paths {
    if ($file_path | path type) != "dir" {
      error input "Is not a directory" --metadata (metadata $paths)
    }
  }

  let metadatas = (
    get-and-check-paths $paths ".tar.zst" --rm-ext --force=$force -m (metadata $paths)
  )
  if ($metadatas | is-empty) { return }

  # options
  let effort = effort zstd $effort
  #let actual_long = if $long != null { "--long" } else { "" }
  let threads = get-threads $threads

  do {
    cd $metadatas.0.active_dir

    $metadatas | each {|paths|
      $env.ZSTD_CLEVEL = $effort
      $env.ZSTD_NBTHREADS = $threads
      tar -I zstd -cf $paths.output_name $paths.input_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }
}

# Compress a directory to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress dir bz3 foo/bar/ } --result "./foo/bar.tar.bz3"
export def bz3 [
  --force(-f)
  # Overwrite existing output file if it exists.
  --threads(-t): int@"nu-complete thread-count"
  # bzip3 compression threads.
  # Defaults to 75% of available threads
  globs: glob
  # Path of directory to compress.
]: nothing -> path {
  let paths = glob $globs
  for file_path in $paths {
    if ($file_path | path type) != "dir" {
      error input "Is not a directory" --metadata (metadata $paths)
    }
  }

  let metadatas = (
    get-and-check-paths $paths ".tar.bz3" --rm-ext --force=$force -m (metadata $paths)
  )
  if ($metadatas | is-empty) { return }

  # options
  let threads = get-threads $threads

  do {
    cd $metadatas.0.active_dir

    $metadatas | each {|paths|
      tar -I bzip3 -cf $paths.output_name $paths.input_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }
}


# Placeholder for bzip2 compression of directories
# export def bz2 [
# ]: nothing -> error {
#   error make { msg: "bzip2 directory compression is not yet implemented." }
# }


# Placeholder for gzip compression of directories
# export def gz [
# ]: nothing -> error {
#   error make { msg: "gzip directory compression is not yet implemented." }
# }
