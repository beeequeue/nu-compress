use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/av1.nu *

# Compress a file to a tar archive with av1.
#
# Returns the relative path to the created archive.
@example "Simple" { compress image av1 image.png } --result "./image.avif"
@example "Custom preset" { compress image av1 -l max foo/bar.png } --result "./foo/bar.avif"
export def av1 [
  --force(-f)
  # Overwrite existing output file if it exists.
  --level(-l): string@"nu-complete level av1" = "better"
  # av1 quality level: smallest (40), small (30), average (20), better (15), best (8).
  --preset(-p): string@"nu-complete preset av1" = "max"
  # av1 speed preset: veryfast (10), fast (8), normal (4), slow (2), max(1).
  # Defaults to max (smallest filesize).
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads.
  # Defaults to 75% of available threads
  file: path
  # Path of file to compress.
]: nothing -> path {
  if ($file | path type) != "file" {
    error input "Is not a file" --metadata (metadata $file)
  }

  let paths = if $force {
    get-and-check-paths $file ".avif" --rm-ext -f -m (metadata $file)
  } else {
    get-and-check-paths $file ".avif" --rm-ext -m (metadata $file)
  }

  # options
  let preset = preset av1 $preset
  let threads = get-threads $threads
  let force = if $force { "-y" } else { "" }

  do {
    cd $paths.active_dir

    $env.SVT_LOG = 1
    null | ffmpeg -v error $force -threads $threads -i $paths.input_name -c:v libsvtav1 -svtav1-params "avif=1" -crf 18 -preset $preset $paths.output_name
  }

  let diff = diff paths $file $paths.output_path

  print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute))"

  return $paths.output_path
}
