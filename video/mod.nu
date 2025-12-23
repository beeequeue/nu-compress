use ../utils/av1.nu *
use ../utils/error.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/video.nu *

# Compress a file to a tar archive with av1.
#
# Returns the relative path to the created archive.
@example "Simple" { compress video av1 video.mp4 } --result "./video.mkv"
@example "Custom container" { compress video av1 -c mp4 -l max foo/bar.mp4 } --result "./foo/bar.mp4"
export def av1 [
  --force(-f)
  # Overwrite existing output file if it exists.
  --quality(-q): string@"nu-complete quality av1" = "average"
  # av1 quality: smallest (40), small (30), average (20), better (15), best (8).
  # Defaults to average.
  --effort(-e): string@"nu-complete effort av1" = "max"
  # av1 speed effort: veryfast (10), fast (8), normal (4), slow (2), max(1).
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
      error input "Is not a file" --metadata (metadata $files)
    }
  }

  let file_metadatas = (
    get-and-check-paths $files $".($container)" --rm-ext --force=$force -m (metadata $files)
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let quality = quality av1 $quality
  let effort = effort av1 $effort
  let threads = get-threads $threads

  do {
    cd $file_metadatas.0.active_dir
    $env.SVT_LOG = 1

    $file_metadatas | each {|paths|
      let flags: list<string> = []
      | ffmpeg-flags -v=info --force=$force --threads=$threads --input=$paths.input_name
      | add-flag "-c:v" "libsvtav1"
      | add-flag "-preset" $effort
      | add-flag "-crf" $quality

      null | ffmpeg ...$flags $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }

  return
}
