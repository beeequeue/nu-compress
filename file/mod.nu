use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/zstd.nu *

# Compress a file to a tar archive with zstd.
#
# Returns the relative path to the created archive.
@example "Simple" { compress file zst foo.txt } --result "./foo.txt.zst"
@example "Custom level" { compress file zst -l max foo/bar.txt } --result "./foo/bar.txt.zst"
export def zst [
  --force(-f)
  # Overwrite existing output file if it exists.
  --level(-l): string@"nu-complete level zstd" = "normal"
  # zstd level: fast (3), normal (12), slow (17), max(19).
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

  # paths
  let input_name = $file | path basename
  let output_name = $input_name + ".zst"
  let active_dir = $file | path dirname
  let out_path = $active_dir | path join $output_name

  if not $force and ($out_path | path exists) {
    error input $"Output file already exists \(($output_name))" --metadata (metadata $file)
  }

  # options
  let level = level zstd $level
  #let actual_long = if $long != null { "--long" } else { "" }
  let threads = get-threads $threads

  do {
    cd $active_dir

    $env.ZSTD_CLEVEL = $level
    $env.ZSTD_NBTHREADS = $threads
    zstd --force --quiet $input_name -o $output_name
  }

  let diff = diff paths $file $out_path

  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $out_path
}
