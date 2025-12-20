use ../utils/av1.nu *
use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/video.nu *

# Compress a file to a tar archive with av1.
#
# Returns the relative path to the created archive.
@example "Simple" { compress video av1 video.mp4 } --result "./video.mkv"
@example "Custom preset" { compress video av1 -c mp4 -l max foo/bar.mp4 } --result "./foo/bar.mp4"
export def av1 [
  --force(-f)
  # Overwrite existing output file if it exists.
  --level(-l): string@"nu-complete level av1" = "average"
  # av1 quality level: smallest (40), small (30), average (20), better (15), best (8).
  # Defaults to average.
  --preset(-p): string@"nu-complete preset av1" = "max"
  # av1 speed preset: veryfast (10), fast (8), normal (4), slow (2), max(1).
  # Defaults to normal.
  --container(-c): string@"nu-complete video container" = "mkv"
  # Container to store the audiovisual data in.
  # Defaults to mkv.
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads.
  # Defaults to 75% of available threads
  files: glob
  # Path of file to compress.
]: nothing -> nothing {
  let files = glob $files
  for file_path in $files {
    if ($file_path | path type) != "file" {
      error input "Is not a file" --metadata (metadata $file_path)
    }
  }

  let file_metadatas = (
    $files | par-each -k {|file|
      $file
      | path relative-to $env.PWD
      get-and-check-paths $in $".($container)" --rm-ext --force=$force -m (metadata $in)
    }
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let level = level av1 $level
  let preset = preset av1 $preset
  let threads = get-threads $threads
  let force = if $force { "-y" } else { "" }

  do {
    cd $file_metadatas.0.active_dir
    $env.SVT_LOG = 1

    $file_metadatas | each {|paths|
      null | ffmpeg -hide_banner -v info $force -threads $threads -i $paths.input_name -c:v libsvtav1 -crf $level -preset $preset $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }

  return
}
