export def add-flag [
  flag: string
  input: oneof<any>
]: list<oneof<string, int>> -> list<oneof<string, int>> {
  $in
  | append (
    if $input == true {
      [$flag]
    } else if $input == false {
      []
    } else {
      [$flag ($input | into string)]
    }
  )
}

export def ffmpeg-flags [
  --force(-f)
  --verbose(-v): string = "error"
  --threads(-t): oneof<int, nothing>
  --input(-i): path
]: list<string> -> list<string> {
  $in
  | add-flag "-hide_banner" true
  | add-flag "-v" $verbose
  | add-flag "-y" $force
  | add-flag "-threads" $threads
  | add-flag "-i" $input
}
