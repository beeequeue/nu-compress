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
      get-and-check-paths $in ".avif" --rm-ext --force=$force -m (metadata $in)
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
      null | ffmpeg -v error $force -threads $threads -i $paths.input_name -c:v libsvtav1 -svtav1-params "avif=1" -crf $level -preset $preset $paths.output_name

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
      error input "Is not a file" --metadata (metadata $file_path)
    }
  }

  let file_metadatas = (
    $files | par-each -k {|file|
      $file
      | path relative-to $env.PWD
      get-and-check-paths $in ".webp" --rm-ext --force=$force -m (metadata $in)
    }
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let quality = if $quality == null and not $lossless {
    quality webp "better"
  } else {
    quality webp $quality
  }
  let effort = effort webp $effort
  let threads = get-threads $threads

  do {
    cd $file_metadatas.0.active_dir

    $file_metadatas | each {|paths|
      mut flags: list<string> = []
      | add-flag "-v" "error"
      | add-flag "-y" $force
      | add-flag "-threads" $threads
      | add-flag "-i" $paths.input_name
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
