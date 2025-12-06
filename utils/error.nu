export def "error input" [
  message: string
  --hm: string
  --metadata: record<span: any>
]: nothing -> error {
  error make {
    msg: "Invalid input"
    label: { ...$metadata, text: $message }
    help: $hm
  }
}
