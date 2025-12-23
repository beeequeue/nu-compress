use ../utils/av1.nu *
use ../utils/error.nu *
use ../utils/flags.nu *
use ../utils/input.nu *
use ../utils/size.nu *
use ../utils/webp.nu *

# Compress a file to a tar archive with av1.
#
# Returns the relative path to the created archive.
@example "Simple" { compress image av1 image.png } --result "./image.avif"
@example "Custom effort" { compress image av1 -l max foo/bar.png } --result "./foo/bar.avif"
export def av1 [
  --force(-f)
  # Overwrite existing output file if it exists.
  --quality(-q): string@"nu-complete quality av1" = "better"
  # av1 quality: smallest (40), small (30), average (20), better (15), best (8).
  --effort(-e): string@"nu-complete effort av1" = "max"
  # av1 speed effort: veryfast (10), fast (8), normal (4), slow (2), max(1).
  # Defaults to max (smallest filesize).
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
    get-and-check-paths $files ".avif" --rm-ext --force=$force -m (metadata $files)
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
      | ffmpeg-flags --force=$force --threads=$threads --input=$paths.input_name
      | add-flag "-c:v" "libsvtav1"
      | add-flag "-svtav1-params" "avif=1"
      | add-flag "-preset" $effort
      | add-flag "-crf" $quality

      null | ffmpeg ...$flags $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }

  return
}

# Compress a file to a tar archive with webp.
#
# Returns the relative path to the created archive.
@example "Simple" { compress image webp image.png } --result "./image.webp"
@example "Custom effort" { compress image webp -l max foo/bar.png } --result "./foo/bar.webp"
export def webp [
  --force(-f)
  # Overwrite existing output file if it exists.
  --lossless(-l)
  # Use lossless compression.
  --quality(-q): string@"nu-complete quality webp"
  # webp quality: smallest (15), small (40), average (75), better (85), best (95).
  --effort(-e): string@"nu-complete effort webp" = "max"
  # webp effort: veryfast (10), fast (8), normal (4), slow (2), max(1).
  # Defaults to max (smallest filesize).
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads.
  # Defaults to 75% of available threads
  files: glob
  # Path of file to compress.
]: nothing -> nothing {
  if $quality == null and not $lossless {
    error make {
      msg: "Cannot use --lossless and --quality together."
      label: {
        ...(metadata $quality)
        text: "Remove this or the --lossless (-s) flag."
      }
    }
  }

  let files = glob $files
  for file_path in $files {
    if ($file_path | path type) != "file" {
      error input "Is not a file" --metadata (metadata $files)
    }
  }

  let file_metadatas = (
    get-and-check-paths $files ".webp" --rm-ext --force=$force -m (metadata $files)
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let quality = quality webp $quality --lossless=$lossless
  let effort = effort webp $effort
  let threads = get-threads $threads

  do {
    cd $file_metadatas.0.active_dir

    $file_metadatas | each {|paths|
      mut flags: list<string> = []
      | ffmpeg-flags --force=$force --threads=$threads --input=$paths.input_name
      | add-flag "-c:v" "libwebp"
      | add-flag "-compression_level" $effort

      if $lossless {
        $flags = $flags
        | add-flag "-lossless" 1
        | add-flag "-quality" 100
      } else {
        $flags = $flags
        | add-flag "-quality" $quality
      }

      null | ffmpeg ...$flags $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }

  return
}
