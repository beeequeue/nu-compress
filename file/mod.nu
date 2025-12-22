use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/zstd.nu *

# Compress a file to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress file zst foo.txt } --result "./foo.txt.zst"
@example "Custom effort" { compress file zst -e max foo/bar.tar } --result "./foo/bar.tar.zst"
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
  file: path
  # Path of file to compress.
]: nothing -> path {
  if ($file | path type) != "file" {
    error input "Is not a file" --metadata (metadata $file)
  }

  let paths = if $force {
    get-and-check-paths $file ".zst" -f -m (metadata $file)
  } else {
    get-and-check-paths $file ".zst" -m (metadata $file)
  }

  # options
  let effort = effort zstd $effort
  #let actual_long = if $long != null { "--long" } else { "" }
  let threads = get-threads $threads

  do {
    cd $paths.active_dir

    $env.ZSTD_CLEVEL = $effort
    $env.ZSTD_NBTHREADS = $threads
    zstd --force --quiet $paths.input_name -o $paths.output_name
  }

  let diff = diff paths $file $paths.output_path

  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $paths.output_path
}

# Compress a file to a tar archive with bzip3.
#
# Returns the relative path to the created archive.
@example "Simple" { compress file bz3 foo.txt } --result "./foo.txt.bz3"
export def bz3 [
  --force(-f)
  --threads(-t): int@"nu-complete thread-count"
  # bzip3 compression threads.
  # Defaults to 75% of available threads
  file: path
  # Path of file to compress.
]: nothing -> path {
  if ($file | path type) != "file" {
    error input "Is not a file" --metadata (metadata $file)
  }

  let paths = if $force {
    get-and-check-paths $file ".bz3" -f -m (metadata $file)
  } else {
    get-and-check-paths $file ".bz3" -m (metadata $file)
  }

  let threads = get-threads $threads

  do {
    cd $paths.active_dir

    tar -I bzip3 -cf $paths.output_name $paths.input_name
  }

  let diff = diff paths $file $paths.output_path

  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $paths.output_path
}
