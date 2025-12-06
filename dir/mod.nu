use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/zstd.nu *

# Compress a directory to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress dir zst foo/bar/ } --result "./foo/bar.tar.zst"
@example "Custom level" { compress dir zst -l max foo/bar/ } --result "./foo/bar.tar.zst"
export def zst [
  --level(-l): string@"nu-complete level zstd" = "normal"
  # zstd level: fast (3), normal (12), slow (17), max(19).
  # Defaults to normal
  --long(-L)
  # Use zstd long distance matching. May improve compression ratio for large (4MB+) files.
  --threads(-t): int@"nu-complete thread-count"
  # zstd compression threads.
  # Defaults to 75% of available threads
  directory: path
  # Path of directory to compress.
]: nothing -> path {
  if ($directory | path type) != "dir" {
    error input "Is not a directory" --metadata (metadata $directory)
  }

  let actual_level = level zstd $level
  #let actual_long = if $long != null { "--long" } else { "" }
  let threads = get-threads $threads

  let input_name = ($directory | path basename)
  let name = $input_name + ".tar.zst"
  let active_dir = ($directory | path dirname | path expand)

  do {
    cd $active_dir

    $env.ZSTD_CLEVEL = $actual_level
    $env.ZSTD_NBTHREADS = $threads
    tar -I zstd -cf $name $input_name
  }

  let out_path = $active_dir | path join $name
  let diff = diff paths $directory $out_path

  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $out_path
}

# Compress a directory to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress dir bz3 foo/bar/ } --result "./foo/bar.tar.bz3"
export def bz3 [
  --threads(-t): int@"nu-complete thread-count"
  # bzip3 compression threads.
  # Defaults to 75% of available threads
  directory: path
  # Path of directory to compress.
]: nothing -> path {
  if ($directory | path type) != "dir" {
    error input "Is not a directory" --metadata (metadata $directory)
  }

  let threads = get-threads $threads

  let input_name = ($directory | path basename)
  let name = $input_name + ".tar.bz3"

  let active_dir = ($directory | path dirname | path expand)
  do {
    cd $active_dir

    # let bz3_cmd = $"bzip3 -z --jobs=($threads)"
    tar -I bzip3 -cf $name $input_name
  }

  let out_path = $active_dir | path join $name
  let diff = diff paths $directory $out_path

  # TODO: add --silent flag
  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $out_path
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
