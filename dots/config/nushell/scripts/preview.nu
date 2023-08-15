#!/usr/bin/env nu
def main [line: string] {
  if ($line | str contains ':') {
    let p = ($line | parse -r '(?P<file>[A-Za-z_.-/]+):(?P<line>\d+)')
    let file = ($p | get file.0)
    let line = ($p | get line.0)
    bat --style=numbers --color=always --line-range $"($line):" --highlight-line $line $file
  } else {
    bat --style=numbers --color=always $line
  }
}
