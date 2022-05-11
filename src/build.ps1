$path = $MyInvocation.MyCommand.Path | Split-Path -Parent
$import_svg_path = Get-Item $path\icon-import.svg

Get-Item .\src\lib\fontawesome-free-6.1.1-desktop\fontawesome-free-6.1.1-desktop\svgs\*\*.svg | ForEach-Object {

  $name = $_ | Select-Object -ExpandProperty BaseName
  "$_"

  Copy-Item $_ $import_svg_path
  & 'C:\Program Files\Inkscape\bin\inkscape.com' --actions="select-clear; export-area-drawing; export-type:png; export-width:200; export-height:200; select-by-id:icon; object-align:hcenter vcenter drawing; select-by-id:inactive; select-by-id:active; object-set-attribute:style,display:inline; export-filename:${path}\output\${name}_Active; export-do; select-clear; select-by-id:active; object-set-attribute:style,display:none; export-filename:${path}\output\${name}_Inactive; export-do; select-clear; select-by-id:inactive; object-set-attribute:style,display:none; export-filename:${path}\output\${name}_Clear; export-do;" 'C:\Users\carso\Nextcloud\Web Dev\Macro-Deck-Icon-Powered-Steel\src\Icon_Powered_Steel.svg'

}
