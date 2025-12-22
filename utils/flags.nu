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
