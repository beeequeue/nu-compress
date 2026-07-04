use ../utils/audio.nu *
use ../utils/error.nu *
use ../utils/flags.nu *
use ../utils/input.nu *
use ../utils/size.nu *

# Compress an audio file using OGG.
@example "Simple" { compress audio ogg foo.wav } --result "./foo.ogg"
@example "Complex" { compress audio ogg --quality best foo.wav } --result "./foo.ogg"
export def ogg [
  --force(-f)
  --quality(-q): string@"nu-complete quality audio" = "average"
  # audio quality: tiny (22kHz/128kbps), average (44kHz/256kbps), better (48kHz/320kbps), best (192kHz/512kbps).
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads. Defaults to 75% of available threads
  files: glob
  # Path of file to compress.
]: nothing -> nothing {
  return (
    compress-audio 
      "libvorbis" 
      ".ogg"
        --force=$force
        --quality=$quality
        --threads=$threads
        $files
  )
}

@example "Simple" { compress audio opus foo.wav } --result "./foo.opus"
@example "Complex" { compress audio opus --quality best foo.wav } --result "./foo.opus"
export def opus [
  --force(-f)
  --quality(-q): string@"nu-complete quality audio" = "average"
  # audio quality: tiny (22kHz/128kbps), average (44kHz/256kbps), better (48kHz/320kbps), best (192kHz/512kbps).
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads. Defaults to 75% of available threads
  files: glob
  # Path of file to compress.
]: nothing -> nothing {
  return (
    compress-audio 
      "libopus" 
      ".opus"
        --force=$force
        --quality=$quality
        --threads=$threads
        $files
  )
}

def compress-audio [
  codec: string
  extension: string
  --force(-f)
  --quality(-q): string@"nu-complete quality audio" = "average"
  # audio quality: tiny (22kHz/128kbps), average (44kHz/256kbps), better (48kHz/320kbps), best (192kHz/512kbps).
  --threads(-t): int@"nu-complete thread-count"
  # ffmpeg threads. Defaults to 75% of available threads
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
    get-and-check-paths $files $extension --rm-ext --force=$force -m (metadata $files)
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let threads = get-threads $threads
  let quality = quality audio $quality

  do {
    cd $file_metadatas.0.active_dir
    $env.SVT_LOG = 1

    $file_metadatas | par-each {|paths|
      let flags: list<string> = []
      | ffmpeg-flags --force=$force --threads=$threads --input=$paths.input_name
      | add-flag "-map_metadata" "0"
      | add-flag "-vn" true
      | add-flag "-c:a" $codec
      | add-flag "-b:a" $quality.bits
      | add-flag "-ar" $quality.samples

      null | ffmpeg ...$flags $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }

  return
}
