use ../utils/error.nu *
use ../utils/flags.nu *
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
    get-and-check-paths $files ".zst" --rm-ext --force=$force -m (metadata $files)
  )
  if ($file_metadatas | is-empty) { return }

  # options
  let effort = effort zstd $effort
  let threads = get-threads $threads

  do {
    cd $file_metadatas.0.active_dir

    $file_metadatas | each {|paths|
      let flags = []
      | add-flag "--force" $force
      | add-flag $"-T($threads)" true
      | add-flag $"-($effort)" true
      | add-flag "--long" $long
      zstd ...$flags $paths.input_name -o $paths.output_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }
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
  --block(-b): int
  # Block size in MB. Defaults to 16.
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
    get-and-check-paths $files ".bz3" --rm-ext --force=$force -m (metadata $files)
  )
  if ($file_metadatas | is-empty) { return }

  let threads = get-threads $threads

  do {
    cd $file_metadatas.0.active_dir

    $file_metadatas | each {|paths|
      let flags = []
      | add-flag "--force" $force
      | add-flag "--jobs" $threads
      | add-flag "--block" $block
      bzip3 ...$flags $paths.input_name

      let diff = diff paths $paths.input_name $paths.output_path
      print $"($diff.before) -> ($diff.after) \(($diff.percent) ($diff.absolute)) | ($paths.output_name)"
    }
  }
}
